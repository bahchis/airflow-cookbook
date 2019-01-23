import requests
import jwt
import flask_login
from flask_login import login_required, logout_user, current_user, UserMixin
from flask import flash, url_for, redirect, request, current_app

from airflow import models
from airflow import configuration
from airflow.configuration import AirflowConfigException
from airflow.utils.log.logging_mixin import LoggingMixin

log = LoggingMixin().log

login_manager = flask_login.LoginManager()
login_manager.login_view = 'airflow.login'
login_manager.session_protection = "Strong"

JWT_SUBJECT_KEY = 'sub'

class AuthenticationError(Exception):
    pass

class JWTUser(models.User):
    def __init__(self, user):
        self.user = user
        log.debug("User is: {}".format(user))
        if configuration.conf.getboolean("webserver", "filter_by_owner"):
            superuser_username = configuration.conf.get("webserver", "superuser")
            if user.username == superuser_username:
                self.superuser = True
            else:
                self.superuser = False
        else:
            self.superuser = True

    @property
    def is_active(self):
        """Required by flask_login"""
        return True

    @property
    def is_authenticated(self):
        """Required by flask_login"""
        return True

    @property
    def is_anonymous(self):
        """Required by flask_login"""
        return False

    def data_profiling(self):
        """Provides access to data profiling tools"""
        return self.superuser
    
    def is_superuser(self):
        """Access all things"""
        return self.superuser

    def get_id(self):
        return self.user.get_id()
    

@login_manager.user_loader
def load_user(user_id):
    log.debug("Loading user with id: {0}".format(user_id))
    user = models.User(id=user_id, username=user_id, is_superuser=False)
    return JWTUser(user)

def authenticate(jwt):
    request_headers = {'Authorization': jwt}
    auth_endpoint = configuration.conf.get("webserver", "jwt_auth_endpoint")
    response = requests.get(auth_endpoint, headers=request_headers, verify=False)
    if response.status_code != requests.codes.ok:
        raise AuthenticationError()

def login(self, request):
    if current_user.is_authenticated:
        flash("You are already logged in")
        return redirect(url_for('index'))

    if 'Authorization' not in request.headers:
        flash("Missing authorization header")
        return redirect(url_for('airflow.noaccess'))

    jwt_bearer = request.headers.get('Authorization')

    try:
        authenticate(jwt_bearer)
        encoded_jwt = jwt_bearer.split(' ')[1].strip()
        decoded_jwt = decode_jwt(encoded_jwt)
        username = decoded_jwt[JWT_SUBJECT_KEY]
        log.debug("Subject is: {}".format(username))

        user = models.User(id=username, username=username, is_superuser=False)
        
        flask_login.login_user(JWTUser(user), force=True)
        return redirect(request.args.get("next") or url_for("admin.index"))
    except AuthenticationError:
        flash("Invalid JWT")
        return redirect(url_for('airflow.noaccess'))

def decode_jwt(encoded_jwt):
    return jwt.decode(encoded_jwt, verify=False)

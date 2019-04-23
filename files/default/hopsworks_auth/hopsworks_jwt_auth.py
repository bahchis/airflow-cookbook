import sys
import requests
import flask_login
import jwt

from requests.auth import AuthBase

from flask_login import login_required, logout_user, current_user, UserMixin
from flask import flash, url_for, redirect, request, current_app

from airflow import models
from airflow import configuration
from airflow.configuration import AirflowConfigException
from airflow.utils.log.logging_mixin import LoggingMixin
from airflow.utils.db import provide_session

PY3 = sys.version_info[0] == 3

if PY3:
    from urllib import parse as urlparse
else:
    import urlparse
    
log = LoggingMixin().log

login_manager = flask_login.LoginManager()
login_manager.login_view = 'airflow.login'
login_manager.session_protection = "Strong"

JWT_SUBJECT_KEY = 'sub'
JWT_ROLES_KEY = 'roles'
JWT_ADMIN_ROLE = 'HOPS_ADMIN'

class AuthenticationError(Exception):
    pass

class JWTUser(models.User):
    def __init__(self, user):
        self.user = user
        log.debug("User is: {}".format(user))

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
        return self.user.is_superuser()

    def is_superuser(self):
        """Access all things"""
        return self.user.is_superuser()

    def get_id(self):
        return self.user.get_id()
    

@login_manager.user_loader
@provide_session
def load_user(user_id, session=None):
    if not user_id or user_id == 'None':
        return None
    log.debug("Loading user with id: {0}".format(user_id))
    user = session.query(models.User).filter(models.User.id == int(user_id)).first()
    return JWTUser(user)

def authenticate(jwt):
    hopsworks_host = configuration.conf.get("webserver", "hopsworks_host")
    hopsworks_port = configuration.conf.get("webserver", "hopsworks_port")
    if not hopsworks_port:
        hopsworks_port = 443
    url = "https://{host}:{port}/hopsworks-api/api/auth/jwt/session".format(
        host = parse_host(hopsworks_host),
        port = hopsworks_port)

    auth = AuthorizationToken(jwt)
    response = requests.get(url, auth=auth, verify=False)
    response.raise_for_status()
    if response.status_code != requests.codes.ok:
        raise AuthenticationError()

def parse_host(host):
    """
    Host should be just the hostname or ip address
    Remove protocol or any endpoints from the host
    """
    parsed_host = urlparse.urlparse(host).hostname
    if parsed_host:
        # Host contains protocol
        return parsed_host
    return host

@provide_session
def login(self, request, session=None):
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

        roles = decoded_jwt[JWT_ROLES_KEY]
        log.debug("User roles: {}".format(roles))
        
        if JWT_ADMIN_ROLE in roles:
            superuser = True
        else:
            superuser = False

        user = session.query(models.User).filter(
            models.User.username == username).first()

        if not user:
            user = models.User(username=username, is_superuser=superuser)
        else:
            user.superuser = superuser

        session.merge(user)
        session.commit()
        flask_login.login_user(JWTUser(user), force=True)
        session.commit()
        return redirect(request.args.get("next") or url_for("admin.index"))
    except AuthenticationError:
        flash("Invalid JWT")
        return redirect(url_for('airflow.noaccess'))

def decode_jwt(encoded_jwt):
    return jwt.decode(encoded_jwt, verify=False)

class AuthorizationToken(AuthBase):
    def __init__(self, token):
        self.token = token

    def __call__(self, request):
        request.headers['Authorization'] = self.token
        return request

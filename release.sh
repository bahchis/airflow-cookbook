#!/bin/bash


cb=$(grep "^name\s*" metadata.rb | perl -p -e 's/"//g' |  perl -p -e "s/name\s*//g")

echo "Releasing cookbook: $cb to Chef supermarket"
if [ $cb == "" ] ; then
 echo "Couldnt determine cookbook name. Exiting..."
fi

rm -f Berksfile.lock
rm -rf /tmp/cookbooks
berks vendor /tmp/cookbooks
cp metadata.rb /tmp/cookbooks/$cb/
knife cookbook site share $cb Applications


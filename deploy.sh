#!/bin/bash

# Usage: ./deploy.sh [host] [recipe]

host=${1}
recipe=${2}

if [[ -n ${recipe} ]] ; then
    echo '{
    "run_list": [ "recipe['${recipe}'::default]" ]
}
' > solo.json
fi


# The host key might change when we instantiate a new VM, so
# we remove (-R) the old host key from known_hosts
#ssh-keygen -R "${host#*@}" 2> /dev/null

tar hcj . | ssh "$host" '
sudo rm -rf ~/chef &&
mkdir ~/chef &&
cd ~/chef &&
tar xj &&
sudo bash install.sh'

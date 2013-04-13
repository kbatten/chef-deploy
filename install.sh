#!/bin/bash

# This runs as root on the server

#chef_binary=/var/lib/gems/1.9.1/bin/chef-solo
chef_binary=/var/lib/gems/1.9.1/gems/chef-11.4.0/bin/chef-solo

# Are we on a vanilla system?
if ! test -f "$chef_binary"; then
    export DEBIAN_FRONTEND=noninteractive
    # Upgrade headlessly (this is only safe-ish on vanilla systems)
    aptitude update &&
    apt-get -o Dpkg::Options::="--force-confnew" \
        --force-yes -fuy dist-upgrade &&
    # Install Ruby and Chef
    aptitude install -y ruby1.9.1 ruby1.9.1-dev make &&
    sudo gem1.9.1 install --no-rdoc --no-ri chef --version 11.4.0
    sudo gem1.9.1 install --no-rdoc --no-ri berkshelf
fi &&

recipe=${1}
if [[ -n ${recipe} ]] ; then
    pushd cookbooks/${recipe}
    berks install
    popd
    for cookbook_v in $(ls ~/.berkshelf/cookbooks/) ; do
        cookbook=$(echo ${cookbook_v} | sed 's/-[^-]*$//')
        ln -s ~/.berkshelf/cookbooks/${cookbook_v} cookbooks/${cookbook}
    done
fi

"$chef_binary" -c $(pwd)/solo.rb -j $(pwd)/solo.json

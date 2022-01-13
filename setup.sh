#! /bin/bash

export GIT_KICKSTART_URL=/vagrant
export INSTALL_LOC=/srv/kickstart
export SALT_FILE_ROOT=/srv/salt
export SALT_PILLAR_ROOT=/srv/pillar
export SALT_FORMULAR_ROOT=/srv/formulas
export SALT_ETC=/etc/salt

export GIT_SALT_FORMULA_URL=https://github.com/saltstack-formulas/salt-formula.git

echo "Salt master provision"


yum -y install git

git clone ${GIT_KICKSTART_URL} ${INSTALL_LOC}
ln -s ${INSTALL_LOC}/salt/roots ${SALT_FILE_ROOT}
ln -s ${INSTALL_LOC}/salt/pillar ${SALT_PILLAR_ROOT}

rpm --import https://repo.saltstack.com/yum/redhat/7/x86_64/latest/SALTSTACK-GPG-KEY.pub
\cp -f ${INSTALL_LOC}/salt-master/roots/salt/files/salt.repo /etc/yum.repos.d/saltstack.repo
yum -y install salt-master salt-minion

mkdir ${SALT_FORMULAR_ROOT}
git clone ${GIT_SALT_FORMULA_URL} ${SALT_FORMULAR_ROOT}/salt-formula

\cp -f ${INSTALL_LOC}/salt-master/minion-master ${SALT_ETC}/minion
echo "salt" > ${SALT_ETC}/autosign.conf

# Run the minion locally to bootstrap the salt master
salt-call --local state.apply

# Add the vagrant user to the adm group
# This will allow login to saltpad, if installed
# For reference, look at salt.sls pillar in master->external_auth
usermod vagrant -G 4 -a

echo "Will restart salt minion in 5 seconds..."
sleep 5
echo "Restarting salt minion"
\cp -f ${INSTALL_LOC}/salt/minion ${SALT_ETC}/minion
systemctl restart salt-minion
echo "Salt minion restarted"

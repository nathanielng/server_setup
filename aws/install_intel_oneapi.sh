#!/bin/bash

INSTALL_DIR="/shared/intel/oneapi/"

# Intel oneAPI Base Toolkit
if [ ! -e "l_BaseKit_p_2022.3.0.8767_offline.sh" ]; then
wget https://registrationcenter-download.intel.com/akdlm/irc_nas/18852/l_BaseKit_p_2022.3.0.8767_offline.sh
fi
sudo bash l_BaseKit_p_2022.3.0.8767_offline.sh -a --silent --eula accept --install-dir $INSTALL_DIR

# Intel oneAPI HPC Toolkit
if [ ! -e "l_HPCKit_p_2022.3.0.8751_offline.sh" ]; then
wget https://registrationcenter-download.intel.com/akdlm/irc_nas/18679/l_HPCKit_p_2022.3.0.8751_offline.sh
fi
sudo bash l_HPCKit_p_2022.3.0.8751_offline.sh -a --silent --eula accept --install-dir $INSTALL_DIR

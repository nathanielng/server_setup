#!/bin/bash

# Intel oneAPI Base Toolkit
if [ ! -e "l_BaseKit_p_2021.4.0.3422_offline.sh" ]; then
wget https://registrationcenter-download.intel.com/akdlm/irc_nas/18236/l_BaseKit_p_2021.4.0.3422_offline.sh
fi
sudo bash l_BaseKit_p_2021.4.0.3422_offline.sh -a --silent --eula accept --install-dir /fsx/intel/oneapi/

# Intel oneAPI HPC Toolkit
if [ ! -e "l_HPCKit_p_2021.4.0.3347_offline.sh" ]; then
wget https://registrationcenter-download.intel.com/akdlm/irc_nas/18211/l_HPCKit_p_2021.4.0.3347_offline.sh
fi
sudo bash l_HPCKit_p_2021.4.0.3347_offline.sh -a --silent --eula accept --install-dir /fsx/intel/oneapi/

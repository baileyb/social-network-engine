#!/usr/bin/env bash

# Update the system
apt-get update

# Install required packages
apt-get install -y git-core
apt-get install -y git

# Install RVM if required
if [ ! -e /usr/local/rvm/bin/rvm ]
	then
		echo "Installing RVM..."
		curl -L https://get.rvm.io | bash -s stable
		source /etc/profile.d/rvm.sh
		rvm autolibs enable
		rvm install 1.9.3-p385
fi

# Load RVM into the shell
source /etc/profile.d/rvm.sh

# Switch to the correct ruby version
rvm use 1.9.3-p385
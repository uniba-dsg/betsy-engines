betsy-engines
=============

This repository contains [Sprinkle](https://github.com/crafterm/sprinkle) configuration files for each WS-BPEL engine supported by *[BETSY](https://github.com/uniba-dsg/betsy)* as of April 2013:

* Active-BPEL
* Apache Ode
* bpel-g
* OpenESB
* Orchestra
* Petals ESB

The repository was created to support the extension of betsy to run the conformance tests in preinstalled virtual machines as part of a bachelor thesis.

## Sprinkle

* By default all '.rb' files in any directory below 'pa* ckages' are included into Sprinkle
* Version numbers can't be passed from a policy to a package, or from one package to another. They must be adjusted in the package itself

## Project Structure:

    files/     # All relevant scripts, tools, etc. which are needed for deployment
    packages/  # All packages with the detailed install instructions for the software
    Gemfile    # Includes all the gems needed to run Sprinkle v0.4.2


## How to create a new installation config file:

##### Create a new policy for the engine 'name_of_the_engine.rb'

```ruby
require File.join(File.dirname(__FILE__),'common.rb')

policy :name_of_the_engine_server, :roles => [:target_box] do
  requires :desired_package_1
  requires :desired_package_2
  requires :desired_package_3

  requires :server_config_name_of_the_engine

  # those packages are always needed!
  requires :betsy_vms
  requires :ntp
end

deploy
```

* The file shall include 'common.rb'!
* One of the required packages shall contain the actual engine installation routine

##### add an entry to the 'packages/server-config.rb' to change the hostname of virtual machine**

```bash
package :server_config_name_of_the_engine do
  requires :sed
  hostname = "betsy-name-of-the-engine"

  runner %Q{#{getSedChangeHostnameFunction(hostname)}}
  runner "hostname #{hostname}"
  runner %Q{#{getSedAppendHostnameFunction(hostname)}}
end
```

## How to install a server based on an existing setup:

__H:__
the host system on which sprinkle is installed and which guides the deployment process

__R:__
the virtual machine you want to deploy your configuration to

### 1) Prepare the host system

##### (H) Install Sprinkle and its dependencies

```bash
sudo apt-get install ruby ruby1.8 ruby1.8-dev libopenssl-ruby1.8 wget

# install rubygems from source
wget http://production.cf.rubygems.org/rubygems/rubygems-1.8.24.tgz
tar -xf rubygems-1.8.24.tgz
cd rubygems-1.8.24 && sudo ruby setup.rb && sudo ln -s /usr/bin/gem1.8 /usr/bin/gem

# install Sprinkle ifself
sudo gem install sprinkle
```

##### (H) Clone this git repository

```bash
$ git clone http://bitbucket.org/croeck/betsy-engines
```

### 2) Prepare the virtual machine

##### (R) Create a new virtual machine with the preferred linux operating system. All scripts in this repository are optimized for the use with 'Ubuntu Server 12.04.2 LTS'

##### (R) If not already done, create an admin user (user with sudo privileges)

##### (R - OPTIONAL) Install latest system updates

```bash
$ sudo apt-get update
$ sudo apt-get upgrade
```

##### (R) Install a SSH server, allow the login for the previously created admin user and make sure the SSH server is running

```bash
$ sudo apt-get install openssh-server
```

##### (R) Note the IP address of the virtual machine

### 3) Set final deployment details

##### (H) Adjust the settings of the virtual machine in 'deploy.rb'

```ruby
default_run_options[:pty] = true
set :user, 'SSH_USER_IN_SODOERS_FILE'
set :password, 'SSH_USERS_PASSWORD'
role :target_box, "192.168.0.2"
```

* In case the VM is using a NAT network adapter, redirect the port 22 of the host to port 22 of the VM and use 127.0.0.1 as IP of the target box

### 4) (H) Deploy the desired configuration

```bash
$ sprinkle -s name_of_the_engine.rb
```

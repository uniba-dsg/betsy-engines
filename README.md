betsy-engines
=============

This repository contains [Sprinkle](https://github.com/crafterm/sprinkle) configuration files for each BPEL engine supported by *[BETSY](https://github.com/uniba-dsg/betsy)*:

* Active BPEL
* Apache Ode
* BPEL-g
* OpenEBS
* Orchestra
* Petals BPEL SE

It was created in January 2013 to support the extension of Betsy to run the conformance tests in preinstalled virtual machines.

## Project Structure:

    files/     # All relevant scripts, tools, etc. which are needed for deployment
    packages/  # All packages with the detailed install instructions for the software
    Gemfile    # Includes all the gems needed to run Sprinkle


* By default all '.rb' files in any directory below 'packages' are included into Sprinkle
* Version numbers can't be passed from a policy to a package, or from one package to another. They must be adjusted in the package itself


## How to create a new server configuration file:

##### Create a new policy for the server 'name_of_the_engine.rb'

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

* The file must include 'common.rb'!

* One of the desired packages must contain the actual engine

##### add an entry to the 'packages/server-config.rb' to change the hostname of virtual machine**

```bash
package :server_config_name_of_the_engine do
  requires :sed
  hostname "betsy-name-of-the-engine"
  noop do
    pre :install, %Q{#{getSedChangeHostnameFunction(hostname)}}
    pre :install, "hostname #{hostname}"
    pre :install, %Q{#{getSedAppendHostnameFunction(hostname)}}
  end
end
```

## How to deploy a server based on an existing server configuration:

__L:__
the system on which sprinkle is installed and which starts the deployment process

__R:__
the virtual machine you want to deploy your configuration to

### 1) Prepare the local system

##### (L) Install Sprinkle and it's dependencies

```bash
sudo apt-get install ruby ruby1.8 ruby1.8-dev libopenssl-ruby1.8 wget

# install rubygems from source
wget http://production.cf.rubygems.org/rubygems/rubygems-1.8.24.tgz
tar -xf rubygems-1.8.24.tgz
cd rubygems-1.8.24 && sudo ruby setup.rb && sudo ln -s /usr/bin/gem1.8 /usr/bin/gem

# install Sprinkle ifself
sudo gem install sprinkle
```

##### (L) Clone this Git repository

```bash
$ git clone http://bitbucket.org/croeck/betsy-engines
```

##### (L) Make sure the submodules of this Git repository are initialized and include the latest changes

```bash
$ git submodule init
$ git submodule update
$ git merge origin/master
$ git submodule update
```

### 2) Prepare the virtual machine

##### (R) Create a new virtual machine with the preferred linux operating system. All scripts in this repository are optimized for the use with 'Ubuntu Server 12.04.1 LTS'

##### (R) If not already done, create an admin user (user with sudo privileges)

##### (R - OPTIONAL) Install latest system updates

```bash
$ sudo apt-get update
$ sudo apt-get upgrade
```

##### (R) Install a SSH server, allow the login for the new user and make sure the SSH server is running

```bash
$ sudo apt-get install openssh-server
```

##### (R) Note or set the ip address of the virtual machine

### 3) Set final deployment details

##### (L) Adjust the settings of the virtual machine in 'deploy.rb'

```ruby
default_run_options[:pty] = true
set :user, 'SSH_USER_IN_SODOERS_FILE'
set :password, 'SSH_USERS_PASSWORD'
role :target_box, "192.168.0.2"
```

### 4) (L) Deploy the desired configuration

```bash
$ sprinkle -s name_of_the_engine.rb
```

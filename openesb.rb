require File.join(File.dirname(__FILE__),'common.rb')

policy :openesb_server, :roles => [:target_box] do

  # The version must be set manually in the package
  requires :openesb
  # Set the hostname of the virtual machine
  requires :server_config_openesb
  # Allow time syncing
  requires :ntp
  # Betsy Virtual Machine Server
  requires :betsy_vms
end

deploy

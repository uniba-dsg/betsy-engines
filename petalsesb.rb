require File.join(File.dirname(__FILE__),'common.rb')

policy :petalsesb_server, :roles => [:target_box] do
  # The version must be set manually in the package
  requires :petalsesb
  # Set the hostname of the virtual machine
  requires :server_config_petalsesb
  # Allow time syncing
  requires :ntp
  # Betsy Virtual Machine Server
  requires :betsy_vms
end

deploy

require File.join(File.dirname(__FILE__),'common.rb')

policy :orchestra_server, :roles => [:target_box] do
  requires :tomcat7
  requires :tomcat7_admin

  # The version must be set manually in the package
  requires :orchestra
  # Set the hostname of the virtual machine
  requires :server_config_orchestra
  # Allow time syncing
  requires :ntp
  # Betsy Virtual Machine Server
  requires :betsy_vms
end

deploy

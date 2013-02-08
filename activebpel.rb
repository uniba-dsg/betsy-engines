require File.join(File.dirname(__FILE__),'common.rb')

policy :activebpel_server, :roles => [:target_box] do
  requires :tomcat5_5_36
  # The version must be set manually in the package
  requires :activebpel
  # Set the hostname of the virtual machine
  requires :server_config_activebpel
  # Allow time syncing
  requires :ntp
  # Betsy Virtual Machine Server
  requires :betsy_vms
end

deploy

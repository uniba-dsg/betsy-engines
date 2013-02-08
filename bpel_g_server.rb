require File.join(File.dirname(__FILE__),'common.rb')

policy :bpel_g_server, :roles => [:target_box] do
  requires :tomcat7
  # The version must be set manually in the package
  requires :bpel_g
  # Set the hostname of the virtual machine
  requires :server_config_bpel_g
  # Allow time syncing
  requires :ntp
  # Betsy Virtual Machine Server
  requires :betsy_vms
end

deploy

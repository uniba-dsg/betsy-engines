require File.join(File.dirname(__FILE__),'common.rb')

policy :ode_server, :roles => [:target_box] do
  requires :tomcat7
  requires :tomcat7_admin
  requires :apache_ode
  # Changes the hostname of the virtual machine
  requires :server_config_ode
  # Betsy Virtual Machine Server
  requires :betsy_vms
  # Allow time syncing
  requires :ntp
end

deploy

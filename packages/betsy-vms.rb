package :betsy_vms_bin do
  description "Copy the binaries for the service"

  # transfer binary file
  transfer "files/betsy-vms/betsy-vms.jar", "/tmp/betsy-vms.jar" do
    pre :install, "mkdir -p /opt/betsy"
    pre :install, "chmod -R 777 /opt/betsy/"
    post :install, "mv -f /tmp/betsy-vms.jar /opt/betsy/betsy-vms.jar"
    post :install, "chown root:root /opt/betsy/betsy-vms.jar"
  end

  # verify files exist
  verify do
    has_folder '/opt/betsy'
    has_file '/opt/betsy/betsy-vms.jar'
  end

end

package :betsy_vms_install do

  requires :betsy_vms_bin

  # transfer the service and adjust rights
  transfer "files/betsy-vms/betsy-vms", "/tmp/betsy-vms" do
    post :install, "mv /tmp/betsy-vms /etc/init.d/betsy-vms"
    post :install, "chmod 755 /etc/init.d/betsy-vms"
    post :install, "chmod +x /etc/init.d/betsy-vms"
    post :install, "chown root:root /etc/init.d/betsy-vms"
  end

  verify do
    has_file "/etc/init.d/betsy-vms"
  end

  noop do
    pre :install, 'update-rc.d betsy-vms defaults'
  end
  
end

package :betsy_vms do

  description "This package provides a server listening in port 10000. It allows the deployment of BPEL packages to a BPEL engine"

  requires :jsvc
  requires :jre
  requires :at
  requires :betsy_vms_install

  transfer "files/betsy-vms/start.sh", "/tmp/start.sh" do
    post :install, "mv /tmp/start.sh /opt/betsy/start.sh"
    post :install, "chmod +x /opt/betsy/start.sh"
    post :install, "chown root:root /opt/betsy/start.sh"
    post :install, "at now -f /opt/betsy/start.sh"
    # sleep to make sure betsy-vms has been started
    post :install, "sleep 3"
  end

  verify do
    has_file "/opt/betsy/start.sh"
    has_process "jsvc"
    #has_version_in_grep "service betsy-vms status", "betsy-vms is running"
    has_file "/var/run/betsy-vms.pid"
  end

end

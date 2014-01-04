package :betsy_vms_bin do
  description "Copy the binaries for the service"

  # transfer binary file
  transfer "files/betsy-vms/betsy-vms.jar", "/tmp/betsy-vms.jar" do
    pre :install, ["mkdir -p /opt/betsy/log", "mkdir -p /opt/betsy/tmp", "chmod -R 777 /opt/betsy/"]
    post :install, ["mv -f /tmp/betsy-vms.jar /opt/betsy/betsy-vms.jar", "chown root:root /opt/betsy/betsy-vms.jar"]
  end


  # verify files exist
  verify do
    has_directory '/opt/betsy'
    has_file '/opt/betsy/betsy-vms.jar'
  end

end

package :betsy_vms_install do

  requires :betsy_vms_bin

  # transfer the service and adjust rights
  transfer "files/betsy-vms/betsy-vms", "/tmp/betsy-vms" do
    post :install, ["mv /tmp/betsy-vms /etc/init.d/betsy-vms", "chmod 755 /etc/init.d/betsy-vms", "chmod +x /etc/init.d/betsy-vms", "chown root:root /etc/init.d/betsy-vms", "update-rc.d betsy-vms defaults"]
  end

  verify do
    has_file "/etc/init.d/betsy-vms"
  end

end

package :betsy_vms do

  description "This package provides a server listening in port 10000. It allows the deployment of BPEL packages to a BPEL engine"

  requires :jsvc
  requires :jre
  requires :at
  requires :betsy_vms_install

  transfer "files/betsy-vms/start.sh", "/tmp/start.sh" do
    post :install, ["mv /tmp/start.sh /opt/betsy/start.sh", "chmod +x /opt/betsy/start.sh", "chown root:root /opt/betsy/start.sh", "at now -f /opt/betsy/start.sh", "sleep 30"]
  end

  verify do
    has_file "/opt/betsy/start.sh"
    has_process "jsvc"
    has_file "/var/run/betsy-vms.pid"
  end

end

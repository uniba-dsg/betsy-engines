package :betsy_vms_bin do
  description "Copy the binaries for the service"

  # transfer binary file
  transfer "files/betsy-vms/betsy-vms.jar", "/tmp/betsy-vms.jar"
  runner "mkdir --parents /opt/betsy/log"
  runner "mkdir --parents /opt/betsy/tmp"
  runner "chmod -R 777 /opt/betsy/"
  runner "mv -f /tmp/betsy-vms.jar /opt/betsy/betsy-vms.jar"
  runner "chown root:root /opt/betsy/betsy-vms.jar"

  # verify files exist
  verify do
    has_directory '/opt/betsy'
    has_file '/opt/betsy/betsy-vms.jar'
  end

end

package :betsy_vms_install do

  requires :betsy_vms_bin

  # transfer the service and adjust rights
  transfer "files/betsy-vms/betsy-vms", "/tmp/betsy-vms"
  runner "mv -f /tmp/betsy-vms /etc/init.d/betsy-vms"
  runner "chmod 755 /etc/init.d/betsy-vms"
  runner "chmod +x /etc/init.d/betsy-vms"
  runner "chown root:root /etc/init.d/betsy-vms"

  runner 'update-rc.d betsy-vms defaults'

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

  transfer "files/betsy-vms/start.sh", "/tmp/start.sh"
  runner "mv /tmp/start.sh /opt/betsy/start.sh"
  runner "chmod +x /opt/betsy/start.sh"
  runner "chown root:root /opt/betsy/start.sh"
  runner "at now -f /opt/betsy/start.sh"
  # sleep to make sure betsy-vms has been started
  runner "sleep 3"

  verify do
    has_file "/opt/betsy/start.sh"
    has_process "jsvc"
    #has_version_in_grep "service betsy-vms status", "betsy-vms is running"
    has_file "/var/run/betsy-vms.pid"
  end

end

package :openesb_download do
  requires :wget
  version '2.2'

  runner "wget https://openesb-dev.org/file/download.php/102/3/p3_r2/glassfishesb-v2.2-full-installer-linux.sh"
  runner "mv glassfishesb-v#{version}-full-installer-linux.sh glassfishesb-full-installer-linux.sh"

  verify do
    has_file "glassfishesb-full-installer-linux.sh"
  end
end

package :openesb_statefile do

  transfer "files/openesb/linux.state.xml", "/tmp/linux.state.xml"
  runner "mkdir --parents /opt/openesb"
  runner "mv /tmp/linux.state.xml /opt/openesb/state.xml"

  verify do
    has_file "/opt/openesb/state.xml"
  end

end

package :openesb_install do
  requires :sed
  requires :jre
  requires :openesb_statefile
  requires :openesb_user
  requires :openesb_service

  runner "mkdir --parents /opt/openesb"
  runner "sed -i 's|@INSTALL_PATH@|/opt/openesb|g' /opt/openesb/state.xml"
  runner "sed -i 's|@JDK_LOCATION@|/usr/lib/jvm/java-7-openjdk-amd64|g' /opt/openesb/state.xml"
  runner "sed -i 's|@HTTP_PORT@|8383|g' /opt/openesb/state.xml"
  runner "sed -i 's|@HTTPS_PORT@|8384|g' /opt/openesb/state.xml"
  runner "chmod +x glassfishesb-full-installer-linux.sh"
  runner "sh glassfishesb-full-installer-linux.sh --silent --state /opt/openesb/state.xml"
  runner "chown --recursive glassfish:glassfish /opt/openesb/"
  runner "chmod -R 775 /opt/openesb/"

  verify do
    has_file "/opt/openesb/glassfish/bin/asadmin"
    has_directory "/opt/openesb/glassfish/bin"
  end
end

package :openesb_login do
  transfer "files/openesb/asadminpass", "/tmp/asadminpass"
  runner "mv /tmp/asadminpass /home/betsy/.asadminpass"

  verify do
    has_file "/home/betsy/.asadminpass"
  end
end

package :openesb_service do

  transfer "files/openesb/glassfish", "/tmp/glassfish"
  runner "mv /tmp/glassfish /etc/init.d/glassfish"
  runner "chmod 755 /etc/init.d/glassfish"
  runner "chmod +x /etc/init.d/glassfish"
  runner "chown root:root /etc/init.d/glassfish"
  runner "update-rc.d glassfish defaults"

  verify do
    has_file "/etc/init.d/glassfish"
  end

end

package :openesb_user do

  runner "groupadd glassfish -f"
  runner "adduser --home /home/glassfish --system --shell /bin/bash glassfish"

  verify do
    has_user "glassfish"
  end

end

package :openesb_start_file do

  transfer "files/openesb/start.sh", "/tmp/start.sh"
  runner "mv /tmp/start.sh /opt/openesb/start.sh"

  verify do
    has_file "/opt/openesb/start.sh"
  end

end

package :openesb_start do
  requires :openesb_install
  requires :openesb_service
  requires :openesb_start_file
  requires :at

  # will be executed each time the installer is executed. if domain is already running nothing will happen
  # runner "service glassfish start"
  runner "at now -f /opt/openesb/start.sh"

end

package :openesb do
  requires :jre
  requires :openesb_download
  requires :openesb_install
  requires :openesb_login
  requires :openesb_start
end

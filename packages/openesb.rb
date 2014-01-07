package :openesb_download do
  requires :wget
  version '2.2'

  runner [
    "wget --no-check-certificate https://svn.lspi.wiai.uni-bamberg.de/svn/betsy/glassfishesb-v2.2-full-installer-linux.sh",
    "mv glassfishesb-v#{version}-full-installer-linux.sh glassfishesb-full-installer-linux.sh"]

  verify do
    has_file "glassfishesb-full-installer-linux.sh"
  end
end

package :openesb_statefile do

  transfer "files/openesb/linux.state.xml", "/tmp/linux.state.xml" do
    pre :install, "mkdir --parents /opt/openesb"
    post :install, "mv /tmp/linux.state.xml /opt/openesb/state.xml"
  end

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

  runner [
    "mkdir --parents /opt/openesb",
    "sed -i 's|@INSTALL_PATH@|/opt/openesb|g' /opt/openesb/state.xml",
    "sed -i 's|@JDK_LOCATION@|/usr/lib/jvm/java-7-openjdk-amd64|g' /opt/openesb/state.xml",
    "sed -i 's|@HTTP_PORT@|8383|g' /opt/openesb/state.xml",
    "sed -i 's|@HTTPS_PORT@|8384|g' /opt/openesb/state.xml",
    "chmod +x glassfishesb-full-installer-linux.sh",
    "sh glassfishesb-full-installer-linux.sh --silent --state /opt/openesb/state.xml",
    "chown --recursive glassfish:glassfish /opt/openesb/",
    "chmod -R 775 /opt/openesb/"]

  verify do
    has_file "/opt/openesb/glassfish/bin/asadmin"
    has_directory "/opt/openesb/glassfish/bin"
  end
end

package :openesb_login do
  transfer "files/openesb/asadminpass", "/tmp/asadminpass" do
    post :install, "mv /tmp/asadminpass /home/betsy/.asadminpass"
  end

  verify do
    has_file "/home/betsy/.asadminpass"
  end
end

package :openesb_service do

  transfer "files/openesb/glassfish", "/tmp/glassfish" do
    post :install, [
      "mv /tmp/glassfish /etc/init.d/glassfish",
      "chmod 755 /etc/init.d/glassfish",
      "chmod +x /etc/init.d/glassfish",
      "chown root:root /etc/init.d/glassfish",
      "update-rc.d glassfish defaults"]
  end

  verify do
    has_file "/etc/init.d/glassfish"
  end

end

package :openesb_user do

  runner [
    "groupadd glassfish -f",
    "adduser --home /home/glassfish --system --shell /bin/bash glassfish"]

  verify do
    has_user "glassfish"
  end

end

package :openesb_start_file do

  transfer "files/openesb/start.sh", "/tmp/start.sh" do
    post :install, "mv /tmp/start.sh /opt/openesb/start.sh"
  end

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

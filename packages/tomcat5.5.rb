package :tomcat5_5_36 do
  requires :jre
  requires :jsvc
  requires :unzip
  requires :tomcat5_user
  requires :tomcat5_init
  requires :tomcat5_download

  runner "unzip -qq -o apache-tomcat-5.5.36.zip & wait $!" do
    pre :install, [
      "rm -R -f apache-tomcat-5.5.36",
      "rm -R -f /usr/share/tomcat5.5"]

    post :install, [
      "mv -f apache-tomcat-5.5.36 /usr/share/tomcat5.5",
      # Create folders
      "mkdir --parents /etc/tomcat5.5/policy.d",
      "mkdir --parents /var/log/tomcat5.5",
      "mkdir --parents /var/cache/tomcat5.5",
      # Make tomcat55 to owner, allows creation of folders, etc.
      "touch /etc/tomcat5.5/policy.d/default.policy",
      "touch /usr/share/tomcat5.5/logs/catalina.out",
      "chown --recursive tomcat55:tomcat55 /etc/tomcat5.5",
      "chown --recursive tomcat55:tomcat55 /usr/share/tomcat5.5",
      "chmod -R 755 /usr/share/tomcat5.5",
      "chown --recursive tomcat55:tomcat55 /var/log/tomcat5.5",
      "chmod -R 777 /var/log/tomcat5.5",
      "chown --recursive tomcat55:tomcat55 /var/cache/tomcat5.5",
      "chmod -R 777 /usr/share/tomcat5.5/logs"]
  end

  #workaround: tomcat won't start if called from sprinkle :/
  transfer "files/tomcat5.5/start.sh", "/tmp/start_tc.sh" do
    post :install, [
      "mv /tmp/start_tc.sh /usr/share/tomcat5.5/bin/restart.sh",
      "chmod +x /usr/share/tomcat5.5/bin/restart.sh",
      "chown root:root /usr/share/tomcat5.5/bin/restart.sh",
      "at now -f /usr/share/tomcat5.5/bin/restart.sh",
      "sleep 5"]
  end

  verify do
    has_directory '/usr/share/tomcat5.5'
    has_process 'java'
    has_file '/usr/share/tomcat5.5/temp/tomcat5.5.pid'
  end

end

package :tomcat5_download do

  runner "wget --no-check-certificate https://svn.lspi.wiai.uni-bamberg.de/svn/betsy/apache-tomcat-5.5.36.zip"

  verify do
    has_file "apache-tomcat-5.5.36.zip"
  end
end

package :tomcat5_init do
  transfer "files/tomcat5.5/tomcat5.5", "/tmp/tomcat5.5" do
    post :install, [
      "mv -f /tmp/tomcat5.5 /etc/init.d/tomcat5.5",
      "chmod 755 /etc/init.d/tomcat5.5",
      "chmod +x /etc/init.d/tomcat5.5",
      "chown root:root /etc/init.d/tomcat5.5",
      "update-rc.d tomcat5.5 defaults"]
end

  verify do
    has_file "/etc/init.d/tomcat5.5"
  end
end

package :tomcat5_user do
  runner "useradd -m -d /home/tomcat55 tomcat55"

  verify do
    has_user "tomcat55"
  end
end

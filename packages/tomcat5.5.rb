package :tomcat5_5_36 do
  requires :jre
  requires :jsvc
  requires :unzip
  requires :tomcat5_user
  requires :tomcat5_init
  requires :tomcat5_download

  noop do
    pre :install, "rm -R -f apache-tomcat-5.5.36"
    pre :install, "rm -R -f /usr/share/tomcat5.5"
    pre :install, "unzip apache-tomcat-5.5.36.zip"
    pre :install, "mv -f apache-tomcat-5.5.36 /usr/share/tomcat5.5"
    # Create folders
    post :install, "mkdir -p /etc/tomcat5.5/policy.d"
    post :install, "mkdir -p /var/log/tomcat5.5"
    post :install, "mkdir -p /var/cache/tomcat5.5"
    # Make tomcat55 to owner, allows creation of folders, etc.
    post :install, "touch /etc/tomcat5.5/policy.d/default.policy"
    post :install, "touch /usr/share/tomcat5.5/logs/catalina.out"
    post :install, "chown -R tomcat55:tomcat55 /etc/tomcat5.5"
    post :install, "chown -R tomcat55:tomcat55 /usr/share/tomcat5.5"
    post :install, "chmod -R 755 /usr/share/tomcat5.5"
    post :install, "chown -R tomcat55:tomcat55 /var/log/tomcat5.5"
    post :install, "chmod -R 777 /var/log/tomcat5.5"
    post :install, "chown -R tomcat55:tomcat55 /var/cache/tomcat5.5"
    post :install, "chmod -R 777 /usr/share/tomcat5.5/logs"
  end

  #workaround: tomcat won't start if called from sprinkle :/
  transfer "files/tomcat5.5/start.sh", "/tmp/start_tc.sh" do
    post :install, "mv /tmp/start_tc.sh /usr/share/tomcat5.5/bin/restart.sh"
    post :install, "chmod +x /usr/share/tomcat5.5/bin/restart.sh"
    post :install, "chown root:root /usr/share/tomcat5.5/bin/restart.sh"
    post :install, "at now -f /usr/share/tomcat5.5/bin/restart.sh"
    post :install, "sleep 5"
  end

  verify do
    has_folder '/usr/share/tomcat5.5'
    has_process 'java'
    has_file '/usr/share/tomcat5.5/temp/tomcat5.5.pid'
  end

end

package :tomcat5_download do
  noop do
    pre :install, "wget --no-check-certificate https://svn.lspi.wiai.uni-bamberg.de/svn/betsy/apache-tomcat-5.5.36.zip"
  end
  verify do
    has_file "apache-tomcat-5.5.36.zip"
  end
end

package :tomcat5_init do
  transfer "files/tomcat5.5/tomcat5.5", "/tmp/tomcat5.5" do
    post :install, "mv -f /tmp/tomcat5.5 /etc/init.d/tomcat5.5"
    post :install, "chmod 755 /etc/init.d/tomcat5.5"
    post :install, "chmod +x /etc/init.d/tomcat5.5"
    post :install, "chown root:root /etc/init.d/tomcat5.5"
    post :install, "update-rc.d tomcat5.5 defaults"
  end

  verify do
    has_file "/etc/init.d/tomcat5.5"
  end
end

package :tomcat5_user do
  noop do
    pre :install, "useradd -d /home/tomcat55 tomcat55"
  end
  verify do
    has_user "tomcat55"
  end
end

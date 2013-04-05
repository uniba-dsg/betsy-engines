package :tomcat7 do
  requires :apt_update
  requires :jre

  apt %w( tomcat7 )

  noop do
    # Make tomcat7 to owner, allows creation of folders, etc.
    post :install, "mkdir /var/lib/tomcat7/ext/"
    post :install, "chown -R tomcat7:tomcat7 /usr/share/tomcat7"
    post :install, "chown -R tomcat7:tomcat7 /var/lib/tomcat7"
    post :install, "service tomcat7 restart"
  end

  verify do
    has_folder '/var/lib/tomcat7'
    has_folder '/var/lib/tomcat7/ext'
    has_process 'java'
    has_file '/var/run/tomcat7.pid'
  end

end

package :tomcat7_admin do
  requires :apt_update
  apt %w( tomcat7-admin tomcat7-user )

  transfer "files/tomcat7/tomcat-users.xml", "/tmp/tomcat-users.xml" do
    post :install, %{mv -f /tmp/tomcat-users.xml /var/lib/tomcat7/conf/tomcat-users.xml}
    post :install, "/etc/init.d/tomcat7 restart"
    post :install, "sleep 2"
  end

  verify do
    has_file "/var/lib/tomcat7/conf/tomcat-users.xml"
    has_file "/var/run/tomcat7.pid"
    file_contains "/var/lib/tomcat7/conf/tomcat-users.xml", "CUSTOM USER CONFIG"
  end
end

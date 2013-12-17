package :tomcat7 do
  requires :apt_update
  requires :jre

  apt %w( tomcat7 )

  # Make tomcat7 to owner, allows creation of folders, etc.
  runner "mkdir --parents /var/lib/tomcat7/ext/"
  runner "chown --recursive tomcat7:tomcat7 /usr/share/tomcat7"
  runner "chown --recursive tomcat7:tomcat7 /var/lib/tomcat7"
  runner "service tomcat7 restart"

  verify do
    has_directory '/var/lib/tomcat7'
    has_directory '/var/lib/tomcat7/ext'
    has_process 'java'
    has_file '/var/run/tomcat7.pid'
  end

end

package :tomcat7_admin do
  requires :apt_update
  apt %w( tomcat7-admin tomcat7-user )

  transfer "files/tomcat7/tomcat-users.xml", "/tmp/tomcat-users.xml"
  runner %{mv -f /tmp/tomcat-users.xml /var/lib/tomcat7/conf/tomcat-users.xml}
  runner "/etc/init.d/tomcat7 restart"
  runner "sleep 2"

  verify do
    has_file "/var/lib/tomcat7/conf/tomcat-users.xml"
    has_file "/var/run/tomcat7.pid"
    file_contains "/var/lib/tomcat7/conf/tomcat-users.xml", "CUSTOM USER CONFIG"
  end
end

package :tomcat7_soapui_log do
  runner "touch /var/lib/tomcat7/soapui.log"
  runner "touch /var/lib/tomcat7/soapui-errors.log"

  verify do
    has_file "/var/lib/tomcat7/soapui.log"
    has_file "/var/lib/tomcat7/soapui-errors.log"
  end
end

package :tomcat7_soapui_symlink_log do
  requires :tomcat7_soapui_log

  runner "chown --recursive tomcat7:tomcat7 /var/lib/tomcat7/soapui.log"
  runner "chown --recursive tomcat7:tomcat7 /var/lib/tomcat7/soapui-errors.log"
  runner "ln /var/lib/tomcat7/soapui.log /var/lib/tomcat7/logs/soapui.log"
  runner "ln /var/lib/tomcat7/soapui-errors.log /var/lib/tomcat7/logs/soapui-errors.log"

  verify do
    has_file "/var/lib/tomcat7/logs/soapui.log"
    has_file "/var/lib/tomcat7/logs/soapui-errors.log"
  end
end

package :orchestra_download do
  requires :unzip
  requires :wget
  version "4.9.0"

  runner "wget https://svn.lspi.wiai.uni-bamberg.de/svn/betsy/orchestra-cxf-tomcat-#{version}.zip"
  runner "rm -R -f orchestra-cxf-tomcat-#{version}"
  runner "unzip orchestra-cxf-tomcat-#{version}.zip"
  runner "mv orchestra-cxf-tomcat-#{version} orchestra-cxf-tomcat"
  runner "rm orchestra-cxf-tomcat-#{version}.zip"

  verify do
    has_file "orchestra-cxf-tomcat/build.xml"
    has_file "orchestra-cxf-tomcat/common.xml"
    has_file "orchestra-cxf-tomcat/install.xml"
  end
end

package :orchestra_tomcat_params do
  requires :tomcat7

  transfer "files/orchestra/setenv.sh", "/tmp/setenv.sh"
  runner "mv -f /tmp/setenv.sh /usr/share/tomcat7/bin/setenv.sh"
  runner "chmod 755 /usr/share/tomcat7/bin/setenv.sh"
  runner "chown tomcat7:tomcat7 /usr/share/tomcat7/bin/setenv.sh"
  runner "service tomcat7 restart"
  runner "sleep 2"

  verify do
    has_file "/usr/share/tomcat7/bin/setenv.sh"
    has_file "/var/run/tomcat7.pid"
  end
end

package :orchestra_log_symlink do

  runner "touch /home/betsy/orchestra-cxf-tomcat/error.txt"
  runner "chown --recursive betsy:betsy orchestra-cxf-tomcat"
  runner "ln /home/betsy/orchestra-cxf-tomcat/error.txt /var/lib/tomcat7/logs/error.txt"
  runner "ln -s /usr/share/tomcat7/lib /var/lib/tomcat7/"

  verify do
    has_file "/var/lib/tomcat7/logs/error.txt"
    has_symlink "/var/lib/tomcat7/lib"
  end
end

package :orchestra do
  # does need tomcat to get deployed as .war file
  requires :tomcat7
  requires :unzip
  requires :ant
  requires :orchestra_download
  requires :orchestra_tomcat_params
  requires :orchestra_log_symlink
  requires :tomcat7_soapui_symlink_log


  runner "sed -i 's|catalina.home=[^ ]*|catalina.home=/var/lib/tomcat7|' orchestra-cxf-tomcat/conf/install.properties"
  runner "sed -i 's|catalina.base=[^ ]*|catalina.base=${catalina.home}|' orchestra-cxf-tomcat/conf/install.properties"
  runner "ant -f orchestra-cxf-tomcat/install.xml install"
  runner "chown tomcat7:tomcat7 /var/lib/tomcat7/webapps"
  runner "chmod -R 755 /var/lib/tomcat7/webapps"
  runner "service tomcat7 restart"

  verify do
   # verify orchestra got deployed
   has_directory '/var/lib/tomcat7/webapps/orchestra'
   has_directory '/var/lib/tomcat7/webapps/designer'
   has_directory '/var/lib/tomcat7/webapps/console'
   has_file '/var/lib/tomcat7/webapps/console/index.html'
   has_file "/var/run/tomcat7.pid"
  end

end

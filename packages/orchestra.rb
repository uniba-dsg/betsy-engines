package :orchestra_download do
  requires :unzip
  requires :wget
  version "4.9.0"

  runner "unzip -qq -o orchestra-cxf-tomcat-#{version}.zip & wait $!" do
    pre :install, [
      "wget --no-check-certificate https://svn.lspi.wiai.uni-bamberg.de/svn/betsy/orchestra-cxf-tomcat-#{version}.zip",
      "rm -R -f orchestra-cxf-tomcat-#{version}"]
    post :install, [
      "mv orchestra-cxf-tomcat-#{version} orchestra-cxf-tomcat",
      "rm orchestra-cxf-tomcat-#{version}.zip"]
  end

  verify do
    has_file "orchestra-cxf-tomcat/build.xml"
    has_file "orchestra-cxf-tomcat/common.xml"
    has_file "orchestra-cxf-tomcat/install.xml"
  end
end

package :orchestra_tomcat_params do
  requires :tomcat7

  transfer "files/orchestra/setenv.sh", "/tmp/setenv.sh" do
    post :install, [
      "mv -f /tmp/setenv.sh /usr/share/tomcat7/bin/setenv.sh",
      "chmod 755 /usr/share/tomcat7/bin/setenv.sh",
      "chown tomcat7:tomcat7 /usr/share/tomcat7/bin/setenv.sh",
      "service tomcat7 restart",
      "sleep 2"]
  end

  verify do
    has_file "/usr/share/tomcat7/bin/setenv.sh"
    has_file "/var/run/tomcat7.pid"
  end
end

package :orchestra_log_symlink do

  runner [
    "touch /home/betsy/orchestra-cxf-tomcat/error.txt",
    "chown --recursive betsy:betsy orchestra-cxf-tomcat",
    "ln /home/betsy/orchestra-cxf-tomcat/error.txt /var/lib/tomcat7/logs/error.txt",
    "ln -s /usr/share/tomcat7/lib /var/lib/tomcat7/"]

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


  runner [
    "sed -i 's|catalina.home=[^ ]*|catalina.home=/var/lib/tomcat7|' orchestra-cxf-tomcat/conf/install.properties",
    "sed -i 's|catalina.base=[^ ]*|catalina.base=${catalina.home}|' orchestra-cxf-tomcat/conf/install.properties",
    "ant -f orchestra-cxf-tomcat/install.xml install",
    "chown tomcat7:tomcat7 /var/lib/tomcat7/webapps",
    "chmod -R 755 /var/lib/tomcat7/webapps",
    "service tomcat7 restart"]

  verify do
   # verify orchestra got deployed
   has_directory '/var/lib/tomcat7/webapps/orchestra'
   has_directory '/var/lib/tomcat7/webapps/designer'
   has_directory '/var/lib/tomcat7/webapps/console'
   has_file '/var/lib/tomcat7/webapps/console/index.html'
   has_file "/var/run/tomcat7.pid"
  end

end

package :bpel_g do
  # does need tomcat to get deployed as .war file
  requires :tomcat7
  requires :bpel_g_deploy

  fpath = "/var/lib/tomcat7/webapps/bpel-g/WEB-INF/log4j.properties"

  # transfer the log4j.properties file into the already deployed bpel-g
  transfer "files/bpel-g/log4j.properties", "/tmp/bpelg_log4j.properties"

  runner "mv -f /tmp/bpelg_log4j.properties #{fpath}"
  runner "chown tomcat7:tomcat7 #{fpath}"
  runner "chmod 644 #{fpath}"

  # transfer script to wait until bpel-g has created the 'bpr' folder
  transfer "files/bpelg/wait.sh", "/tmp/wait.sh"
  runner "sh /tmp/wait.sh"
  runner "service tomcat7 restart"

  verify do
    has_file "/var/lib/tomcat7/webapps/bpel-g/WEB-INF/log4j.properties"
    has_file "/var/run/tomcat7.pid"
    has_directory "/usr/share/tomcat7/bpr"
  end

end

package :bpel_g_deploy do
  requires :bpel_g_tomcat_parameters
  requires :h2_tomcat_db
  requires :bpel_g_download
  requires :unzip

  runner "mkdir --parents /var/lib/tomcat7/webapps/bpel-g"
  runner "unzip ./bpel-g.war -d /var/lib/tomcat7/webapps/bpel-g"
  runner "chown --recursive tomcat7:tomcat7 /var/lib/tomcat7/webapps/bpel-g"

  verify do
   # verify bpel-g got deployed
   has_directory '/var/lib/tomcat7/webapps/bpel-g'
   has_file '/var/lib/tomcat7/webapps/bpel-g/index.html'
  end
end

package :bpel_g_download do
  requires :wget
  version "5.3"

  runner "wget https://svn.lspi.wiai.uni-bamberg.de/svn/betsy/bpel-g-#{version}.war"
  runner "mv bpel-g-#{version}.war bpel-g.war"

  verify do
    has_file "bpel-g.war"
  end
end

package :bpel_g_tomcat_parameters do
  requires :tomcat7

  # copy configuration files to the machine
  transfer "files/bpel-g/setenv.sh", "/tmp/setenv.sh"
  runner %{mv /tmp/setenv.sh /usr/share/tomcat7/bin/setenv.sh}

  # restart to load config files
  runner '/etc/init.d/tomcat7 restart'

  verify do
    has_file '/usr/share/tomcat7/bin/setenv.sh'
  end

end

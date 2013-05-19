package :bpel_g do
  # does need tomcat to get deployed as .war file
  requires :tomcat7
  requires :bpel_g_deploy

  fpath "/var/lib/tomcat7/webapps/bpel-g/WEB-INF/log4j.properties"

  # transfer the log4j.properties file into the already deployed bpel-g
  transfer "files/bpel-g/log4j.properties", "/tmp/bpelg_log4j.properties"

  noop do
    post :install, "mv -f /tmp/bpelg_log4j.properties #{fpath}"
    post :install, "chown tomcat7:tomcat7 #{fpath}"
    post :install, "chmod 644 #{fpath}"    
  end

  verify do
    has_file "/var/lib/tomcat7/webapps/bpel-g/WEB-INF/log4j.properties"
  end

  # transfer script to wait until bpel-g has created the 'bpr' folder 
  transfer "files/bpelg/wait.sh", "/tmp/wait.sh" do
    post :install, "sh /tmp/wait.sh"
    post :install, "service tomcat7 restart"
  end

  verify do
    has_file "/var/run/tomcat7.pid"
    has_folder "/usr/share/tomcat7/bpr"
  end
end

package :bpel_g_deploy do
  requires :bpel_g_tomcat_parameters
  requires :h2_tomcat_db
  requires :bpel_g_download
  requires :unzip

  noop do
    pre :install, "mkdir -p /var/lib/tomcat7/webapps/bpel-g"
    pre :install, "unzip ./bpel-g.war -d /var/lib/tomcat7/webapps/bpel-g"
    pre :install, "chown -R tomcat7:tomcat7 /var/lib/tomcat7/webapps/bpel-g"
  end

  verify do
   # verify bpel-g got deployed
   has_folder '/var/lib/tomcat7/webapps/bpel-g'
   has_file '/var/lib/tomcat7/webapps/bpel-g/index.html'
  end
end

package :bpel_g_download do
  requires :wget
  version "5.3"
  noop do
    pre :install, "wget --no-check-certificate https://svn.lspi.wiai.uni-bamberg.de/svn/betsy/bpel-g-#{version}.war"
    pre :install, "mv bpel-g-#{version}.war bpel-g.war"
  end
  verify do
    has_file "bpel-g.war"
  end
end

package :bpel_g_tomcat_parameters do
  requires :tomcat7

  # copy configuration files to the machine
  transfer "files/bpel-g/setenv.sh", "/tmp/setenv.sh" do
    post :install, %{mv /tmp/setenv.sh /usr/share/tomcat7/bin/setenv.sh}
  end

  verify do
    has_file '/usr/share/tomcat7/bin/setenv.sh'
  end

  # restart to load config files
  noop do
    post :install, '/etc/init.d/tomcat7 restart'
  end
end

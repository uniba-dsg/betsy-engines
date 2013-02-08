package :apache_ode_download do
  requires :unzip
  requires :wget
  version "1.3.5"
  noop do
    pre :install, "wget ftp://ftp.uni-erlangen.de/pub/mirrors/apache/ode/apache-ode-war-#{version}.zip"
    pre :install, "rm -R -f apache-ode-war"
    pre :install, "unzip apache-ode-war-#{version}.zip"
    pre :install, "mv apache-ode-war-#{version} apache-ode-war"
    post :install, "rm apache-ode-war-#{version}.zip"
  end
  verify do
    has_file "apache-ode-war/ode.war"
  end
end

package :apache_ode_dependencies do
  # does need tomcat to get deployed as .war file
  requires :tomcat7
  requires :apache_ode_download
end

package :apache_ode do
  requires :apache_ode_deploy

  fpath "/var/lib/tomcat7/webapps/ode/WEB-INF/classes/log4j.properties"

  # transfer the log4j.properties file into the already deployed Apache Ode
  transfer "files/betsy/src/main/resources/ode/log4j.properties", "/tmp/ode_log4j.properties"

  noop do
    post :install, "mv -f /tmp/ode_log4j.properties #{fpath}"
    post :install, "chown tomcat7:tomcat7 #{fpath}"
    post :install, "chmod 644 #{fpath}"    
  end

  verify do
    has_file "/var/lib/tomcat7/webapps/ode/WEB-INF/classes/log4j.properties"
  end

  noop do
    post :install, "service tomcat7 restart"
  end

  verify do
    has_file "/var/run/tomcat7.pid"
  end
end

package :apache_ode_deploy do
  requires :apache_ode_tomcat_params
  requires :apache_ode_dependencies
  requires :unzip

  noop do
    pre :install, "mkdir -p /var/lib/tomcat7/webapps/ode"
    pre :install, "unzip ./apache-ode-war/ode.war -d /var/lib/tomcat7/webapps/ode"
    pre :install, "chown -R tomcat7:tomcat7 /var/lib/tomcat7/webapps/ode"
  end

  verify do
   # verify ode got deployed
   has_file '/var/lib/tomcat7/webapps/ode/index.html'
  end
end

package :apache_ode_tomcat_params do
  requires :tomcat7

  # copy configuration files to the machine
  transfer "files/ode/setenv.sh", "/tmp/setenv.sh" do
    post :install, %{mv /tmp/setenv.sh /usr/share/tomcat7/bin/setenv.sh}
    post :install, '/etc/init.d/tomcat7 restart'
    post :install, "sleep 2"
  end

  verify do
    has_file '/usr/share/tomcat7/bin/setenv.sh'
    has_file "/var/run/tomcat7.pid"
  end

end


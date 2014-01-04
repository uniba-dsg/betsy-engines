package :apache_ode_download do
  requires :unzip
  requires :wget
  version "1.3.5"

  runner "unzip -qq -o apache-ode-war-#{version}.zip & wait $!" do
    pre :install, ["rm -R -f apache-ode-war", "wget --no-check-certificate https://lspi.wiai.uni-bamberg.de/svn/betsy/apache-ode-war-#{version}.zip"]
    post :install, ["mv apache-ode-war-#{version} apache-ode-war", "rm apache-ode-war-#{version}.zip"]
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

  fpath = "/var/lib/tomcat7/webapps/ode/WEB-INF/classes/log4j.properties"

  # transfer the log4j.properties file into the already deployed Apache Ode
  # TODO convert them from other system
  transfer "files/ode/log4j.properties", "/tmp/ode_log4j.properties"

  runner "mv -f /tmp/ode_log4j.properties #{fpath}"
  runner "chown tomcat7:tomcat7 #{fpath}"
  runner "chmod 644 #{fpath}"

  runner "service tomcat7 restart"

  verify do
    has_file "/var/lib/tomcat7/webapps/ode/WEB-INF/classes/log4j.properties"
    has_file "/var/run/tomcat7.pid"
  end

end

package :apache_ode_deploy do
  requires :apache_ode_tomcat_params
  requires :apache_ode_dependencies
  requires :unzip

  runner "unzip -qq -o apache-ode-war/ode.war -d /var/lib/tomcat7/webapps/ode & wait $!" do
    pre :install, ["mkdir --parents /var/lib/tomcat7/webapps/ode"]
    post :install, ["chown --recursive tomcat7:tomcat7 /var/lib/tomcat7/webapps/ode"]
  end

  verify do
   # verify ode got deployed
   has_file '/var/lib/tomcat7/webapps/ode/index.html'
  end
end

package :apache_ode_tomcat_params do
  requires :tomcat7

  # copy configuration files to the machine
  transfer "files/ode/setenv.sh", "/tmp/setenv.sh"
  runner %{mv /tmp/setenv.sh /usr/share/tomcat7/bin/setenv.sh}
  runner '/etc/init.d/tomcat7 restart'
  runner "sleep 2"

  verify do
    has_file '/usr/share/tomcat7/bin/setenv.sh'
    has_file "/var/run/tomcat7.pid"
  end

end


package :activebpel_download do
  requires :unzip
  requires :wget
  version "5.0.2"

  runner "wget https://svn.lspi.wiai.uni-bamberg.de/svn/betsy/activebpel-#{version}-bin.zip"
  runner "rm -R -f activebpel"
  runner "unzip activebpel-#{version}-bin.zip"
  runner "mv activebpel-#{version} activebpel"

  verify do
    has_file "activebpel/install.sh"
  end
end

package :activebpel_logsymlink do

  runner "mkdir --parents /home/tomcat55/AeBpelEngine/deployment-logs/"
  runner "touch /home/tomcat55/AeBpelEngine/deployment-logs/aeDeployment.log"
  runner "chown --recursive tomcat55:tomcat55 /home/tomcat55/AeBpelEngine/deployment-logs/aeDeployment.log"
  runner "chmod -R 755 /home/tomcat55/AeBpelEngine/deployment-logs/aeDeployment.log"
  runner "ln /home/tomcat55/AeBpelEngine/deployment-logs/aeDeployment.log /usr/share/tomcat5.5/logs/aeDeployment.log"

  verify do
    #has_symlink "/usr/share/tomcat5.5/logs/aeDeployment.log"
    has_file "/usr/share/tomcat5.5/logs/aeDeployment.log"
  end
end

package :activebpel do
  requires :tomcat5_5_36
  requires :activebpel_download
  requires :activebpel_tomcat_parameters
  requires :activebpel_install
  requires :activebpel_logsymlink

  runner "chown --recursive tomcat55:tomcat55 /usr/share/tomcat5.5/bpr/"
  runner "at now -f /usr/share/tomcat5.5/bin/restart.sh"

end

package :activebpel_install do

  runner "env CATALINA_HOME=/usr/share/tomcat5.5 sh activebpel/install.sh"

end

package :activebpel_tomcat_parameters do
  requires :tomcat5_5_36

  # copy configuration files to the machine
  transfer "files/activebpel/setenv.sh", "/tmp/setenv.sh"
  runner %{mv /tmp/setenv.sh /usr/share/tomcat5.5/bin/setenv.sh}
  runner "at now -f /usr/share/tomcat5.5/bin/restart.sh"

  verify do
    has_file '/usr/share/tomcat5.5/bin/setenv.sh'
    has_process "java"
    has_file "/usr/share/tomcat5.5/temp/tomcat5.5.pid"
  end
end

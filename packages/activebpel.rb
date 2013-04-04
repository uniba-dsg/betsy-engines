package :activebpel_download do
  requires :unzip
  requires :wget
  version "5.0.2"
  noop do
    pre :install, "wget --no-check-certificate https://svn.lspi.wiai.uni-bamberg.de/svn/betsy/activebpel-#{version}-bin.zip"
    pre :install, "rm -R -f activebpel"
    pre :install, "unzip activebpel-#{version}-bin.zip"
    pre :install, "mv activebpel-#{version} activebpel"
  end
  verify do
    has_file "activebpel/install.sh"
  end
end

package :activebpel_logsymlink do
  noop do
    pre :install, "ln -f -s /home/tomcat55/AeBpelEngine/deployment-logs/aeDeployment.log /usr/share/tomcat5.5/logs/aeDeployment.log"
  end

  verify do
    has_symlink "/usr/share/tomcat5.5/logs/aeDeployment.log"
  end
end

package :activebpel do
  requires :tomcat5_5_36
  requires :activebpel_download
  requires :activebpel_tomcat_parameters
  requires :activebpel_install
  requires :activebpel_logsymlink

  noop do
    pre :install, "chown -R tomcat55:tomcat55 /usr/share/tomcat5.5/bpr/"
    pre :install, "at now -f /usr/share/tomcat5.5/bin/restart.sh"
  end

end

package :activebpel_install do

  noop do
    pre :install, "env CATALINA_HOME=/usr/share/tomcat5.5 sh activebpel/install.sh"
  end

end

package :activebpel_tomcat_parameters do
  requires :tomcat5_5_36

  # copy configuration files to the machine
  transfer "files/activebpel/setenv.sh", "/tmp/setenv.sh" do
    post :install, %{mv /tmp/setenv.sh /usr/share/tomcat5.5/bin/setenv.sh}
    post :install, "at now -f /usr/share/tomcat5.5/bin/restart.sh"
  end

  verify do
    has_file '/usr/share/tomcat5.5/bin/setenv.sh'
    has_process "java"
    has_file "/usr/share/tomcat5.5/temp/tomcat5.5.pid"
  end
end

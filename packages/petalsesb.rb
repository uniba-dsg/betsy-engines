package :petalsesb_download do
  requires :unzip
  requires :wget
  requires :petalsesb_user
  version '4.0'

  runner "wget https://svn.lspi.wiai.uni-bamberg.de/svn/betsy/petals-esb-distrib-#{version}.zip"
  runner "mkdir --parents /opt/petalsesb"
  runner "rm -f -R petals-esb-distrib"
  runner "unzip petals-esb-distrib-#{version}.zip"
  runner "unzip petals-esb-distrib-#{version}/esb/petals-esb-#{version}.zip -d ./petalsesb"
  runner "mv -f petalsesb/petals-esb-#{version}/* /opt/petalsesb/"
  runner "mv -f petals-esb-distrib-#{version} petals-esb-distrib"
  runner "chown --recursive petals:petals /opt/petalsesb"
  # now remove large files
  runner "rm -R -f petalsesb"

  verify do
    has_directory "/opt/petalsesb/bin"
    has_file "/opt/petalsesb/bin/petals-launcher.jar"
  end

end

package :petalsesb_user do

  runner "useradd petals -d /home/petals -m"

  verify do
    has_user "petals"
  end

end

package :petalsesb_install_wait do

  transfer "files/petalsesb/wait.sh", "/tmp/petalsesb_wait.sh"
  runner "mv /tmp/petalsesb_wait.sh /opt/petalsesb/wait.sh"

  verify do
    has_file "/opt/petalsesb/wait.sh"
  end

end

package :petalsesb_start do
  requires :petalsesb_install_components
  requires :petalsesb_install_service
  requires :petalsesb_install_wait

  runner "service petals stop"
  runner "rm -f /opt/petalsesb/logs/petals.log"
	runner "touch /opt/petalsesb/logs/petals.log"
	runner "chown petals:petals /opt/petalsesb/logs/petals.log"
	runner "chmod 755 /opt/petalsesb/logs/petals.log"
	runner "sleep 10"
  runner "service petals start"
  runner "sh /opt/petalsesb/wait.sh"

end

package :petalsesb_install_components do
  requires :petalsesb_user
  requires :petalsesb_download

  runner "cp -f ./petals-esb-distrib/esb-components/petals-se-bpel-1.1.0.zip /opt/petalsesb/install"
  runner "cp -f ./petals-esb-distrib/esb-components/petals-bc-soap-4.1.0.zip /opt/petalsesb/install"
  # not required anymore, cleanup
  runner "rm -R -f petals-esb-distrib"

  verify do
    has_file "/opt/petalsesb/install/petals-se-bpel-1.1.0.zip"
    has_file "/opt/petalsesb/install/petals-bc-soap-4.1.0.zip"
  end

end

package :petalsesb_install_service do
  requires :petalsesb_user
  requires :petalsesb_download

  transfer "files/petalsesb/petals", "/tmp/petals"
  runner "mv /tmp/petals /etc/init.d/petals"
  runner "chmod 755 /etc/init.d/petals"
  runner "chmod +x /etc/init.d/petals"
  runner "chown root:root /etc/init.d/petals"
  runner "update-rc.d petals defaults"

  verify do
    has_file "/etc/init.d/petals"
  end

end

package :petalsesb do
  requires :jre
  requires :gawk
  requires :petalsesb_download
  requires :petalsesb_user
  requires :petalsesb_install_components
  requires :petalsesb_install_service
  requires :petalsesb_start
end

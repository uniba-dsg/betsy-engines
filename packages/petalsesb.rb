package :petalsesb_download do
  requires :unzip
  requires :wget
  requires :petalsesb_user
  version '4.0'

  noop do
    pre :install, "wget --no-check-certificate https://svn.lspi.wiai.uni-bamberg.de/svn/betsy/petals-esb-distrib-#{version}.zip"
    pre :install, "mkdir -p /opt/petalsesb"
    pre :install, "rm -f -R petals-esb-distrib"
    pre :install, "unzip petals-esb-distrib-#{version}.zip"
    pre :install, "unzip petals-esb-distrib-#{version}/esb/petals-esb-#{version}.zip -d ./petalsesb"
    pre :install, "mv -f petalsesb/petals-esb-#{version}/* /opt/petalsesb/"
    pre :install, "mv -f petals-esb-distrib-#{version} petals-esb-distrib"
    pre :install, "chown -R petals:petals /opt/petalsesb"
    # now remove large files
    post :install, "rm -R -f petalsesb"
  end

  verify do
    has_folder "/opt/petalsesb/bin"
    has_file "/opt/petalsesb/bin/petals-launcher.jar"
  end

end

package :petalsesb_user do

  noop do
    pre :install, "useradd petals -d /home/petals -m"
  end

  verify do
    has_user "petals"
  end

end

package :petalsesb_install_wait do

  transfer "files/petalsesb/wait.sh", "/tmp/petalsesb_wait.sh" do
    post :install, "mv /tmp/petalsesb_wait.sh /opt/petalsesb/wait.sh"
  end

  verify do
    has_file "/opt/petalsesb/wait.sh"
  end

end

package :petalsesb_start do
  requires :petalsesb_install_components
  requires :petalsesb_install_service
  requires :petalsesb_install_wait

  noop do
    pre :install, "service petals stop"
    pre :install, "rm -f /opt/petalsesb/logs/petals.log"
	pre :install, "touch /opt/petalsesb/logs/petals.log"
	pre :install, "chown petals:petals /opt/petalsesb/logs/petals.log"
	pre :install, "chmod 755 /opt/petalsesb/logs/petals.log"
	pre :install, "sleep 10"
    pre :install, "service petals start"
    post :install, "sh /opt/petalsesb/wait.sh"
  end

end

package :petalsesb_install_components do
  requires :petalsesb_user
  requires :petalsesb_download

  noop do
    pre :install, "cp -f ./petals-esb-distrib/esb-components/petals-se-bpel-1.1.0.zip /opt/petalsesb/install"
    pre :install, "cp -f ./petals-esb-distrib/esb-components/petals-bc-soap-4.1.0.zip /opt/petalsesb/install"
    # not required anymore, cleanup
    post :install, "rm -R -f petals-esb-distrib"
  end

  verify do
    has_file "/opt/petalsesb/install/petals-se-bpel-1.1.0.zip"
    has_file "/opt/petalsesb/install/petals-bc-soap-4.1.0.zip"
  end

end

package :petalsesb_install_service do
  requires :petalsesb_user
  requires :petalsesb_download

  transfer "files/petalsesb/petals", "/tmp/petals" do
    post :install, "mv /tmp/petals /etc/init.d/petals"
    post :install, "chmod 755 /etc/init.d/petals"
    post :install, "chmod +x /etc/init.d/petals"
    post :install, "chown root:root /etc/init.d/petals"
    post :install, "update-rc.d petals defaults"
  end

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

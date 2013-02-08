def getSedChangeHostnameFunction(hostname)
   return "sed -i 's/^.*$/#{hostname}/' /etc/hostname"
end

def getSedAppendHostnameFunction(hostname)
  return "sed -i '1i 127.0.0.1       #{hostname}' /etc/hosts"
end

package :server_config_ode do
  requires :sed
  hostname "betsy-apache-ode"
  noop do
    pre :install, %Q{#{getSedChangeHostnameFunction(hostname)}}
    pre :install, "hostname #{hostname}"
    pre :install, %Q{#{getSedAppendHostnameFunction(hostname)}}
  end
  verify do
    has_version_in_grep "cat /etc/hostname", hostname
    has_version_in_grep "cat /etc/hosts", hostname
  end
end

package :server_config_bpel_g do
  requires :sed
  hostname "betsy-bpel-g"
  noop do
    pre :install, %Q{#{getSedChangeHostnameFunction(hostname)}}
    pre :install, "hostname #{hostname}"
    pre :install, %Q{#{getSedAppendHostnameFunction(hostname)}}
  end
  verify do
    has_version_in_grep "cat /etc/hostname", hostname
    has_version_in_grep "cat /etc/hosts", hostname
  end
end

package :server_config_openesb do
  requires :sed
  hostname "betsy-openesb"
  noop do
    pre :install, %Q{#{getSedChangeHostnameFunction(hostname)}}
    pre :install, "hostname #{hostname}"
    pre :install, %Q{#{getSedAppendHostnameFunction(hostname)}}
  end
  verify do
    has_version_in_grep "cat /etc/hostname", hostname
    has_version_in_grep "cat /etc/hosts", hostname
  end
end

package :server_config_orchestra do
  requires :sed
  hostname "betsy-orchestra"
  noop do
    pre :install, %Q{#{getSedChangeHostnameFunction(hostname)}}
    pre :install, "hostname #{hostname}"
    pre :install, %Q{#{getSedAppendHostnameFunction(hostname)}}
  end
  verify do
    has_version_in_grep "cat /etc/hostname", hostname
    has_version_in_grep "cat /etc/hosts", hostname
  end
end

package :server_config_petalsesb do
  requires :sed
  hostname "betsy-petals-esb"
  noop do
    pre :install, %Q{#{getSedChangeHostnameFunction(hostname)}}
    pre :install, "hostname #{hostname}"
    pre :install, %Q{#{getSedAppendHostnameFunction(hostname)}}
  end
  verify do
    has_version_in_grep "cat /etc/hostname", hostname
    has_version_in_grep "cat /etc/hosts", hostname
  end
end

package :server_config_activebpel do
  requires :sed
  hostname "betsy-active-bpel"
  noop do
    pre :install, %Q{#{getSedChangeHostnameFunction(hostname)}}
    pre :install, "hostname #{hostname}"
    pre :install, %Q{#{getSedAppendHostnameFunction(hostname)}}
  end
  verify do
    has_version_in_grep "cat /etc/hostname", hostname
    has_version_in_grep "cat /etc/hosts", hostname
  end
end

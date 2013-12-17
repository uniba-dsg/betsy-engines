package :git do
  requires :apt_update
  apt 'git-core'
  verify do
    has_executable 'git'
  end
end

package :gawk do
  requires :apt_update
  apt 'gawk'
  verify do
    has_executable 'gawk'
  end
end

package :at do
  requires :apt_update
  apt 'at'
  verify do
    has_executable 'at'
  end
end

package :sed do
  requires :apt_update
  apt 'sed'
  verify do
    has_executable 'sed'
  end
end

package :wget do
  requires :apt_update
  apt 'wget'
  verify do
    has_executable 'wget'
  end
end

package :ntp do
  requires :apt_update
  apt 'ntp'
  verify do
    has_executable 'ntptrace'
  end
end

package :unzip do
  requires :apt_update
  apt 'unzip'
  verify do
    has_executable 'unzip'
  end
end

package :ant do
  requires :apt_update
  apt 'ant'
  verify do
    has_executable 'ant'
  end
end

package :apt_update do
  description 'Update the sources and upgrade the lists'

  runner 'apt-get update'
end

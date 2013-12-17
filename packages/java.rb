package :java_7_openjdk_amd64, :provides => :jre do
  requires :apt_update
  apt('openjdk-7-jdk')
  verify do
    has_executable 'java'
  end
end

package :java_home7, :provides => :java_home do
  requires :jre
  requires :sed

  java_home = "/usr/lib/jvm/java-7-openjdk-amd64"
  env = "/etc/environment"

  runner %Q{sed -i 's/\(PATH="[^"]*\)"$/\1:\/usr/lib/jvm/java-7-openjdk-amd64\/bin"/' #{env}}
  runner %Q{sed -i '$a JAVA_HOME=#{java_home}' #{env}}
  runner %Q{sed -i '$a export JAVA_HOME' #{env}}

  verify do
    file_contains env, "JAVA_HOME=#{java_home}"
  end

end

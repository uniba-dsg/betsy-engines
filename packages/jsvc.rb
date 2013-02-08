package :jsvc do

  description 'Java Service Wrapper to use Java Applications as Service'

  requires :java_7_openjdk_amd64
  requires :apt_update

  apt 'jsvc'
  
  verify do
    has_executable 'jsvc'
  end  

end

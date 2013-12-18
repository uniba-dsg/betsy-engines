require File.join(File.dirname(__FILE__),'common.rb')

policy :bvms_reinstall, :roles => [:target_box] do
  requires :betsy_vms
end

deploy
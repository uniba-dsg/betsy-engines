def getH2DBVersion()
   return "h2-1.2.122.jar"
end

package :h2_tomcat_db do
  description "Add missing h2 database to tomcat installation"

  # does need tomcat to deploy the .jar
  requires :tomcat7
  requires :h2_tomcat_db_download

  noop do
    # copy the .jar file to the tomcat lib directory
    pre :install, "cp ./#{getH2DBVersion()} /usr/share/tomcat7/lib/#{getH2DBVersion()}"
    pre :install, "chmod 777 /usr/share/tomcat7/lib/#{getH2DBVersion()}"
  end

  verify do
   # verify .jar has been copied into tomcat's lib dir
   has_file "/usr/share/tomcat7/lib/#{getH2DBVersion()}"
  end
end

package :h2_tomcat_db_download do
  requires :wget
  noop do
    pre :install, "wget --no-check-certificate https://svn.lspi.wiai.uni-bamberg.de/svn/betsy/#{getH2DBVersion()}"    
  end
  verify do
    has_file getH2DBVersion()
  end
end

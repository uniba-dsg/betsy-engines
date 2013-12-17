BETSY_HOME="../betsy"
BETSY_ENGINES_HOME=Dir.pwd

# uncomment this to enable "caching" ;-)
puts `cd #{BETSY_HOME} && gradlew jarServer && cp build/libs/betsy-vms.jar #{BETSY_ENGINES_HOME}/files/betsy-vms/betsy-vms.jar`

# Load all packages
Dir["#{File.dirname(__FILE__)}/packages/*.rb"].each do |f|
  require f
end

def deploy
  deployment do

    # mechanism for deployment
    delivery :capistrano do
      recipes 'deploy'
    end

    # source based package installer defaults
    source do
      prefix   '/usr/local'
      archives '/usr/local/sources'
      builds   '/usr/local/build'
    end

  end
end

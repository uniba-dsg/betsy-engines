#! /bin/sh
#
while : ; do
  [ -f "/var/lib/tomcat7/webapps/ode/WEB-INF/classes/log4j.properties" ] && break
  echo "file does not exist yet..."
  sleep 1
done
echo "File found!"

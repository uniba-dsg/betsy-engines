#! /bin/sh
#
while : ; do
  [ -d "/usr/share/tomcat7/bpr" ] && break
  echo "folder '/usr/share/tomcat7/bpr' does not exist yet..."
  sleep 2
done
echo "Folder found!"

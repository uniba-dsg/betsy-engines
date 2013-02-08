#! /bin/sh
#
while : ; do
  [ -f "/usr/share/tomcat7/bpr" ] && break
  echo "folder '/usr/share/tomcat7/bpr' does not exist yet..."
  sleep 1
done
echo "Folder found!"

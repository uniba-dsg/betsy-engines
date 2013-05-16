#! /bin/sh
#
sudo service petals restart

while : ; do
  grep -Fq "Component started" /opt/petalsesb/logs/petals.log && break
  echo "Petals ESB is not started yet..."
  sleep 1
done
sleep 5
echo "Petals ESB started!"

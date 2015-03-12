#!/bin/bash
# Source https://github.com/Lumida/packer/wiki/Building-Ubuntu-12.04-and-14.04-HVM-Instance-Store-AMIs
DEBIAN_FRONTEND=noninteractive
UCF_FORCE_CONFFNEW=true
export UCF_FORCE_CONFFNEW DEBIAN_FRONTEND

apt-get update
apt-get install -y ruby unzip runit fgetty kpartx gdisk
apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" dist-upgrade
apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" install ruby1.9.3
apt-get clean

# ec2-bundle-vol requires legacy grub and have to turn off the console
apt-get -y install grub
sed -i 's/console=hvc0/console=ttyS0/' /boot/grub/menu.lst
# kill uefi partition for 14.04 ami packaging
sed -i 's/LABEL=UEFI.*//' /etc/fstab

mkdir /var/tmp
cd /var/tmp
mkdir ami_tools java api_tools ec2
mkdir ec2/bin ec2/lib ec2/etc
export EC2_HOME=/var/tmp/ec2/bin
export JAVA_HOME=/var/tmp/java/jdk1.8.0_25/bin
export PATH=$PATH:$EC2_HOME:$JAVA_HOME

cd java
wget --no-check-certificate -c --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u40-b25/server-jre-8u40-linux-x64.tar.gz
tar -xzf server-jre-8u40-linux-x64.gz

cd ../ami_tools
wget http://s3.amazonaws.com/ec2-downloads/ec2-ami-tools.zip
sudo unzip ec2-ami-tools.zip

cd ../api_tools
wget http://s3.amazonaws.com/ec2-downloads/ec2-api-tools.zip
unzip ec2-api-tools.zip

cd ..
mv ami_tools/ec2-ami-tools*/bin/* api_tools/ec2-api-tools*/bin/* ec2/bin/
mv ami_tools/ec2-ami-tools*/lib/* api_tools/ec2-api-tools*/lib/* ec2/lib/
mv ami_tools/ec2-ami-tools*/etc/* api_tools/ec2-api-tools*/etc/* ec2/etc/

exit 0

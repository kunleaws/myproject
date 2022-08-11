#! /bin/bash

#LAMP Server Documentation: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/install-LAMP.html

#Update the server
sudo yum update -y

#Download package for LAMP Server
sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
sudo yum install -y httpd mariadb-server

#Start and Enable Apache
sudo systemctl enable httpd
sudo systemctl start httpd

#Add ec2-user to apache group
sudo usermod -a -G apache ec2-user

#Change /var/www directory ownership
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;

#Add group write permission
find /var/www -type f -exec sudo chmod 0664 {} \;

#Create a PHP file in Apache
echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php

#Change directory to /var/www/html
cd /var/www/html/

#Start and Enable Mariadb
sudo systemctl enable mariadb
sudo systemctl start mariadb

#rm /var/www/html/phpinfo.php

#Secure Mariadb
sudo mysql_secure_installation <<EOF

y
abcd1234!!
abcd1234!!
y
y
y
y
EOF

#Install phpMyAdmin
sudo yum install php-mbstring -y

#Restart Apache and php-fpm
sudo systemctl restart httpd
sudo systemctl restart php-fpm

cd /var/www/html

#Get latest phpmyadmin download from this link
sudo wget https://files.phpmyadmin.net/phpMyAdmin/5.2.0/phpMyAdmin-5.2.0-all-languages.tar.gz -P /var/www/html/
cd /var/www/html/ && sudo mkdir phpMyAdmin
sudo tar -xvzf phpMyAdmin-5.2.0-all-languages.tar.gz -C phpMyAdmin --strip-components 1

#Enable and start MariaDB
sudo systemctl enable mariadb
sudo systemctl start mariadb

#Install wordpress
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz

sudo systemctl restart mariadb

#Create Database, Database-User and Grant Permission
mysql -uroot -pabcd1234!! -e "CREATE DATABASE wordpress_db;"
mysql -uroot -pabcd1234!! -e "CREATE USER 'db_user'@'localhost' IDENTIFIED BY 'abcd1234!!';"
mysql -uroot -pabcd1234!! -e "GRANT ALL PRIVILEGES ON wordpress_db.* TO "db_user"@"localhost";"
mysql -uroot -pabcd1234!! -e "FLUSH PRIVILEGES;"

#Copy wp-config.php file
cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php

#Search and replace
sudo sed -i 's/database_name_here/wordpress_db/g' /var/www/html/wordpress/wp-config.php
sudo sed -i 's/username_here/db_user/g' /var/www/html/wordpress/wp-config.php
sudo sed -i 's/password_here/abcd1234!!/g' /var/www/html/wordpress/wp-config.php

#Comment certain line
#https://api.wordpress.org/secret-key/1.1/salt/
sudo sed -i '51,58 s/^/#/' /var/www/html/wordpress/wp-config.php

#Copy wordpress directory recursively to /var/www/html directory
sudo cp -r wordpress/* /var/www/html/

#Make blog directory uncer /var/www/html
#sudo mkdir /var/www/html/blog
#sudo cp -r wordpress/* /var/www/html/blog/

#Change AllowOverride None to AllowOverride All
sudo sed -i 's/AllowOverride None/AllowOverride All/g' /etc/httpd/conf/httpd.conf
sudo sed -i 's/AllowOverride none/AllowOverride All/g' /etc/httpd/conf/httpd.conf

#Set Permission for apache on /var/www
sudo chown -R apache /var/www
sudo chgrp -R apache /var/www
sudo chmod 2775 /var/www

find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;

#Restart Apache and MariaDB
sudo systemctl restart httpd
sudo systemctl restart mariadb

#Download wp-cli
sudo wget -P /var/www/html/ "https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar"
sudo wget -P /var/www/html/ "https://downloads.wordpress.org/theme/twentyseventeen.2.9.zip"
sudo unzip /var/www/html/twentyseventeen.2.9.zip
sudo chmod +x /var/www/html/wp-cli.phar
sudo mv /var/www/html/wp-cli.phar /usr/local/bin/wp
#wp theme activate twentyseventeen

#wp theme install twentyseventeen --activate
#secure your wordpress site (https://api.wordpress.org/secret-key/1.1/salt/)

#Enabling jemalloc for MySQL and restart MariaDB
sudo yum install jemalloc -y
sudo systemctl restart mariadb

##-- Format disk using fdisk utility
sudo fdisk /dev/xvdb<<EOF
n
p
1

+7G
w
EOF

sudo fdisk /dev/xvdc<<EOF
n
p
1

+7G
w
EOF

sudo fdisk /dev/xvdd<<EOF
n
p
1

+7G
w
EOF

sudo fdisk /dev/xvde<<EOF
n
p
1

+7G
w
EOF

sudo fdisk /dev/xvdf<<EOF
n
p
1

+7G
w
EOF

sudo fdisk /dev/xvdg<<EOF
n
p
1

+7G
w
EOF

##-- Make directory for filesystem
sudo mkdir /u01
sudo mkdir /u02
sudo mkdir /u03
sudo mkdir /u04
sudo mkdir /u05
sudo mkdir /backups

##--Create Physical Volume
sudo pvcreate /dev/xvdb1 
sudo pvcreate /dev/xvdc1 
sudo pvcreate /dev/xvdd1 
sudo pvcreate /dev/xvde1 
sudo pvcreate /dev/xvdf1
sudo pvcreate /dev/xvdg1

##-- Create Volume Group
sudo vgcreate stack_vg1 /dev/xvdb1 
sudo vgcreate stack_vg2 /dev/xvdc1 
sudo vgcreate stack_vg3 /dev/xvdd1 
sudo vgcreate stack_vg4 /dev/xvde1 
sudo vgcreate stack_vg5 /dev/xvdf1
sudo vgcreate stack_vg6 /dev/xvdg1

##-- Create Logical Volume
sudo lvcreate -n Lv_u01 -L 4G stack_vg1
sudo lvcreate -n Lv_u02 -L 4G stack_vg2
sudo lvcreate -n Lv_u03 -L 4G stack_vg3
sudo lvcreate -n Lv_u04 -L 4G stack_vg4
sudo lvcreate -n Lv_u05 -L 4G stack_vg5
sudo lvcreate -n Lv_backups -L 4G stack_vg6

##-- Make file system
sudo mkfs.ext4 /dev/stack_vg1/Lv_u01
sudo mkfs.ext4 /dev/stack_vg2/Lv_u02
sudo mkfs.ext4 /dev/stack_vg3/Lv_u03
sudo mkfs.ext4 /dev/stack_vg4/Lv_u04
sudo mkfs.ext4 /dev/stack_vg5/Lv_u05
sudo mkfs.ext4 /dev/stack_vg6/Lv_backups

##-- Mount the disks
sudo mount /dev/stack_vg1/Lv_u01 /u01
sudo mount /dev/stack_vg2/Lv_u02 /u02
sudo mount /dev/stack_vg3/Lv_u03 /u03
sudo mount /dev/stack_vg4/Lv_u04 /u04
sudo mount /dev/stack_vg5/Lv_u05 /u05
sudo mount /dev/stack_vg6/Lv_backups /backups

##-- Mount file system in fstab for data persistence
echo '/dev/mapper/stack_vg1-Lv_u01             /u01            ext4    defaults 0 0' | sudo tee -a /etc/fstab
echo '/dev/mapper/stack_vg2-Lv_u02             /u02            ext4    defaults 0 0' | sudo tee -a /etc/fstab
echo '/dev/mapper/stack_vg3-Lv_u03             /u03            ext4    defaults 0 0' | sudo tee -a /etc/fstab
echo '/dev/mapper/stack_vg4-Lv_u04             /u04            ext4    defaults 0 0' | sudo tee -a /etc/fstab
echo '/dev/mapper/stack_vg5-Lv_u05             /u05            ext4    defaults 0 0' | sudo tee -a /etc/fstab
echo '/dev//mapper/stack_vg6-Lv_backups        /backups        ext4    defaults 0 0' | sudo tee -a /etc/fstab

##-- Mount all
sudo mount -a

##-- Extend file system
#sudo lvextend -L +200M /dev/mapper/stack_vg1-lv_u01
#sudo lvextend -L +200M /dev/mapper/stack_vg2-lv_u02
#sudo lvextend -L +200M /dev/mapper/stack_vg3-lv_u03
#sudo lvextend -L +200M /dev/mapper/stack_vg4-lv_u04
#sudo lvextend -L +200M /dev/mapper/stack_vg5-lv_u05
#sudo lvextend -L +200M /dev/mapper/stack_vg6-Lv_backups

##-- Resize file system
#sudo resize2fs /dev/mapper/stack_vg1-Lv_u01
#sudo resize2fs /dev/mapper/stack_vg2-Lv_u02
#sudo resize2fs /dev/mapper/stack_vg3-Lv_u03
#sudo resize2fs /dev/mapper/stack_vg4-Lv_u04
#sudo resize2fs /dev/mapper/stack_vg5-Lv_u05
#sudo resize2fs /dev/mapper/stack_vg6-Lv_backups

## start FROM database.txt.sh first ^_^
## @ Apache Server

yum install mysql       >>      # mysql client side

firewall-cmd --add-service=mysql --permanent
firewall-cmd --reload

mysql -u iti -h 192.168.1.10 -p     >>      # to access database


## add index.html && submit.php to /var/www/html ##
## --------------------------------------------- ##


## now we should install php plugin

dnf module enable php
dnf install epel-release -y
dnf install https://rpms.remirepo.net/enterprise/remi-release-9.rpm
dnf module reset php
dnf module install php:remi-8.3 -y

## now we should install php-mysql module (VERY IMPORTANT!!)
yum install php-mysqlnd.x86_64


## SeLinux problem
setsebool -P httpd_can_network_connect_db on


systemctl restart httpd.service

## Test it, It should work now!

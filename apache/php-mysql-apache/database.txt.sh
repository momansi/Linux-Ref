## Start FROM here
## @ Database Server

yum install mysql-server

systemctl enable mysqld.service 
systemctl start mysqld.service 

firewall-cmd --add-service=mysql --permanent 
firewall-cmd --reload

mysql_secure_installation           >>      # configure root password

mysql -u root -p

    > create database iti;
    > use iti;
    > CREATE TABLE userinfo ( firstname VARCHAR(100) DEFAULT NULL, lastname VARCHAR(40) DEFAULT NULL, email VARCHAR(40) DEFAULT NULL ); 
    > show tables;
    > describe userinfo;
    > CREATE USER 'iti'@'%' IDENTIFIED BY 'P@sword2001';
    > GRANT INSERT, SELECT ON iti.* TO 'iti'@'%';
    > FLUSH PRIVILEGES;


## install apache

yum install httpd -y

systemctl enable httpd
systemctl start httpd

firewall-cmd --add-service=http --permanent
firewall-cmd --add-service=https --permanent
firewall-cmd --reload

## Important Directories

    /etc/httpd/conf/httpd.conf  >>          # main config. file
    /etc/httpd/conf.d/          >>          # Additional configs (virtual hosts, modules)
    /var/www/html/              >>          # Default website root


#-----------------------------------


## Change default document root from /var/www/html >> /mnt/websites (It isn't important to change ^_^)

vim /etc/httpd/conf/httpd.conf

    DocumentRoot "/mnt/websites"

    <Directory "/mnt/websites">
        AllowOverride None
        # Allow open access:
        Require all granted
    </Directory>

echo "Hello" >> /mnt/websites/index.html

semanage fcontext -a -t "httpd_sys_content_t" "/mnt/websites(/.*)?"
restorecon -Rv /mnt/websites

systemctl restart httpd


## Allowing write access to Document root (for developers! assume there are in developers group)

setfacl -R -m g:developers:rwX /var/www/html    >>    # X mean set execute permission for directories only
setfacl -d -m g:developers:rwx /var/www/html


#-----------------------------------


## Virtual Hosts (host more than one website with same ip - name-based hostname) 

# media.com website
touch /etc/httpd/conf.d/media.conf       >>      By default it included to main config. file
vim /etc/httpd/conf.d/media.conf

    <Directory "/var/www/media.com">
        AllowOverride None
        Require all granted
    </Directory>

    <VirtualHost *:80>
    ServerName media.com
    ServerAlias www.media.com
    ServerAdmin webmaster@media.com
    DocumentRoot /var/www/media.com
    ErrorLog /var/log/httpd/media.com-error.log
    CustomLog /var/log/httpd/media.com-access.log combined
    </VirtualHost>

# sales.com website
touch /etc/httpd/conf.d/sales.conf       >>      By default it included to main config. file
vim /etc/httpd/conf.d/sales.conf

    <Directory "/var/www/sales.com">
        AllowOverride None
        Require all granted
    </Directory>

    <VirtualHost *:80>
    ServerName sales.com
    ServerAlias www.sales.com
    ServerAdmin webmaster@sales.com
    DocumentRoot /var/www/sales.com
    ErrorLog /var/log/httpd/sales.com-error.log
    CustomLog /var/log/httpd/sales.com-access.log combined
    </VirtualHost>

# add test pages
mkdir -p /var/www/media.com
mkdir -p /var/www/sales.com
echo "Media Site" > /var/www/media.com/index.html
echo "Sales Site" > /var/www/sales.com/index.html


systemctl restart httpd

vim /etc/hosts
    $IP     www.media.com
    $IP     www.sales.com


#-----------------------------------


## Configure TLS certificate (Just for Lab!)

yum install openssl mod_ssl -y

mkdir -p /etc/ssl/private

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt

vim /etc/httpd/conf.d/media.conf
    <Directory "/var/www/media.com">
        AllowOverride None
        Require all granted
    </Directory>

    <VirtualHost *:443>
        SSLEngine on
        SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
        SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
        ServerName media.com
        ServerAlias www.media.com
        ServerAdmin webmaster@media.com
        DocumentRoot /var/www/media.com
        ErrorLog /var/log/httpd/media.com-error.log
        CustomLog /var/log/httpd/media.com-access.log combined
    </VirtualHost>

firewall-cmd --add-service=https --permanent
firewall-cmd --reload



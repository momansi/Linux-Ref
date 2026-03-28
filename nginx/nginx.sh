## install nginx

yum install nginx -y

systemctl enable nginx
systemctl start nginx

firewall-cmd --add-port=80/tcp --permanent
firewall-cmd --add-port=443/tcp --permanent
firewall-cmd --reload

## Important Directories

    /etc/nginx/nginx.conf       >>          # main config. file
    /etc/nginx/conf.d/          >>          # Additional configs (Server blocks)
    /usr/share/nginx/html       >>          # Default website root

#-----------------------------------

## Serve a basic web app

vim /etc/nginx/nginx.conf       >>          # Inside http block add a new server.
    
    server {
        listen 8080;
        root /var/www/nginx/site;     # Path that nginx will host from. 
    }

mkdir -p /var/www/nginx/site

echo "Hello from Nginx" > /var/www/nginx/site/index.html       # Test it from IP:8080

mkdir -p /var/www/nginx/site/bmw

echo "Hello from BMW" > /var/www/nginx/site/bmw/index.html     # Test it from IP:8080/bmw


#-----------------------------------

## Configure a web app with following details

mkdir /var/www/media.com
echo "Hello from Media!" > /var/www/media.com/index.html
echo "Error 404" > /var/www/media.com/404.html

chown -R nginx:nginx /var/www/media.com/

semanage fcontext -a -t httpd_sys_content_t "/var/www/media.com(/.*)?"
restorecon -Rv /var/www/media.com/

vim /etc/nginx/conf.d/media.com.conf
    server {
        listen 80;
        server_name media.com;
        root /var/www/media.com;
        index index.html;

        # custom error page

        error_page 404 /404.html;
        location = /404.html {
                root /var/www/media.com;
        }

        # redirect /oldpage to /newpage
        location /oldpage {
                rewrite ^/oldpage$ /newpage permanent;
        }
    }

# redirect from old url to new url ( old.com >> media.com )

vim /etc/nginx/conf.d/old.com.conf
    server {
            listen 80;
            server_name old.com;
            return 301 http://media.com$request_uri;
    }


systemctl reload nginx.service

vim /etc/hosts
    $IP     media.com old.com





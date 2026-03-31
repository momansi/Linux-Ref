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


#-----------------------------------


## Configure TLS certificate for Last Website and enforce https redirect

yum install openssl mod_ssl -y

mkdir /etc/nginx/ssl

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/media.com.key -out /etc/nginx/ssl/media.com.cert

vim /etc/nginx/conf.d/media.com.conf

    # redirect from http url to https url
    server {
        listen 80;
        server_name media.com www.media.com;
        return 301 https://$host$request_uri;
    }

    # https config.
    server {
        listen 443 ssl;
        server_name media.com www.media.com;

        ssl_certificate /etc/nginx/ssl/media.com.cert;
        ssl_certificate_key /etc/nginx/ssl/media.com.key;

        # enforce browsers to always use HTTPS for 1 year
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

        # allow only secure TLS versions
        ssl_protocols TLSv1.2 TLSv1.3;

        # configure strong cipher suites >> encryption algorithms
        ssl_prefer_server_ciphers on;
        ssl_ciphers HIGH:!aNULL:!MD5:!3DES;          # HIGH > strong encryption, !aNULL > disable anonymous auth, !MD5 > remove weak hash, !3DES > remove weak cipher

        # stronger Diffie-Hellman parameters (secure againest modern attcks)
        # 2048 b or 4096 b !! note: nginx use default DH 1024b 
        # you should generate it first by: openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048
        # ssl_dhparam /etc/nginx/ssl/dhparam.pem;    # uncomment for using it!

        root /var/www/media.com;
        index index.html;

        # custom error page

        error_page 404 /404.html;
        location = /404.html {
                root /var/www/media.com;
        }

        # redirect /old to /new
        location /oldpage {
                rewrite ^/oldpage$ /newpage permanent;
        }
    }


#-----------------------------------


## configure a load balancer using two backend machine and a reverse proxy machine

## first backend machine ip=192.168.1.5

mkdir -p  /var/www/backend1
echo "Hello from Backend1" > /var/www/backend1/index.html
cd /var/www/backend1/
python3 -m http.server 80 &     # turns the directory into a tiny web server for testing (simulate as a backend)
                                # last & to keep running in background
                                # we can change the port but we should open it on firewall !!!


## second backend machine ip=192.168.1.9

mkdir -p  /var/www/backend2
echo "Hello from Backend2" > /var/www/backend1/index.html
cd /var/www/backend2/
python3 -m http.server 80 &    


## reverse proxy machine

yum install openssl mod_ssl -y

mkdir /etc/nginx/ssl

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/lb.key -out /etc/nginx/ssl/lb.cert

vim /etc/nginx/conf.d/lb.conf

    # Define backend servers
    upstream backend_pool {
        server 192.168.1.5; 
        server 192.168.1.9;
      # server 192.168.1.9 weight=3;    # if we use this instead above >> this server will handle 3 req. than other backend server (it called weighted load balancing)
    }

    # allow https redirection
    server {
        listen 80;
        server_name 192.168.1.6;
        return 301 https://$host$request_uri;
    }

    # configure TLS and reverse proxy
    server {
        listen 443 ssl;
        server_name 192.168.1.6;

        ssl_certificate /etc/nginx/ssl/lb.cert;
        ssl_certificate_key /etc/nginx/ssl/lb.key;

        # enforce browsers to always use HTTPS for 1 year
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

        # allow only secure TLS versions
        ssl_protocols TLSv1.2 TLSv1.3;

        # configure strong cipher suites >> encryption algorithms
        ssl_prefer_server_ciphers on;
        ssl_ciphers HIGH:!aNULL:!MD5:!3DES;       

        location / {
            proxy_pass http://backend_pool;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }


nginx -t
systemctl reload nginx.service

curl -k https://192.168.1.6             # -k ignore self-signed certificate
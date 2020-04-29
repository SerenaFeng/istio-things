docker run -tid --name openresty --network host \
           -v /home/serena/study/istio-things/nginx.conf:/usr/local/openresty/nginx/conf/nginx.conf \
           serenafeng/openresty:latest

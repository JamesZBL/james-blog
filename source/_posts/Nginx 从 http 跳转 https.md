---
title: Nginx 从 http 跳转 https
date: 2018-04-15 20:30:53
categories:
    - 运维
tags:
    - Linux
    - Nginx
    - https
    - 域名
    - 运维
---
网站由 http 升级到 https， 原来的链接是不是就都失效了呢？其实旧链接依然可用，在 Nginx 中简单设置一下即可实现将 http 请求重定向到 https 地址。
<!-- more -->


```
server {
    listen 80;
    server_name example.com;
    rewrite ^(.*) https://$server_name$1 permanent;
}
server {
    listen 443 ssl;
    server_name example.com;
    ssl on;
    # 视具体情况而定
    ssl_certificate     /server/nginx/ssl/example.com.pem;
    ssl_certificate_key /server/nginx/ssl/example.com.key;
    ssl_session_timeout 5m;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;
    # location /{
        # ...
    # }
}
```

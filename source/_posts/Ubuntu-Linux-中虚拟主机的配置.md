---
title: Ubuntu Linux 中虚拟主机的配置 - 搭配 Nginx
date: 2018-04-14 20:30:53
categories:
    - 运维
tags:
    - Linux
    - Nginx
    - 虚拟主机
    - 域名
    - 运维
    - 架构
---

虚拟主机，正如其名，就是将一台服务器划分为多个虚拟的主机，可以将每个域名分配给不同的虚拟主机，这样可以充分利用了域名资源和硬件资源。这次我们采用 Nginx 实现虚拟主机的配置。

Nginx 是一款 free、开源的高性能 HTTP 服务器和反向代理服务器，同时可用作 IMAP、POP3、SMTP 服务器，它经常被用作 HTTP 服务器进行 Web 应用的部署使用，另外，Nginx 还经常以反向代理服务器的身份实现负载均衡。
<!-- more -->

使用 Nginx 配置虚拟主机只需编辑 Nginx 安装目录下 conf/nginx.conf 即可，增加一个虚拟主机只需要在配置文件中添加一个 server 节点，就像这样：

```
server {
    listen 80;
    server_name test1.example.com;

    location / {
        index index.html;
        root /home/www/test1/;
    }
}

server {
    listen 80;
    server_name test2.example.com;

    location / {
        index index.html;
        root /home/www/test2/;
    }
}
```

`listen` 为监听的端口，本例中监听 80 端口
`server_name` 即指定的虚拟主机名
`location` 只 Nginx 代理的相对 URL 范围
`index` 指主页的文件名
`root` 为网站根目录在系统中的实际位置

`location /` 表示匹配这个主机名下的所有请求，`server_name` 的值可以为 `*.example.com` 这种形式，即匹配所有以 `example.com` 结尾的主机名，亦或 `test.*`，即所有以 `test` 开头的主机名，还可以用正则表达式的形式，比如 `~^test\d+\.example\.com$`，如果使用正则表达式，最前面要加上 `~` 这个符号。

以上两个虚拟主机实现了将对不同主机名的请求指向不同的物理目录，下面介绍如何用虚拟主机实现区分端口，即将不同主机名的请求分发到不同端口上

和上面的配置写法类似：
```
server {
    listen 80;
    server_name demo1.example.com;

    location / {
        proxy_pass http://127.0.0.1:8080;
    }
}

server {
    listen 80;
    server_name demo2.example.com;

    location / {
        proxy_pass http://127.0.0.1:8081;
    }
}
```

proxy_pass 表示将请求转发到某个 URL，这样便可以实现虚拟主机名和端口的映射了。如果采用一台物理机部署多个 Tocmat 服务实例则可以采用这种方式，这样就避免了暴露多个端口的问题。

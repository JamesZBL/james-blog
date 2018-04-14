---
title: Nginx 解决浏览器 Ajax 跨域问题
date: 2018-04-14 22:52:21
categories:
    - 后端
tags:
    - 服务器
    - 架构
    - Nginx
    - Ajax
    - 跨域
    - CORS
---

跨域是指 host 为 A 页面中的 Ajax 发起指向 host B 的请求，只要 A 和 B 的协议、域名、端口、子域名其中任何一项不同，则执行的访问都会被认为是跨域的请求，几乎所有的浏览器为了安全等问题，对跨域访问做了限制，也就是无法通过浏览器发起跨域请求。跨域问题的本质是浏览器的限制。但也并不意味着浏览器根本不能发出任何跨域请求，在发起跨域请求后，浏览器总会发送一个 OPTION 请求，并根据响应的 Header 中 `Access-Control-Allow-Origin` 参数值进行下一步操作，如果这个参数不存在或不符合当前的域，则拒绝这个跨域请求。解决这个问题的一个简单方法就是使用 Nginx 反向代理。
<!-- more -->


# 场景示例


现在假设在同一台主机上部署有两个网站，访问地址分别为 `localhost:8080`（A） 和 ` localhost:8081`（B）， A 站的某个页面 Ajax 想要访问 B 的某个接口，以 jQuery 的 Ajax 为例：

```javascript
$.get(
    "http://localhost:8081/api/orders",
    {},
    function (result) {
    // ...
});
```

显然，在没有做任何其他配置的情况下，这个请求一定会发送失败。



# Nginx 反向代理

修改 Nginx 安装目录下 conf/nginx.conf 文件，添加如下内容：

```
server {
    listen  80;
    server_name  localhost;

    location /{
        proxy_pass http://localhost:8080
    }

    # 所有跨域访问以 /api 开头
    location /api {
        # 请求改写
		rewrite  ^/api/(.*)$ /$1 break;
		proxy_pass   http://localhost:8081;
   }
}
```

- 这样配置并启动 Nginx 之后，可以通过 `localhost` 的 `80` 端口 访问 `8080`和 `8081` 端口的网站
- 所有以 `/api` 开头的请求将被重写，然后被发送给 `8081` 端口
- 对请求的重写为正则式的形式： `^/api/(.*)$ /$1 break;` `$1` 表示匹配正则表达式中的第一个分组，也就是 `(.*)` 匹配的内容，将其改写为 `/匹配内容`，比如 `/api/abc/def/ghi` 将被改写为 `/abc/def/ghi`， `break` 表示一次匹配成功则结束。


# URL 更改


原来 Ajax 请求中所有指向 `localhost:8081/***` 的请求现在都应该改成 `localhost/api/***`，比如这样：

```javascript
$.get(
    "http://localhost/api/orders",
    {},
    function (result) {
    // ...
});
```

# 其他方案

CORS （跨域资源共享），需要设置服务端响应头中 `Access-Control-Allow-Origin` 参数。

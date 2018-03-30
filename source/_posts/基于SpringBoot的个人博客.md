---
title: 基于 Spring Boot 的个人博客
date: 2018-03-29 22:14:57
categories:
    - 开源项目
tags:
    - Spring Boot
    - Spring
    - MyBatis
    - BootStrap
    - 个人博客
---

[在线 Demo：http://fsblog.letec.top](http://fsblog.letec.top)
[Github 地址：https://github.com/jameszbl/fs-blog](https://github.com/jameszbl/fs-blog)
## 1. 涉及技术及工具
- 核心框架：SpringBoot
- ORM 框架：MyBatis
- MyBatis 工具：MyBatis Mapper
- MVC 框架：Spring MVC
- 模板引擎：Freemarker
- 编译辅助插件：Lombok
- CSS 框架：BootStrap 4.0
- Markdown 编辑器：Editor.md
- 数据库：MySQL
<!--more-->
## 2. 效果图
### 2.1 首页
![首页](https://upload-images.jianshu.io/upload_images/7134080-9314125f0eba4b91.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
#### 2.2 博客列表页
![博客列表页](https://upload-images.jianshu.io/upload_images/7134080-5bc39b987193939f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
### 2.3 博客阅读页
![博客阅读](https://upload-images.jianshu.io/upload_images/7134080-7f49df2f61559bcb.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
#### 2.4 个人简历页
![个人简历](https://upload-images.jianshu.io/upload_images/7134080-188d16150bfc2019.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
#### 2.5 文章编辑
![文章编辑](https://upload-images.jianshu.io/upload_images/7134080-05a4df2254471c7e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
### 3. 构建及运行
### 3.1 服务器环境
- 安装 ``MySQL``
- 安装 ``Gradle``
- 在项目目录下运行 ``gradle clean build``，生成的 jar 包位于 ``build/libs`` 目录下，使用 ``java -jar .../fsblog.jar`` 运行
- 在 ``application-dev.yml`` 中配置数据库用户名和密码，默认为：``username: root password: root``
- 默认自动创建数据库、数据表并自动导入初始数据，同样在``application-dev.yml``中配置
### 3.2 开发环境
- 可直接在 IntelliJ IDEA 或 Eclipse 中打开项目进行二次开发
## 4. 配置文件
```yml
spring:
  # 应用名称
  application:
    name: FS-Blog
  # 缓存
  cache:
    cache-names: ehcache
    ehcache:
      # 缓存的配置文件
      config: ehcache.xml
  # Spring Boot 热部署工具
  devtools:
    restart:
      enabled: true
  # 模板引擎
  freemarker:
    enabled: true
    cache: false
    suffix: .ftl
    charset: utf-8
    # 逻辑视图名（所有视图都要写在这里）
    view-names: index,
                error,
                userlogin,
                adminlogin,
                register,
                article,
                posts,
                admin/index,
                admin/userlogin,
                admin/blogadd,
                admin/blog_manage,
                admin/blog_modify,
                admin/admin_user_manage,
                admin/admin_user_pwd_modify
    content-type: text/html
    allow-request-override: true
    check-template-location: true
    expose-request-attributes: true
    expose-session-attributes: true
    expose-spring-macro-helpers: true
    request-context-attribute: request
    template-loader-path: classpath:/templates/
  # 静态资源
  resources:
    chain:
      strategy:
        content:
          enabled: true
          # 静态资源位置
          paths: /**
        fixed:
          enabled: true
          paths: /js/lib
          version: v12
    static-locations: classpath:/static/,classpath:/META-INF/resources/,classpath:/resources/,classpath:/public/
  # 数据源
  datasource:
    type: com.zaxxer.hikari.HikariDataSource
    # 数据库连接
    # 用户名
    username: root
    # 密码
    password: root
    # 数据库 URL
    url: jdbc:mysql://127.0.0.1:3306?useUnicode:true&amp;characterEncoding:UTF-8
    # 数据库连接驱动
    driverClassName: com.mysql.jdbc.Driver
    # SQL 编码
    sql-script-encoding: UTF-8
    hikari:
      # 连接存活时间
      connection-timeout: 30000
      # 连接池容量
      maximum-pool-size: 50
      minimum-idle: 5
    # 数据库定义
    schema: classpath:schema.sql
    # 测试数据
    data: classpath:data.sql
    # 是否自动创建数据库并自动导入初始数据
    initialize: true
    continue-on-error: true
# 服务器配置
server:
  # 端口
  port: 8083
  max-http-header-size: 8192
  compression:
      min-response-size: 512
      enabled: true
      mime-types: text/html,text/css,text/javascript,application/javascript,image/gif,image/png,image/jpg
  tomcat:
        maxThreads: 12
        minSpareThreads: 3
        # 访问日志
        accesslog:
          directory: /home/fullstack/app/fullstack
          pattern: combined
          enabled: true
# 会话
  session:
    cookie:
      # Session 存活时间
      max-age: 1800
# 日志
logging:
    # Log4j2 配置文件
    config: classpath:log4j2.xml
mybatis:
    # 实体类所在包
    type-aliases-package: me.zbl.fullstack.entity
    # xml 文件位置
    mapper-locations: classpath:mapping/*.xml
```
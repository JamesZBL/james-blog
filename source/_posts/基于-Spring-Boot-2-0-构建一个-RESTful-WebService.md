---
title: 基于 Spring Boot 2.0 构建一个 RESTful WebService
date: 2018-04-16 13:12:45
categories: 后端
tags:
    - Spring
    - Spring Boot
    - RESTful
    - Spring MVC
---

![](https://upload-images.jianshu.io/upload_images/7134080-edebba8af60420c9.gif?imageMogr2/auto-orient/strip)

REST 全称是 Representational State Transfer，中文意思是“表述性状态转移”。RESTful 是关于 Web 的现有特征和使用方式的一些准则和约束。 基于 Spring MVC 的 RestController，我们可以方便的构建一个 RESTful 风格的应用。

<!-- more -->

# 使用 Maven 创建项目



我们可以直接使用 **IntelliJ IDEA** （推荐）中的 **Spring initializer** 快速创建一个基于 **Spring Boot** 的项目，这里使用 **Maven** 构建， `pom.xml` 文件如下：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>org.springframework</groupId>
    <artifactId>gs-rest-service</artifactId>
    <version>0.1.0</version>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.0.1.RELEASE</version>
    </parent>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>com.jayway.jsonpath</groupId>
            <artifactId>json-path</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <properties>
        <java.version>1.8</java.version>
    </properties>


    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>

    <repositories>
        <repository>
            <id>spring-releases</id>
            <url>https://repo.spring.io/libs-release</url>
        </repository>
    </repositories>
    <pluginRepositories>
        <pluginRepository>
            <id>spring-releases</id>
            <url>https://repo.spring.io/libs-release</url>
        </pluginRepository>
    </pluginRepositories>
</project>
```

`Spring Maven plugin` 是 Spring 针对 Maven 开发的一套插件，包含了几个强大的功能：
- 无需过多复杂的配置即可**快速构建**一个可执行的 jar 包，使应用的运行可以几乎不受环境的影响
- 自动搜索 `public static void main()` 方法，并将其所在的类标志为**启动类**
- 对 Spring Boot 的依赖进行自动化管理，所有的依赖项目版本都和 Spring Boot 父项目保持一致（默认情况下），当然也可以手动指定其他版本

Spring 同样支持 `Gradle` 构建，详细配置请参考 [Build with Gradle][7dc5ba20]



# 创建实体类



这里的实体类并非 **ORM** 中的实体类，而是 REST 中的 “资源” ，我们的 web service 要实现的功能是处理 URL 为 `/userinfo/1` 的 `GET` 请求，并将结果以 **JSON** 作为响应体返回，响应状态码为 `200 OK`，JSON 的格式如下：

```javascript
{
    "id": 1,
    "name": "张三"
}
```

这个例子简单模拟了获取 id 为 1 的用户信息，首先要创建 POJO 类 `User`：

```java
public class User {

    private final long id;
    private final String name;

    public User(long id, String name) {
        this.id = id;
        this.name = name;
    }

    public long getId() {
        return id;
    }

    public String getName() {
        return name;
    }
}
```

    Spring 默认使用 `Jackson` 作为 JSON 解析库将 POJO 类对象序列化为 JSON。



# 创建 Controller



在 controller 类上添加 `@RestController` 注解即可实现将返回值序列化为 JSON 并充当响应体返回，返回的 `content-type` 为 `application/json`，请求 `/user/1` 将得 id 为 1 的用户的信息，下面是 controller 类：

```java
@RestController
public class GreetingController {

    private static final String template = "张三";
    private final long id = 1;

    @RequestMapping("/user/{id}")
    public User userInfo(@PathVariable("id")long id) {
        return new User(id, template);
    }
}
```



# 让应用跑起来



传统的构建方式是生成一个 war 文件然后部署到 web 服务器上，这样有时会觉得不太方便，因此推荐使用 Spring Boot 的 Maven 插件快速生成一个独立的可执行的 jar 文件，使用 `java -jar` 命令即可启动这个应用，所有的类和资源等文件都被集成到这一个 jar 文件中，里面也包括了**嵌入式**的 servlet 容器（比如 Tomcat），下面是这个应用的启动类：

```java
@SpringBootApplication
public class Application {

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

`@SpringBootApplication` 这个注解是一个组合注解，它包括：
- `@Configuration`：声明这个类是上下文中的 bean 的配置类
- `@EnableAutoConfiguration`：使 Spring 将上下文中扫描到的相关 bean 配置类或 properties 类，并将这些 bean 放到应用上下文中
- Spring 当检测到 classpath 下有 spring-webmvc 的依赖后，会自动给应用启动类上添加 `@EnableWebMvc` 的注解，它表示这个应用是一个 web 应用，应用启动时就会执行和 web 相关的操作，比如实例化 `DispatcherServlet` 类并进行相关的配置
- `@ComponentScan`：使 Spring 扫描所有自定义**组件类、配置类、业务类以及控制器**，并将其装配

在启动类中的 `main` 方法中调用 `SpringBootApplication.run()` 即可实现应用的启动，和传统 Java web 应用配置复杂的 **web.xml** 文件截然不同，不需要在配置上花费太多时间


## 构建可执行的 jar

我们可以使用一条简单的命令来完成应用打包成 jar：

```shell
$ ./mvnw clean package
```

执行这条命令来启动应用：

```shell

$ java -jar target/gs-rest-service-0.1.0.jar
```

## 做一些简单的测试

在浏览器中访问 `htpp://localhost:8080/user/1`，没问题的话会得到如下响应：

```javascript
{
    "id": 1,
    "name": "张三"
}
```


# 总结


这仅仅是一个 RESTful web service，更多文档请浏览：[Building a RESTful Web Service][5e1fef67]




  [5e1fef67]: https://spring.io/guides/gs/rest-service/ "Building a RESTful Web Service"
  [7dc5ba20]: https://spring.io/guides/gs/rest-service/ "Build with Gradle"

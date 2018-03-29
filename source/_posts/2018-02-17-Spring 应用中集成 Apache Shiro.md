---
layout:     post
title:      "Spring 应用中集成 Apache Shiro"
subtitle:   ""
date:       2018-02-17 09:55:00
author:     "James"
header-img: "img/post-bg-2015.jpg"
catalog: true
tags:
    - Shiro
---
这一篇文章涵盖了将 Shiro 集成到基于 Spring 的应用程序的方法。

Shiro 的 Java Bean兼容性使它非常适合通过 Spring XML 或其他基于 Spring 的配置机制进行配置。Shiro 的应用程序需要一个应用程序单例安全管理器 ( SecuriyManager) 实例。注意，这并不一定是静态的单例，但是应用程序应该只使用一个实例，不管它是否是静态的单例。

## 1.独立的应用程序
以下是在 Spring 应用程序中启用应用程序单例安全管理器的最简单方法:

```xml
<!-- 定义连接到后端安全数据源的 Realm : -->
<bean id="myRealm" class="...">
    ...
</bean>

<bean id="securityManager" class="org.apache.shiro.mgt.DefaultSecurityManager">
    <!-- 单一 Realm 应用这样写。如果有多个 Realm ，可以使用 "realms" 属性 -->
    <property name="realm" ref="myRealm"/>
</bean>

<bean id="lifecycleBeanPostProcessor" class="org.apache.shiro.spring.LifecycleBeanPostProcessor"/>

<!-- 对于最简单的集成方式，就像所有的 SecurityUtils 中的静态
方法一样，在所有情况下都适用，将 securityManager bean 声明
为一个静态的单例对象。但不要在 web 应用程序中这样做。参见
下面的 “web 应用程序” 部分。  -->
<bean class="org.springframework.beans.factory.config.MethodInvokingFactoryBean">
    <property name="staticMethod" value="org.apache.shiro.SecurityUtils.setSecurityManager"/>
    <property name="arguments" ref="securityManager"/>
</bean>
```

## 2.Web 应用程序
Shiro 对 Spring web 应用程序有很棒的支持。在一个 web 应用程序中，所有的可用的 web 请求都必须经过 Shiro Filter。这个过滤器非常强大，允许基于 URL 路径表达式执行的特殊自定义任何过滤器链。

在 Shiro 1.0之前，你必须在 Spring web 应用程序中使用一种混合的方法，定义 Shiro 的过滤器所有的配置属性都在 web.xml 中。但是在 spring.xml中定义 securityManager，这有点不友好。

现在，在 Shiro 1.0 以上的版本中，所有的 Shiro 配置都是在Spring XML 中完成的，它提供了更健壮的 Spring 配置机制。
以下是如何在基于 spring 的 web 应用程序中配置 Shiro:
### web.xml
除了其他的 spring 的一些标签 ( ContextLoaderListener、Log4jConfigListener 等)，还定义了以下过滤器和过滤器的映射:
```xml
<!-- 在 applicationContext.xml 中，过滤器名称 “shiroFilter” bean的名称匹配。-->
<filter>
    <filter-name>shiroFilter</filter-name>
    <filter-class>org.springframework.web.filter.DelegatingFilterProxy</filter-class>
    <init-param>
        <param-name>targetFilterLifecycle</param-name>
        <param-value>true</param-value>
    </init-param>
</filter>

...

<!-- 确保你想要的任何请求都可以被过滤。/ * 捕获所有
请求。通常，这个过滤器映射首先 （在所有其他的之前）定义，
确保 Shiro 在过滤器链的后续过滤器中工作:-->
<filter-mapping>
    <filter-name>shiroFilter</filter-name>
    <url-pattern>/*</url-pattern>
</filter-mapping>
```
### applicationContext.xml
在 applicationContext.xml 文件，定义 web 适用的SecurityManager 和 “shiroFilter” bean，这个bean 在 web.xml 中会被引用。

```xml
<bean id="shiroFilter" class="org.apache.shiro.spring.web.ShiroFilterFactoryBean">
    <property name="securityManager" ref="securityManager"/>
    <!-- 根据具体情况定义以下几个属性:
    <property name="loginUrl" value="/login.jsp"/>
    <property name="successUrl" value="/home.jsp"/>
    <property name="unauthorizedUrl" value="/unauthorized.jsp"/> -->
    <!-- 如果声明过任何的 javax.servlet，“filters” 属性就是不必要的了-->
    <!-- <property name="filters">
        <util:map>
            <entry key="anAlias" value-ref="someFilter"/>
        </util:map>
    </property> -->
    <property name="filterChainDefinitions">
        <value>
            # 定义需要过滤的 url :
            /admin/** = authc, roles[admin]
            /docs/** = authc, perms[document:read]
            /** = authc
            </value>
    </property>
</bean>
<!-- 可以在上下文中定义的任何 javax.servlet.Filter bean，它们会自动被上面的 “shiroFilter” bean 所捕获，并为“filterChainDefinitions” 属性所用。如果需要的话，可以手动添加/显式添加到 shiroFilter 的 “filters” Map 上。-->
<bean id="someFilter" class="..."/>
<bean id="anotherFilter" class="..."> ... </bean>
...

<bean id="securityManager" class="org.apache.shiro.web.mgt.DefaultWebSecurityManager">
    <!-- 单一 Realm 应用这样写。如果有多个 Realm ，可以使用 "realms" 属性. -->
    <property name="realm" ref="myRealm"/>
    <!-- 认情况下，适用 servlet 容器的 session 。取消对这一行的注释后则使用 shiro的原生 session  -->
    <!-- <property name="sessionMode" value="native"/> -->
</bean>
<bean id="lifecycleBeanPostProcessor" class="org.apache.shiro.spring.LifecycleBeanPostProcessor"/>

<!-- 通过自定义 Shiro Realm 的子类来使用后台的数据源 -->
<bean id="myRealm" class="...">
    ...
</bean>
```
## 启用 Shiro 的注解
在应用程序中，可能需要使用 Shiro 的注释来进行安全检查(例如，@RequiresRole、@requiresPermission 等等。这需要 Shiro的 Spring AOP 集成，以扫描适当的带注释的类，并在必要时执行安全逻辑。下面是如何启用这些注释，将这两个 bean 定义添加到 applicationContext.xml 中:
```xml
<bean class="org.springframework.aop.framework.autoproxy.DefaultAdvisorAutoProxyCreator" depends-on="lifecycleBeanPostProcessor"/>
    <bean class="org.apache.shiro.spring.security.interceptor.AuthorizationAttributeSourceAdvisor">
    <property name="securityManager" ref="securityManager"/>
</bean>
```

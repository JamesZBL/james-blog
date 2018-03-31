---
title: Spring 整合 Shiro 权限控制
date: 2018-03-30 10:50:07
categories:
    - 后端
tags:
    - Shiro
    - Spring
    - 权限控制
    - 安全
    - 认证
---

Apache Shiro 是一个功能强大且灵活的开放源代码安全框架，可以细粒度地处理认证 (Authentication)，授权 (Authorization)，会话 (Session) 管理和加密 (cryptography) 等企业级应用中常见的安全控制流程。

Apache Shiro 的首要目标是易于使用和理解。 有时候安全性的流程控制会非常复杂，对开发人员来说是件很头疼的事情，但并不一定如此。 框架就应该尽可能地掩盖复杂性，并公开一个简洁而直观的 API，从而简化开发人员的工作，确保其应用程序安全性。这次我们聊一聊如何在 Spring Web 应用中使用 Shiro 实现权限控制。
<!-- more -->



# 功能



Apache Shiro 是一个具有许多功能的综合型应用程序安全框架。 下图为 Shiro 中的最主要的几个功能：

图片

Shiro 的主要目标是“应用安全的四大基石” - 认证，授权，会话管理和加密：
- 身份验证：也就是通常所说的 “登录”，为了证明用户的行为所有者。
- 授权：访问控制的过程，即确定什么用户可以访问哪些内容。
- 会话管理：即使在非 Web 应用程序中，也可以管理用户特定的会话，这也是 Shiro 的一大亮点。
- 加密技术：使用加密算法保证数据的安全，非常易于使用。


# 架构


从整体概念上理解，Shiro 的体系架构有三个主要的概念：Subject （主体，也就是用户），Security Manager （安全管理器）和 Realms （领域）。 下图描述了这些组件之间的关系：

图片

这几大组件可以这样理解：

- Subject （主体）：主体是当前正在操作的用户的特定数据集合。主体可以是一个人，也可以代表第三方服务，守护进程，定时任务或类似的东西，也就是几乎所有与该应用进行交互的事物。
- Security Manager （安全管理器）：它是 Shiro 的体系结构的核心，扮演了类似于一把 “伞” 的角色，它主要负责协调内部的各个组件，形成一张安全网。
- Realms （领域）：Shiro 与应用程序安全数据之间的 “桥梁”。当需要实际与用户帐户等安全相关数据进行交互以执行认证和授权时，Shiro 将从 Realms 中获取这些数据。


# 数据准备

在 Web 应用中，对安全的控制主要有角色、资源、权限（什么角色能访问什么资源）几个概念，一个用户可以有多个角色，一个角色也可以访问多个资源，也就是角色可以对应多个权限。落实到数据库设计上，我们至少需要建 5 张表：用户表、角色表、资源表、角色-资源表、用户-角色表，这 5 张表的结构如下：

用户表：
 id | username  | password
--|---|--
 1 | 张三  |  123456
 2 | 李四  |  666666
 3 | 王五  |  000000

角色表：
 id | rolename
--|--
 1 | 管理员
 2 | 经理
 3 | 员工

资源表：
 id | resname
--|--
 1 | /user/add
 2 | /user/delete
 3 | /compony/info  

角色-资源表：
 id | roleid  | resid
--|---|--
 1 | 1  | 1
 2 | 1  | 2
 3 | 2  | 3

用户-角色表：
 id | userid  | roleid
--|---|--
 1 | 1  | 1
 2 | 1  | 2
 3 | 1  | 3

对应的 POJO 类如下：

```java
/**
 * 用户
 */
public class User {

	private Integer id;

	private String username;

	private String password;

    //getter & setter...
}
```

```java
/**
 * 角色
 */
public class Role {

    private String id;

    private String rolename;
}
```
```java
/**
 * 资源
 */
public class Resource {

    private String id;

    private String resname;
}
```
```java
/**
 * 角色-资源
 */
public class RoleRes {

    private String id;

    private String roleid;

    private String resid;
}
```
```java
/**
 * 用户-角色
 */
public class UserRole {

    private String id;

    private String userid;

    private String roleid;
}
```

Spring 与 Shiro 整合的详细步骤，请参阅我的博客 [《 Spring 应用中整合 Apache Shiro 》]()

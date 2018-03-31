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
![](https://upload-images.jianshu.io/upload_images/7134080-faa18427db36e746.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
Shiro 的主要目标是“应用安全的四大基石” - 认证，授权，会话管理和加密：
- 身份验证：也就是通常所说的 “登录”，为了证明用户的行为所有者。
- 授权：访问控制的过程，即确定什么用户可以访问哪些内容。
- 会话管理：即使在非 Web 应用程序中，也可以管理用户特定的会话，这也是 Shiro 的一大亮点。
- 加密技术：使用加密算法保证数据的安全，非常易于使用。



# 架构



从整体概念上理解，Shiro 的体系架构有三个主要的概念：Subject （主体，也就是用户），Security Manager （安全管理器）和 Realms （领域）。 下图描述了这些组件之间的关系：
![](https://upload-images.jianshu.io/upload_images/7134080-0cce315aff85264c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
这几大组件可以这样理解：
- Subject （主体）：主体是当前正在操作的用户的特定数据集合。主体可以是一个人，也可以代表第三方服务，守护进程，定时任务或类似的东西，也就是几乎所有与该应用进行交互的事物。
- Security Manager （安全管理器）：它是 Shiro 的体系结构的核心，扮演了类似于一把 “伞” 的角色，它主要负责协调内部的各个组件，形成一张安全网。
- Realms （领域）：Shiro 与应用程序安全数据之间的 “桥梁”。当需要实际与用户帐户等安全相关数据进行交互以执行认证和授权时，Shiro 将从 Realms 中获取这些数据。



# 数据准备



在 Web 应用中，对安全的控制主要有角色、资源、权限（什么角色能访问什么资源）几个概念，一个用户可以有多个角色，一个角色也可以访问多个资源，也就是角色可以对应多个权限。落实到数据库设计上，我们至少需要建 5 张表：用户表、角色表、资源表、角色-资源表、用户-角色表，这 5 张表的结构如下：

用户表：

| id | username | password|
|--|---|--|
| 1 | 张三 | 123456|
| 2 | 李四 | 666666|
| 3 | 王五 | 000000|

角色表：

| id | rolename|
|--|--|
| 1 | 管理员|
| 2 | 经理|
| 3 | 员工|

资源表：

| id | resname|
|--|--|
| 1 | /user/add|
| 2 | /user/delete|
| 3 | /compony/info|

角色-资源表：

| id | roleid | resid|
|--|---|--|
| 1 | 1 | 1|
| 2 | 1 | 2|
| 3 | 2 | 3|

用户-角色表：

| id | userid | roleid|
|--|---|--|
| 1 | 1 | 1|
| 2 | 1 | 2|
| 3 | 1 | 3|

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



# 整合


Spring 与 Shiro 整合的详细步骤，请参阅我的博客 [《 Spring 应用中整合 Apache Shiro 》](http://james.letec.top/2018/02/17/Spring%20%E5%BA%94%E7%94%A8%E4%B8%AD%E9%9B%86%E6%88%90%20Apache%20Shiro/)。
这里补充一下：需要提前引入 Shiro 的依赖，打开 [mvnrepository.com](mvnrepository.com)，搜索 Shiro，我们需要前三个依赖，也就是 Shiro-Core、Shiro-Web 以及 Shiro-Spring，以 Maven 项目为例，在 `pom.xml` 中的 `<dependencies>` 节点下添加如下依赖：
```xml
<dependency>
    <groupId>org.apache.shiro</groupId>
    <artifactId>shiro-core</artifactId>
    <version>1.4.0</version>
</dependency>
<dependency>
    <groupId>org.apache.shiro</groupId>
    <artifactId>shiro-web</artifactId>
    <version>1.4.0</version>
</dependency>
<dependency>
    <groupId>org.apache.shiro</groupId>
    <artifactId>shiro-spring</artifactId>
    <version>1.4.0</version>
</dependency>
```
在 `application-context.xml` 中需要这样配置 `shiroFilter` bean:
```xml
<!-- 配置shiro的过滤器工厂类，id- shiroFilter要和我们在web.xml中配置的过滤器一致 -->
<bean id="shiroFilter" class="org.apache.shiro.spring.web.ShiroFilterFactoryBean">
    <property name="securityManager" ref="securityManager"/>
    <!-- 登录页面 -->
    <property name="loginUrl" value="/login"/>
    <!-- 登录成功后的页面 -->
    <property name="successUrl" value="/index"/>
    <!-- 非法访问跳转的页面 -->
    <property name="unauthorizedUrl" value="/403"/>
    <!-- 权限配置 -->
    <property name="filterChainDefinitions">
        <value>
            <!-- 无需认证即可访问的静态资源，还可以添加其他 url -->
            /static/** = anon
            <!-- 除了上述忽略的资源，其他所有资源都需要认证后才能访问 -->
            /** = authc
        </value>
    </property>
</bean>
```


# 认证


接下来就需要定义 Realm 了，自定义的 Realm 集成自 `AuthorizingRealm` 类：
```java
public class MyRealm extends AuthorizingRealm {
 @Autowired
 private UserService userService;
 /**
  * 验证权限
  */
 @Override
 protected AuthorizationInfo doGetAuthorizationInfo(PrincipalCollection principalCollection) {
  String loginName = SecurityUtils.getSubject().getPrincipal().toString();
  if (loginName != null) {
   String userId = SecurityUtils.getSubject().getSession().getAttribute("userSessionId").toString();
   // 权限信息对象,用来存放查出的用户的所有的角色及权限
   SimpleAuthorizationInfo info = new SimpleAuthorizationInfo();
   // 用户的角色集合
   ShiroUser shiroUser = (ShiroUser) principalCollection.getPrimaryPrincipal();
         info.setRoles(shiroUser.getRoles());
         info.addStringPermissions(shiroUser.getUrlSet());
   return info;
  }
  return null;
 }
 /**
  * 认证回调函数,登录时调用
  */
 protected AuthenticationInfo doGetAuthenticationInfo(AuthenticationToken token) {
  String username = (String) token.getPrincipal();
  User user = new User();
        sysuser.setUsername(username);
  try {
   List<SysUser> users = userService.findByNames(user);
            List<String> roleList= userService.selectRoleNameListByUserId(users.get(0).getId());
   if (users.size() != 0) {
    String pwd = users.get(0).getPassword();
    // 当验证都通过后，把用户信息放在 session 里
    Session session = SecurityUtils.getSubject().getSession();
    session.setAttribute("userSession", users.get(0));
    session.setAttribute("userSessionId", users.get(0).getId());
    session.setAttribute("userRoles", org.apache.commons.lang.StringUtils.join(roleList,","));
                return new SimpleAuthenticationInfo(username,users.get(0).getPassword());
   } else {
                // 没找到该用户
    throw new UnknownAccountException();
   }
  } catch (Exception e) {
   System.out.println(e.getMessage());
  }
  return null;
 }
 /**
     * 更新用户授权信息缓存.
     */
 public void clearCachedAuthorizationInfo(PrincipalCollection principals) {
  super.clearCachedAuthorizationInfo(principals);
 }
 /**
     * 更新用户信息缓存.
     */
 public void clearCachedAuthenticationInfo(PrincipalCollection principals) {
  super.clearCachedAuthenticationInfo(principals);
 }
 /**
  * 清除用户授权信息缓存.
  */
 public void clearAllCachedAuthorizationInfo() {
  getAuthorizationCache().clear();
 }
 /**
  * 清除用户信息缓存.
  */
 public void clearAllCachedAuthenticationInfo() {
  getAuthenticationCache().clear();
 }
 /**
  * 清空所有缓存
  */
 public void clearCache(PrincipalCollection principals) {
  super.clearCache(principals);
 }
 /**
  * 清空所有认证缓存
  */
 public void clearAllCache() {
  clearAllCachedAuthenticationInfo();
  clearAllCachedAuthorizationInfo();
 }
}
```


# 控制器


最后定义一个用户登录的控制器，接受用户的登录请求：
```java
@Controller
public class UserController {
    /**
     * 用户登录
     */
    @PostMapping("/login")
    public String login(@Valid User user,BindingResult bindingResult,RedirectAttributes redirectAttributes){
        try {
            if(bindingResult.hasErrors()){
                return "login";
            }
            //使用权限工具进行认证，登录成功后跳到 shiroFilter bean 中定义的 successUrl
            SecurityUtils.getSubject().login(new UsernamePasswordToken(user.getUsername(), user.getPassword()));
            return "redirect:index";
        } catch (AuthenticationException e) {
            redirectAttributes.addFlashAttribute("message","用户名或密码错误");
            return "redirect:login";
        }
    }
    /**
     * 注销登录
     */
    @GetMapping（"/logout")
    public String logout(RedirectAttributes redirectAttributes ){
        SecurityUtils.getSubject().logout();
        return "redirect:login";
    }
}
```

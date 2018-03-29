---
title: SpringMVC 解析之 DispatcherServlet
categories: [后端]
tags: [Spring MVC,Spring]
---

# Spring MVC 是什么

Spring Web MVC （Spring MVC) 是一套以 Servlet API 为基础平台的优雅的 Web 框架，一直是 Spring Framework 中重要的一个组成部分。 正式名称 “Spring Web MVC” 来自其源模块 spring-webmvc 的名称，但它通常被称为“Spring MVC”。

与 Spring Web MVC 并行，Spring Framework 5.0 引入了一个 Reactive stack —— Web框架，其名称 Spring WebFlux 也基于它的源模块 spring-webflux。
<!-- more -->
# DispatcherServlet

与许多其他 Web 框架一样，Spring MVC 同样围绕前端页面的控制器模式 (Controller) 进行设计，其中最为核心的 Servlet —— DispatcherServlet 为来自客户端的请求处理提供通用的方法，而实际的工作交由可自定义配置的组件来执行。 这种模型使用方式非常灵活，可以满足多样化的项目需求。

和任何普通的 Servlet 一样，DispatcherServlet 需要根据 Servlet 规范使用 Java 代码配置或在 web.xml 文件中声明请求和 Servlet 的映射关系。 DispatcherServlet 通过读取 Spring 的配置来发现它在请求映射，视图解析，异常处理等方面所依赖的组件。

以下是注册和初始化 DispatcherServlet 的 Java 代码配置示例。 该类将被 Servlet 容器自动检测到：

```java
public class MyWebApplicationInitializer implements WebApplicationInitializer {

    @Override
    public void onStartup(ServletContext servletCxt) {

        // 加载 Spring Web Application 的配置
        AnnotationConfigWebApplicationContext ac = new AnnotationConfigWebApplicationContext();
        ac.register(AppConfig.class);
        ac.refresh();

        // 创建并注册 DispatcherServlet
        DispatcherServlet servlet = new DispatcherServlet(ac);
        ServletRegistration.Dynamic registration = servletCxt.addServlet("app", servlet);
        registration.setLoadOnStartup(1);
        registration.addMapping("/app/*");
    }
}
```

以下是在 web.xml 中注册和初始化 DispatcherServlet 的方法：

```xml
<web-app>

    <listener>
        <listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
    </listener>

    <context-param>
        <param-name>contextConfigLocation</param-name>
        <!-- Spring 上下文的配置 -->
        <param-value>/WEB-INF/app-context.xml</param-value>
    </context-param>

    <servlet>
        <servlet-name>app</servlet-name>
        <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
        <init-param>
            <param-name>contextConfigLocation</param-name>
            <param-value></param-value>
        </init-param>
        <load-on-startup>1</load-on-startup>
    </servlet>

    <servlet-mapping>
        <servlet-name>app</servlet-name>
        <!-- "/*" 表示将所有请求交由 DispatcherServlet 处理 -->
        <url-pattern>/*</url-pattern>
    </servlet-mapping>

</web-app>
```

# 1. 应用上下文的层次结构

DispatcherServlet 依赖于一个 WebApplicationContext（对普通 ApplicationContext 的功能扩展）来实现自己的配置。 WebApplicationContext 中包含了一个指向它所关联的 ServletContext 和 Servlet 的链接。 它同时还绑定到 Servlet 上下文中，以便应用程序可以使用 RequestContextUtils 中的静态方法在 WebApplicationContext 进行查找，来判断是否需要调用 DispatcherServlet 中的方法。

对于只有一个 WebApplicationContext 应用程序来说，这已经可以满足使用了。 同时也可以使用具有层次结构的上下文，其中有一个根上下文（或者叫基上下文） 被多个 DispatcherServlet（或其他普通 Servlet）实例所共享，每个实例都有属于自己的子上下文配置。

根上下文通常包含被多个 Servlet 实例共享的公共 bean，例如数据仓库和业务。 这些 bean 被继承下来使用，还可以在特定的 Servlet 的子上下文中重写（即重新声明一个 bean 的配置），子上下文中拥有该 Servlet 所独有的局部 bean 实例：

![](https://docs.spring.io/spring/docs/current/spring-framework-reference/images/mvc-context-hierarchy.png)

以下是使用 WebApplicationContext 层次结构的示例配置：

```java
public class MyWebAppInitializer extends AbstractAnnotationConfigDispatcherServletInitializer {

    @Override
    protected Class<?>[] getRootConfigClasses() {
        return new Class<?>[] { RootConfig.class };
    }

    @Override
    protected Class<?>[] getServletConfigClasses() {
        return new Class<?>[] { App1Config.class };
    }

    @Override
    protected String[] getServletMappings() {
        return new String[] { "/app1/*" };
    }
}
```

在 web.xml 中的配置

```xml
<web-app>

    <listener>
        <listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
    </listener>

    <context-param>
        <param-name>contextConfigLocation</param-name>
        <!-- 根上下文的配置 -->
        <param-value>/WEB-INF/root-context.xml</param-value>
    </context-param>

    <servlet>
        <servlet-name>app1</servlet-name>
        <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
        <init-param>
            <param-name>contextConfigLocation</param-name>
            <!-- app1 专属的的子上下文 -->
            <param-value>/WEB-INF/app1-context.xml</param-value>
        </init-param>
        <load-on-startup>1</load-on-startup>
    </servlet>

    <servlet-mapping>
        <servlet-name>app1</servlet-name>
        <url-pattern>/app1/*</url-pattern>
    </servlet-mapping>

</web-app>
```


# 2. 带有特殊功能的 Bean

DispatcherServlet 依靠这些特殊的 bean 来处理请求并返回响应。 这些特殊的 bean 是指实现 WebFlux 框架协议的，同样由 Spring 管理的对象。 这些对象都含有一套默认的配置，但也可以自定义各种属性，从而进行灵活扩展或功能改写。

 bean 类名 | 功能
--|--
 HandlerMapping |  将请求映射到处理程序以及用于预处理和后续处理的一系列拦截器。 这种映射有着一套标准，具体的功能因 HandlerMapping 实现而异。            HandlerMapping 的两个最主要实现是 RequestMappingHandlerMapping 和 SimpleUrlHandlerMapping ,前者支持 @RequestMapping 注释方法，它为请求的处理进行 URI 映射的注册。
 HandlerAdapter |  协助 DispatcherServlet 调用匹配请求映射的处理程序，且不需要关心如何调用处理程序以及处理程序的任何细节。 例如，调用带注释的控制器中的方法需要先对 @RequestMapping 等注释进行解析。 HandlerAdapter 的主要功能是屏蔽 DispatcherServlet 的实现细节。
 HandlerExceptionResolver |  包含各种异常的解决方法，可以将不同的异常映射到响应的处理程序或页面等。
 ViewResolver |  将处理程序中的方法返回值（字符串）的逻辑视图名称解析为实际视图，来将响应返回给客户端。
 LocaleResolver, LocaleContextResolver |  识别客户端的当前区域设置以估测大概的时区，从而能够返回响应地区的国际化视图。
 ThemeResolver |  解析当前 Web 应用程序可用的主题，例如提供个性化布局。
 MultipartResolver |  在相应的解析库的辅助下，对 multi-part 请求（比如浏览器的表单文件上传）进行解析。
 FlashMapManager |  存储和检索可将参数从一个请求传递到另一个请求的“输入”和“输出”的 FlashMap，通常通过重定向来实现。


# 3. Web MVC 的配置

应用程序可以单独声明上文中“带有特殊功能的 Bean”中列出的基础版的 bean。 DispatcherServlet 扫描这些 bean 所属的 WebApplicationContext。 如果没有匹配的 bean 类型，它将返回 DispatcherServlet.properties 中的默认类型。

在大多数情况下，MVC 默认配置是最好的实现。 它采用 Java 代码或 XML 文件来配置所需的 bean，同时提供更高级别的配置回调 API 用于改写默认配置。

# 4.  Servlet 的配置

在 Servlet 3.0 以上的版本中，可以用 Java代码或与 web.xml 文件相结合来配置 Servlet 容器。 以下是用 Java 代码注册 DispatcherServlet 的示例：

```java
import org.springframework.web.WebApplicationInitializer;

public class MyWebApplicationInitializer implements WebApplicationInitializer {

    @Override
    public void onStartup(ServletContext container) {
        XmlWebApplicationContext appContext = new XmlWebApplicationContext();
        appContext.setConfigLocation("/WEB-INF/spring/dispatcher-config.xml");

        ServletRegistration.Dynamic registration = container.addServlet("dispatcher", new DispatcherServlet(appContext));
        registration.setLoadOnStartup(1);
        registration.addMapping("/");
    }
}
```

WebApplicationInitializer 是 Spring MVC 提供的一个接口，其所有实现类都可以被扫描到，并自动用于初始化任何 Servlet 3 容器。 AbstractDispatcherServletInitializer （WebApplicationInitializer 的一个抽象父类）的实现类可以通过覆盖方法来配置 Servlet 请求映射、DispatcherServlet 配置文件的目录，这样很简单的就实现了 DispatcherServlet 的配置。

如果通过 Java 代码来配置 Spring 的话，需要这样做：

```java
public class MyWebAppInitializer extends AbstractAnnotationConfigDispatcherServletInitializer {

    @Override
    protected Class<?>[] getRootConfigClasses() {
        return null;
    }

    @Override
    protected Class<?>[] getServletConfigClasses() {
        return new Class<?>[] { MyWebConfig.class };
    }

    @Override
    protected String[] getServletMappings() {
        return new String[] { "/" };
    }
}
```

如果用 xml 文件来配置 Spring，则只需定义一个 AbstractDispatcherServletInitializer 实现类即可：

```java
public class MyWebAppInitializer extends AbstractDispatcherServletInitializer {

    @Override
    protected WebApplicationContext createRootApplicationContext() {
        return null;
    }

    @Override
    protected WebApplicationContext createServletApplicationContext() {
        XmlWebApplicationContext cxt = new XmlWebApplicationContext();
        cxt.setConfigLocation("/WEB-INF/spring/dispatcher-config.xml");
        return cxt;
    }

    @Override
    protected String[] getServletMappings() {
        return new String[] { "/" };
    }
}
```

AbstractDispatcherServletInitializer 还可以轻松添加 Filter 并自动映射到 DispatcherServlet 中:

```java
public class MyWebAppInitializer extends AbstractDispatcherServletInitializer {

    // ...

    @Override
    protected Filter[] getServletFilters() {
        return new Filter[] {
            new HiddenHttpMethodFilter(), new CharacterEncodingFilter() };
    }
}
```

不同的 Filter 都会以不同的名称注册，同时映射到 DispatcherServlet 中。

The isAsyncSupported protected method of AbstractDispatcherServletInitializer provides a single place to enable async support on the DispatcherServlet and all filters mapped to it. By default this flag is set to true.

AbstractDispatcherServletInitializer 中的 isAsyncSupported() 方法可以设置各个 Filter 是否开启异步支持。

如果还想更加细化自定义配置，可以通过重写 createDispatcherServlet() 方法来实现。

# 5. 处理请求

DispatcherServlet 处理请求的规则：
- 在请求中查找并绑定 WebApplicationContext，它可以作为参数被控制器中的方法使用。 默认绑定到 DispatcherServlet.WEB_APPLICATION_CONTEXT_ATTRIBUTE 对应的值。
- 区域解析器 (LocaleResolver) 也绑定到请求上，它可以在请求解析、呈现视图、准备数据等过程中将信息解析为当前的区域环境。如果无需解析这些信息，可以不用管它。
- 主题解析器用来决定使用哪个主题。 如果你不使用主题，可以忽略掉它。
- 如果在应用中声明了 multipart file resolver，则会对请求进行 multipart 检查；如果发现了 multiparts，请求会被包装成 MultipartHttpServlet 来进行处理。
- 如果返回模型，则会解析并返回视图。 如果没有返回模型（由于其他处理程序拦截了请求，可能出于安全原因），则不会返回视图，因为可能已经有响应返回给客户端了。

WebApplicationContext 中声明的 HandlerExceptionResolver bean 可以解析请求处理时抛出的异常。 可以给异常解析器进行特定的配置来解决特定的异常。

DispatcherServlet 还支持返回最后修改日期。 DispatcherServlet 扫描注册的映射关系并，判断找到的处理程序是否实现了 LastModified 接口。 如果实现了，则将 LastModified 接口的 long getLastModified（request）方法的返回值返回给客户端。

在 web.xml 中，可以通过配置 Servlet 的初始化参数（init-param）来自定义一个 DispatcherServlet 的实例。

_DispatcherServlet 的初始化参数_

参数  |  含义
--|--
 contextClass |  WebApplicationContext 的实现类，初始化 Servlet 的上下文，默认为 XmlWebApplicationContext
 contextConfigLocation | 作为参数传递给在 contextClass 中指定上下文实例，用于标识上下文的位置，接受多个字符串（以逗号分隔），如果同一个 bean 的配置在多个上下文中出现，则以最后一个为准。
 namespace |  WebApplicationContext 的命名空间，默认为 <servlet-name> 元素中的值加上“servlet”。比如，<servlet-name>app</servlet-name>，那么，命名空间为 appServlet。


# 6. 拦截器

所有 HandlerMapping 的实现类都支持使用拦截器，特别是将某些功能只应用到特定的请求上时（比如判断权限），拦截器就非常有用。 拦截器必须实现 org.springframework.web.servlet 包中的 HandlerInterceptor，它提供了三个方法，供不同时刻来调用：

- preHandle(..)：在请求处理前执行...
- postHandle(..)：在请求处理后执行...
- afterCompletion(..)：在请求处理完全结束后执行...

preHandle(..) 方法返回布尔值，可以通过这一点选择来切断或继续请求的处理链。当返回 true 的时候，处理器链会继续执行；返回 false 的时候， DispatcherServlet 就会认为拦截器已经处理了请求或返回了视图，并不会继续被处理链中的其他处理器或拦截器所处理。

请注意，postHandle(..) 对使用 @ResponseBody 和 ResponseEntity 方法的用处不大，在 HandlerAdapter 中， postHandle(..) 调用之前就已经提交响应了。 所以这时再修改响应什么用也没有了。 这种情况下，可以实现 ResponseBodyAdvice，并将其声明为 Controller Advice bean （在 Controller 类上添加 @ControllerAdvice 注解）或直接在 RequestMappingHandlerAdapter 中进行配置。


# 7. 异常处理

在映射或调用请求处理程序 （例如带有 @Controller 注解的控制器） 处理请求时，如果抛出了异常，则 DispatcherServlet 调用 HandlerExceptionResolver bean 来处理异常，然后将错误页面或错误状态码等信息返回个客户端。

下面列出 HandlerExceptionResolver 的几个实现类：

_HandlerExceptionResolver 实现类_

类名  |  功能
--|--
 SimpleMappingExceptionResolver |  将异常类型映射到异常页面的视图名，可以很容易实现错误页面的返回
 DefaultHandlerExceptionResolver |  处理由 Spring MVC 抛出的异常，可以直接映射到不同的 HTTP 状态码
 ResponseStatusExceptionResolver |  处理带有 @ResponseStatus 注解的异常，并将其映射到 HTTP 状态码
 ExceptionHandlerExceptionResolver |  通过调用控制器（带有 @Controller 注解或 @ControllerAdvice 注解）中的带有 @ExceptionHandler 注解的方法，来处理异常

如果需要同时映射多个异常类型，需要设置不同异常的权重 （order 属性），权重越高，处理时机越晚。

## 处理方式
HandlerExceptionResolver 中可以返回：

- ModelAndView： 指向视图名
- 不带属性的 ModelAndView： 如果已经通过权重更低的方法处理过异常了
- null： 这个异常无法被当前异常处理器识别，需要丢给接下来的处理器，如果所有处理器都不能处理这个异常，异常会传到 Servlet 容器中，由容器来处理
- 自定义异常处理请求也非常简单，比如，在 xml 中配置一个 HandlerExceptionResolver 的 bean， Spring MVC 会自动使用内部的默认异常处理器来处理 Spring MVC 抛出的异常（带有 @ResponseStatus 注解的异常或带有 @ExceptionHandler 注解的方法），可以修改这些默认配置或干脆直接重写新的配置。

## Servlet 容器中定义的错误页面 (error-page)
如果抛出的异常没能被任何 HandlerExceptionResolver 处理，就会传到 Servlet 容器中。如果将 HTTP 响应码设置为 4xx 或 5xx， Servlet 容器会直接返回默认的错误页面。可以在 web.xml 中配置自定义的错误页面：

```xml
<error-page>
    <location>/error</location>
</error-page>
```

此时，如果想要对异常处理进一步自定义，可以这样做：

```java
@RestController
public class ErrorController {

    @RequestMapping(path = "/error")
    public Map<String, Object> handle(HttpServletRequest request) {
        Map<String, Object> map = new HashMap<String, Object>();
        map.put("status", request.getAttribute("javax.servlet.error.status_code"));
        map.put("reason", request.getAttribute("javax.servlet.error.message"));
        return map;
    }
}
```

这样就能再次将 /error 请求交给 DispatcherServlet 来处理，这种方式解决了使用 RestController 返回 JSON，而不是返回视图的情况。


# 8. 视图名解析

Spring MVC 定义了 View 和 ViewResolver 这两个接口，View 负责返回视图前的数据准备， ViewResolver 则负责将逻辑视图名映射到实际视图。 屏蔽了具体的视图实现细节。

_ViewResolver 的几个实现类_
类名  |  功能
--|--
 AbstractCachingViewResolver |  AbstractCachingViewResolver 的实现类会将解析过的视图缓存，缓存可以提升特定视图技术的性能。可以通过设置 cache 属性的值为 false 来将缓存功能关闭。如果想在运行时刷新视图缓存，可以调用 removeFromCache(String viewName, Locale loc) 方法将已缓存内容移除。
 XmlViewResolver |  可以使用 Spring bean DTD 定义，在 xml 中对其配置。默认的配置文件为 /WEB-INF/views.xml
 ResourceBundleViewResolver |  通过解析定义的 ResourceBundle bean，将 viewname 解析为视图名，url 解析为视图路径
 UrlBasedViewResolver |  可以直接将 url 映射到返回值中，无需再进行额外的映射配置，适用于视图结构清晰，可以直接对应匹配的情况
 InternalResourceViewResolver |  UrlBasedViewResolver 的子类，可以解析 InternalResourceView （比如 Servlet 或 JSP) 以及其子类，比如 JstlView 或 TilesView。可以通过 setViewClass(..) 方法来指定要解析的具体视图类型
 FreeMarkerViewResolver |  UrlBasedViewResolver 的子类，可以解析 FreeMarkerView 以及自定义的子类
 ContentNegotiatingViewResolver |  通过请求的 url 或请求头信息来解析视图

## 处理方式

和上面提到的异常解析器一样，通过配置 bean 来解析视图，同样可以指定不同解析器的权重，权重越高，调用时机越晚。

ViewResolver 可以通过返回 null 来表示视图无法解析，如果是 JSP 或 InternalResourceViewResolver，可以判断 JSP 是否存在的唯一方法就是通过执行 RequestDispatcher 的请求调度方法。 因此必须将 InternalResourceViewResolver 的权重配置为所有视图解析器中最高的。

如果返回视图的执行过程不需要处理任何的业务逻辑，可以使用视图控制器来实现：

```java
@Configuration
@EnableWebMvc
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addViewControllers(ViewControllerRegistry registry) {
        // 将 url 为 "/" 的请求映射到名为 home 的视图上
        registry.addViewController("/").setViewName("index");
    }
}
```

在 xml 中这样写：

```xml
<mvc:view-controller path="/" view-name="index"/>
```

## 重定向

如果返回的视图名以 "redirect:" 开头， UrlBasedViewResolver 就会将其解析为请求重定向，后面的视图名就是将重定向的 url。

这样和返回 RedirectView 的效果是一样的，他可以将请求重定向到当前 Servlet 上下文的相对路径，如果写成这样 `redirect:http://myhost.com/some/arbitrary/path`，就会重定向到这个绝对路径上。

如果在控制器的方法上写了 @ResponseStatus 注解，则注解中的状态码优先权高于 RedirectView 中的。

## 转发

如果最终的视图解析器为 UrlBasedViewResolver， 则可以使用 `forward:`，效果通过 forward() 方法创建一个 InternalResourceView 。这个前缀不适用于 InternalResourceViewResolver 和 InternalResourceView （JSP），但对于使用其他的视图技术且想执行请求转发，就非常有用了。同样，将多个视图解析器组成处理链实现链式处理。

## 内容规约

ContentNegotiatingViewResolver 实际并不会解析视图，而是调用其他视图解析器，查找与客户端请求中有关信息匹配的视图。这些信息可以从请求头中的 `Accept` 中或 url 中参数获得。

ContentNegotiatingViewResolver 将请求的媒体类型与 ViewResolvers 关联的 View 支持的媒体类型（也称为 Content-Type）进行比较，选择最佳的 View 来处理请求。 与这个 Content-Type 相符的第一个视图会被首先返回给客户端。 如果 ViewResolver 链无法解析视图，则会在 DefaultViews 的视图列表进行查找。 后者适用于无需进行业务逻辑处理的单例 View ，因此不用考虑逻辑视图名。 Accept 头中可以包含通配符，例如 `text/ *` ，则将匹配 content-type 为 `text/xml`的 View 。



# 9. 语言环境

Spring MVC 和 Spring 中的大多数模块一样，也提供了内容国际化的功能。DispatcherServlet 可以根据客户端的语言环境进行内容的自动国际化，这要归功于 LocaleResolver。

DispatcherServlet 接受到请求后会去上下文中查找 LocaleResolver bean，找到后就会使用它完成国际化的任务。可以调用 RequestContext.getLocale() 来获得请求的语言环境。

如果不想使用默认的自动解析方式，还可以通过在处理程序映射中添加一个拦截器来实现，比如解析 url 中的参数。

有关国际化的解析器和拦截器都定义在 `org.springframework.web.servlet.i18n` 中，并且都需要在应用上下文中配置。Spring 可以国际化这些内容：

## 时区

除了语言环境，有时还需要获得客户端的时区信息，LocaleContextResolver 对 LocaleResolver 中的功能进行了扩展，这样可以在 LocaleContext 中获得更为丰富的信息。

通过 RequestContext.getTimeZone()方法获取客户端的时区信息，在 Spring 的 ConversionService 中注册的日期/时间转换器和格式化器会自动获取这些信息。

## 请求头

这个区域解析器会识别请求中的 `accept-language` 头，这个字段一般包含客户操作系统的区域信息，但是它无法获得客户端的时区信息。

## Cookie

这个区域解析器会检查客户端上的 Cookie 是否存在语言或时区信息。这个区域解析器可以设置 cookie 的名字和失效时间。在 xml 文件中定义 CookieLocaleResolver：

```xml
<bean id="localeResolver" class="org.springframework.web.servlet.i18n.CookieLocaleResolver">

    <!-- 根据具体情况自定义 -->
    <property name="cookieName" value="clientlanguage"/>

    <!-- 100000 为秒数，值为 -1 时, cookie 会在浏览器关闭时被销毁 -->
    <property name="cookieMaxAge" value="100000"/>

</bean>
```

_CookieLocaleResolver 部分属性的含义_

 属性 | 默认值  | 含义
--|---|--
 cookieName | 类名+语言环境  |  cookie 的名称
 cookieMaxAge |  Servlet 容器中规定的值 |  cookie 的有效期，值为 -1 时, cookie 会在浏览器关闭时被销毁
 cookiePath | /  | 将 cookie 的作用域限制到制定的相对路径下，cookie 将只在这个路径及其自路径中有效

## Session

SessionLocaleResolver 可以从会话上下文中获取语言和时区信息，它和 CookieLocaleResolver 的区别是：它是在 Servlet 容器的 session 中存储语言和时区信息，所有，这些信息都是暂时的，会话结束后也就不复存在了。

## 语言环境拦截器

LocaleChangeInterceptor bean 可以通过自定义配置来修改请求中的参数，达到修改语言环境的目的。调用 LocaleResolver 中的 setLocal() 方法即可。下面的例子演示将所有请求中的 siteLanguage 参数修改为荷兰语：

```xml
<bean id="localeChangeInterceptor"
        class="org.springframework.web.servlet.i18n.LocaleChangeInterceptor">
    <property name="paramName" value="siteLanguage"/>
</bean>

<bean id="localeResolver"
        class="org.springframework.web.servlet.i18n.CookieLocaleResolver"/>

<bean id="urlMapping"
        class="org.springframework.web.servlet.handler.SimpleUrlHandlerMapping">
    <property name="interceptors">
        <list>
            <ref bean="localeChangeInterceptor"/>
        </list>
    </property>
    <property name="mappings">
        <value>/**/*.view=someController</value>
    </property>
</bean>
```


# 10. 主题

Spring Web MVC 框架支持自定义主题，应用程序的整体外观可以实现统一修改。主题即静态资源的集合，通常是 CSS 和图片，两者决定了应用的整体风格。

## 主题的定义

必须定义一个 `org.springframework.ui.context.ThemeSource` 接口的实现类才能使用主题功能。默认情况下，WebApplicationContext 通过 `org.springframework.ui.context.support.ResourceBundleThemeSource` 实现主题功能，它从 classpath 的根目录读取配置文件。 要使用自定义的 ThemeSource，需要配置 ResourceBundleThemeSource 的主题名称前缀，在应用程序上下文中注册一个 themeSource bean。

使用 ResourceBundleThemeSource 自定义主题，需要将配置写在 properties 文件中，这个文件中包含了构成主题的所有资源。

```xml
styleSheet=/themes/cool/style.css
background=/themes/cool/img/coolBg.jpg
```

在 JSP 中使用主题设置，要用到 `spring:theme` 标签：

```html
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<html>
    <head>
        <link rel="stylesheet" href="<spring:theme code='styleSheet'/>" type="text/css"/>
    </head>
    <body style="background=<spring:theme code='background'/>">
        ...
    </body>
</html>
```

默认情况下，ResourceBundleThemeSource 主题名前缀是空的。properties 文件是从 classpath 的根目录读取的。所以应当将 abc.properties 配置文件放到根目录下（`/WEB-INF/classes`）。 ResourceBundleThemeSource 可以实现主题的国际化。比如，`/WEB-INF/classes/abc_nl.properties`，结合上面对 background 属性的配置，可以实现将背景切换为带有荷兰文字的背景图片。

## 主题的解析

定义好主题配置后，当有请求发来时，在预处理阶段，通过查找上下文中叫 `themeResolver` 的 bean 来对决定用什么解析器来解析主题，这里的工作原理和上文中的 `localeResolver` 一样。通过识别带有不同参数的请求来对请求的主题进行切换。Spring 提供了这几种 themeResolver:

 类名 | 功能
--|--
 FixedThemeResolver | 通过读取 `defaultThemeName` 属性来选择固定的主题
 SessionThemeResolver |  主题信息由 session 保存，每个 session 只需解析一次，不同的 session 之间无法共享
 FixedThemeResolver |  主题信息保存在客户端的 cookie 中

Spring 还提供了一个 `ThemeChangeInterceptor` 拦截器，通过识别请求的参数来切换主题。


# 11. Multipart


`org.springframework.web.multipart.MultipartResolver` 提供了一种处理表单上传文件的解决方案，有两种实现方式，一种是基于 Apache 的 Commons-Fileupload，另一种是基于 Servlet 3.0 的。

首先要在 Spring 的配置文件中为 DispatcherServlet 声明一个叫做 `MultipartResolver` 的 bean，DispatcherServlet 会自动识别并调用它来处理文件上传请求。它会将 content-type 为 `multipart/form-data` 的请求包装成 `MultipartHttpServletRequest`，从而将这些 "part" 暴露为请求的一个参数。

## Apache FileUpload

要想使用 Apache Commons-Fileupload，需要将 `multipartResolver` bean 配置为 `CommonsMultipartResolver`，另外不要忘了添加 `commons-fileupload` 的依赖。

## Servlet 3.0

如果通过 Servlet 3.0 处理 multipart 请求，则同样需要在 DispatcherServlet 中注册。在 Java 代码中配置的话，需要添加一个 `MultipartConfigElement `；在 xml 文件中配置的话，添加 `<multipart-config>` 节点。文件大小限制和文件保存位置等选项同样需要这样配置，因为在 Servlet 3.0 以后，不允许 `MultipartResolver` 这么干了。

Servlet 3.0 配置好后，只需要在 xml 文件中将 `multipartResolver` hean 配置为 `StandartMultipartResolver` 即可。

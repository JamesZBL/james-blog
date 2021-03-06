---
title: Spring MVC 中 @ModelAttribute 注解的妙用
date: 2018-03-31 10:44:32
categories:
    - 后端
tags:
    - Spring
    - Spring MVC
    - Java
---

Spring MVC 提供的这种基于注释的编程模型，极大的简化了 web 应用的开发。其中 `@Controller` 和 `@RestController` 注解的组件使用 `@RequestMapping`、 `@ExceptionHandler` 等注解来表示请求映射，请求输入，异常处理等，使得开发者能专注于业务逻辑的编写，提高了开发效率。 带注释的控制器具有灵活的方法签名，不必扩展基类，也不需要实现特定的接口。
<!-- more -->

可以使用 `Servlet` 的 `WebApplicationContext` 中的标准 `Spring bean` 定义来定义控制器 bean。 所有带有 `@Controller` 注解的类会被自动检测，就像 Spring 通常的扫描方式一样，检测类路径中的 `@Component` 类，并为它们自动注册 bean 定义。 它也充当注释类的刻板，表示它可以作为一个 Web 组件。

带有 `@RequestMapping` 注解的方法叫做 `Handler Method` - 处理器方法，它的参数可以来自很多地方，比如 `ServletRequest` 、 `ServletResponse` 、 `HttpSession` 等。




# @ModelAttribute


在控制器的处理器方法参数上添加 `@ModelAttribute` 注释可以访问模型中的属性，如果不存在这个模型，则会自动将其实例化，产生一个新的模型。 模型属性还覆盖了来自 HTTP Servlet 请求参数的名称与字段名称匹配的值，也就是请求参数如果和模型类中的域变量一致，则会自动将这些请求参数绑定到这个模型对象，这被称为数据绑定，从而避免了解析和转换每个请求参数和表单字段这样的代码。 例如：

```java
@PostMapping("/componies/{componyId}/departments/{departmentId}/edit")
public String processSubmit(@ModelAttribute Department department) { }
```

这个处理器方法中的 department 参数会被从以下几个来源进行匹配绑定：

- 已经定义过的模型方法（带有 `@ModelAttribute` 的方法，后面解释）
- HTTP Session 中和字段名匹配的会话方法（带有 `@SessionAttribute` 的方法，和模型方法类似，只是作用域不同）
- 经过 URL 转换器解析过的路径变量
- 该模型类的默认构造方法
- 调用具有与 Servlet 请求参数匹配的参数的 “主构造函数”; 参数名称通过 JavaBeans `@ConstructorProperties` 或通过字节码中的运行时保留参数名称确定。

虽然一般都是使用模型方法 Model method 来使用属性填充模型，但另一种方法是依靠 `Converter<String,T>` 识别 URI 路径变量来绑定。在下面的例子中，模型属性名称 “user” 与 URI 路径变量 “user” 匹配，并且通过将 String 类型的用户名交给给已注册的 `Converter<String,User>` 这个转换器来生成创建模型：

```java
@PutMapping("/users/{user}")
public String saveUser(@ModelAttribute("user") User user) {
    // ...
}
```
在获得模型属性实例之后，请求数据就会被绑定到模型属性上。 `WebDataBinder` 负责将 Servlet 请求参数名称（查询参数或表单字段）和目标模型对象上的字段名称进行匹配。 必要时会将属性的类型进行转换后再填充对应字段。

数据绑定不能保证不会出错，发生错误时默认情况下会抛出 `BindException` 异常，但要在处理器方法中识别出这些错误，需要在 @ModelAttribute 后面添加一个 `BindingResult` 类型的参数，需要注意的是：这个参数必须和模型属性参数 (`@ModelAttribute` 参数)相邻，如下所示：

```java
@PostMapping("/owners/{componyId}/departments/{departmentId}/edit")
public String processSubmit(@ModelAttribute("compony") Compony compony, BindingResult result) {
    if (result.hasErrors()) {
        return "componyForm";
    }
    // ...
}
```

这个例子表示如果用户提交的表单不符合预期的匹配规则，就会返回视图 `componyForm`。

有时候我们需要获得一个不带数据绑定的模型属性，也就是需要在处理器方法中使用 `new` 关键字来实例化一个对象。但是在 Spring MVC 中就不用这么麻烦了，我们可以将模型注入控制器并直接访问它，或者可以添加 `@ModelAttribute（binding = false）` 来表示不需要绑定数据，如下所示：

```java
@ModelAttribute
public UserForm setUpForm() {
    return new UserForm();
}

@ModelAttribute
public User findUser(@PathVariable String userId) {
    return userRepository.findOne(userId);
}

@PostMapping("update")
public String update(@Valid UserUpdateForm form, BindingResult result,
        @ModelAttribute(binding=false) User user) {
    // ...
}
```
在参数上添加 `javax.validation.Valid` 注解或 Spring 的 `@Validated` 注解，就可以在数据绑定后使用字段校验功能了，就像这样：

```java
@PostMapping("/componies/{componyId}/departments/{departmentId}/edit")
public String processSubmit(@Valid @ModelAttribute("department") Department department, BindingResult result) {
    if (result.hasErrors()) {
        return "departmentForm";
    }
    // ...
}
```
这样写和在方法体中写 `model.addAttribute("compony",compony)` 是等价的。

需要注意的是 `@ModelAttribute` 注解如果不加，按照 `BeanUtils` 中的 `isSimpleProperty` 方法来判断，如果不属于简单类型的参数，都会被自动视为 `ModelAttribute`。

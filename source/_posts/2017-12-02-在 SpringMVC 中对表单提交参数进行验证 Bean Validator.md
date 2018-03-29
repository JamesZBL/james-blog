---
layout:     post
title:      "在 SpringMVC 中对表单提交参数进行验证（使用 Bean Validator）"
subtitle:   ""
date:       2017-12-01 19:25:00
author:     "James"
header-img: "img/post-bg-2015.jpg"
catalog: true
tags:
    - Spring MVC
---
## 前言
在 SpringMVC 项目中，有时需要对前端页面上传的表单参数进行一定的限制，包括不为空或者长度等。在控制器的各种方法中进行诸如如下方式的判断势必造成大量重复的代码
```java
if( null != username && (!username.isEmpty()){
  ......
}else if( null != password && (!password.isEmpty()){
  ......
}else if( null != phone && (!phone.isEmpty()){
  ......
}
......
```

## Bean Validator

Bean Validation 为 JavaBean 验证定义了相应的元数据模型和 API。缺省的元数据是 Java Annotations，通过使用 XML 可以对原有的元数据信息进行覆盖和扩展。在应用程序中，通过使用 Bean Validation 或是你自己定义的 constraint，例如 @NotNull, @Max, @ZipCode， 就可以确保数据模型（JavaBean）的正确性。constraint 可以附加到字段，getter 方法，类或者接口上面。对于一些特定的需求，用户可以很容易的开发定制化的 constraint。Bean Validation 是一个运行时的数据验证框架，在验证之后验证的错误信息会被马上返回。

这里我们使用 Hibernate Validator 作为上述问题的解决方案

## SpringMVC 中使用 Hibernate Validator

在合适的位置新建一个 ValidatorConfig 类，以 Java Config 的方式对 LocalFactoryBean 进行配置

```java
import org.hibernate.validator.HibernateValidator;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.validation.beanvalidation.LocalValidatorFactoryBean;

/**
 * 配置 Hibernate Validator
 * Created by James on 17-12-2.
 */
@Configuration
public class ValidatorConfig {

  @Bean(name = "validator")
  public LocalValidatorFactoryBean getValidator() {
    LocalValidatorFactoryBean bean = new LocalValidatorFactoryBean();
    bean.setProviderClass(HibernateValidator.class);
    return bean;
  }
}
```

## 定义 Java Bean 实体类
```java
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import me.zbl.fullstack.consts.DataConsts;
import org.hibernate.validator.constraints.Length;
import org.hibernate.validator.constraints.NotEmpty;

@NoArgsConstructor
@Getter
@Setter
public class UserRegisterForm {
    @Length(max = 10)
    @NotEmpty(message = "用户名不能为空")
    private String username;
    @Length(max = 10)
    @NotEmpty(message = "密码不能为空")
    private String password;
    @NotEmpty(message = "请再次确认密码")
    private String confirmpassword;
}
```

## Bean Validation 中内置的约束注解    

@Null   被注释的元素必须为 null    
@NotNull    被注释的元素必须不为 null    
@AssertTrue     被注释的元素必须为 true    
@AssertFalse    被注释的元素必须为 false    
@Min(value)     被注释的元素必须是一个数字，其值必须大于等于指定的最小值    
@Max(value)     被注释的元素必须是一个数字，其值必须小于等于指定的最大值    
@DecimalMin(value)  被注释的元素必须是一个数字，其值必须大于等于指定的最小值    
@DecimalMax(value)  被注释的元素必须是一个数字，其值必须小于等于指定的最大值    
@Size(max=, min=)   被注释的元素的大小必须在指定的范围内    
@Digits (integer, fraction)     被注释的元素必须是一个数字，其值必须在可接受的范围内    
@Past   被注释的元素必须是一个过去的日期    
@Future     被注释的元素必须是一个将来的日期    
@Pattern(regex=,flag=)  被注释的元素必须符合指定的正则表达式    

Hibernate Validator 附加的 constraint    
@NotBlank(message =)   验证字符串非null，且长度必须大于0    
@Email  被注释的元素必须是电子邮箱地址    
@Length(min=,max=)  被注释的字符串的大小必须在指定的范围内    
@NotEmpty   被注释的字符串的必须非空    
@Range(min=,max=,message=)  被注释的元素必须在合适的范围内

## 在 Controller 中对参数绑定结果进行验证

```java
/**
  * 表单提交
  */
  @PostMapping("/register.form")
  public String fFrontUserRegister(@Valid UserRegisterForm registerForm, BindingResult bindingResult) {
    if (bindingResult.hasErrors()) {
      List<ObjectError> errors = bindingResult.getAllErrors();
      // 此处可以对 errors 进行遍历获取错误消息
      return "error";
      ......
    }
    ......
    return "success";
  }
```

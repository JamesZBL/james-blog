---
title: 使用 Hexo + Github 搭建自己的博客
date: 2018-03-30T13:03:58.000Z
categories:
    - 博客
tags:
    - 博客
    - Git
    - Linux
    - Hexo
---

Hexo 是一个快速、简洁且高效的静态博客应用，它的一大亮点是提供了强大的 CLI 工具，真正实现了一键部署。Hexo 使用 Markdown 来解析文章，可以在很短时间内渲染出简洁大方的页面。本文将从安装到部署来详细介绍 Hexo。
<!-- more -->
本文涉及到的一些工具需要一定操作基础，若有疑问，请先自行搜索学习。


# 安装


Hexo 的运行和部署需要以下工具：
 - Node.js
 - Git

## 安装 Node.js
Windows 平台使用官网提供的安装包来安装，在 cmd 中验证是否安装好：
![](https://upload-images.jianshu.io/upload_images/7134080-c1363a9feb73fda6.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


## 安装 Hexo-Cli
安装 Node 时一般默认安装了 npm 工具，因此使用以下命令来安装 Hexo 的命令行工具 Hexo-Cli:

```shell
$ npm install -g hexo-cli
```

## 安装 Git
Windows 平台下安装 git-for-windows，\*nix 平台使用自带的包管理工具安装，以 Ubuntu 为例：

```shell
$ apt-get install git
```

## 创建一个站点
在任意位置打开 cmd，使用 ``hexo init <dir>`` 命令创建一个博客，``dir`` 为博客目录名

```shell
$ hexo init <folder>
$ cd <folder>
$ npm install
```

等待所有依赖包安装完成



# 配置


## 配置站点
博客根目录的 ``_config.yml`` 为 “站点配置文件”，包括 SEO、主题、布局、插件等配置项

```yml
# Site
title: xxx的博客
subtitle: 副标题
description: 对站点的描述
keywords: 关键词
author: 作者
language: 语言（中文简体为：zh-Hans）
timezone: 时区（国内这里填写：Asia/Shanghai）
```

Hexo 默认的样式大概是这样的：
![](https://upload-images.jianshu.io/upload_images/7134080-df16f35a46e2c669.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


推荐使用 Next 主题

## 主题

### 安装 Next 主题

在站点根目录打开 cmd，运行命令：
```shell
$ git clone https://github.com/iissnan/hexo-theme-next themes/next
```

### 切换主题

主题相关的文件就从 Next 的 github 仓库克隆到了 themes/next 目录下，只需要在 “站点配置文件” 中将 `theme` 字段的值改为 `next` 就实现了主题的切换
```yml
theme: next
```

### 查看效果

Hexo 提供的命令行工具中自带服务器功能，在站点根目录运行：

```shell
$ hexo s
```

当出现提示：

    INFO  Hexo is running at http://0.0.0.0:4000/. Press Ctrl+C to stop.

的时候，就可以打开浏览器访问：`http://localhost:4000` 来查看效果了，默认效果是这样的：
![](https://upload-images.jianshu.io/upload_images/7134080-c039d4e9117a5f31.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


如果觉得不好看可以通过修改`themes/next`目录下 “主题配置文件” `_config.yml`来自定义主题样式，这里只介绍一些常用配置，详细配置请参考 [Next 官网](http://theme-next.iissnan.com/getting-started.html)

### 布局

Next 的默认布局为 Muse，就是这个样子：
![](https://upload-images.jianshu.io/upload_images/7134080-c039d4e9117a5f31.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

Next 还提供另外两种布局：
- Pisces
- Mist

我这里使用的是 Pisces，所有这样修改 “主题” 配置文件：

```yml
scheme: Pisces
```
Pisces 布局的效果：
![](https://upload-images.jianshu.io/upload_images/7134080-a3bf55f9e72586af.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


# 写文章

在站点根目录运行命令：
```shell
hexo new <title>
```
其中，\<title\> 为文章题目，运行命令后在 `source/_posts` 目录下可以看到 `文章题目.md` 这样一个文件，用任意编辑器打开这个文件，里面的内容大概是这样：

```yml
---
title: Hello World
date: 2013/7/13 20:46:25
---
```
这段内容在 Hexo 官方的叫法为 `Front matter`，在渲染文章的时候，渲染引擎会读取这段内容并在页面适当的地方展示文章的各种信息，`Front matter` 主要有一下几项：

- title：文章标题
- date：创建日期
- tags：标签
- categories：分类

需要注意的是，分类是具有层次性的，也就是说 `Python,爬虫` 这种分类和 `爬虫,Python` 是完全不同的，它们会被分为两类，而标签则没有这种层次性

如果觉得使用起来不是很方便，可以只给定一个分类，比如这样：
```yml
categories:
- 日记
tags:
- 上海
- 旅行
```

站点首页会以分页的方式展示最近发布的文章，默认展示全文，如果想要只展示开头部分内容，比如这种效果：
![](https://upload-images.jianshu.io/upload_images/7134080-e5fa264b0b204944.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


可以在文章适当的位置添加 `<!-- more -->` 标记，这样可以在首页只展示标记之前的内容，避免首页一次加载过多内容造成不好的体验

# 部署

如果有可用的服务器，可以使用 `hexo g` 命令，生成静态站点，通过 FTP 或其他方式将站点上传到服务器对应目录，并配合 nginx 或 Apache 服务器，即可完成部署，这里介绍一下没有服务器情况下，如何搭建一个完整的博客站点

首先要有一个 github 账号，如果没有，可到 [github](http://github.com) 用邮箱注册

新建一个仓库，仓库的名字必须符合 `<用户名>.github.io`，用户名指的是浏览 github 个人主页的时候，浏览器地址栏 `github.com/` 后面的那个名字，比如我的 [github 主页](http://github.com/jameszbl)，则我的用户名就是 `jameszbl`，新建仓库后会跳转到初始化页面，显示一个类似于 `https://github.com/jameszbl/jameszbl.github.io.git` 的 url， 记下这个url，稍候会用到

在 “站点配置文件” 中，找到 `deploy`，如果没有可以手动添加，像这样填写：
```yml
deploy:
    - type: git
      # 远端仓库地址（刚才记下的 url)
      repo: https://github.com/JamesZBL/jameszbl.github.io.git
      branch: master
```

这里的部署配置需要安装一个插件，因此在站点根目录运行命令：
```shell
$ npm install hexo-deployer-git --save
```

插件安装完成后，再执行：
```shell
$ hexo g && hexo d
```

部署插件会自动将编译完成的静态站点推送到 github 的远端仓库，等待几分钟后，访问 `<github 用户名>.github.io`，即可看到搭建好的效果了

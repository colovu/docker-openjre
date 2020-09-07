# 简介

针对 OpenJDK 的 Docker 镜像，用于提供基础 Java 开发环境及运行环境。

使用说明可参考：官方说明



**JDK 版本信息：**

- 11-jdk、11.0.7-jdk、latest-jdk
- 8-jdk、8u252-jdk
- 8u242-jdk

**JRE 版本信息：**

- 11-jre、11.0.7-jre、latest-jre
- 8-jre、8u252-jre
- 8u242-jre

**镜像信息：**

- 镜像地址：colovu/openjdk:latest

  

## **TL;DR**

基本验证命令：

```shell
# 11之前的版本
$ docker run -it --rm colovu/openjdk:8-jdk javac -version

# 11之后的版本
$ docker run -it --rm colovu/openjdk:latest javac --version
```



----

本文原始来源 [Endial Fang](https://github.com/colovu) @ [Github.com](https://github.com)


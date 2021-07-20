# 简介

针对 OpenJRE 的 Docker 镜像，用于提供基础 Java 运行环境。

使用说明可参考：[官方说明](https://docs.oracle.com/javase/8/)

<img src="img/java-logo.png" alt="OpenJDK-logo" style="zoom: 33%;" />

**JRE 版本信息：**

- 8u262b10

**镜像信息：**

* 镜像地址：
  - Aliyun仓库：registry.cn-shenzhen.aliyuncs.com/colovu/openjre:8
  - DockerHub：colovu/openjre:8
  * 依赖镜像：debian:buster-slim

> 后续相关命令行默认使用`[Docker Hub](https://hub.docker.com)`镜像服务器做说明



## TL;DR

基本验证命令：

```shell
# 11之前的版本
$ docker run -it --rm colovu/openjre java -version

# 11之后的版本
$ docker run -it --rm colovu/openjre java --version
```



----

本文原始来源 [Endial Fang](https://github.com/colovu) @ [Github.com](https://github.com)


# Ver: 1.0 by Endial Fang (endial@126.com)
#
FROM colovu/alpine:3.12
ARG apt_source=default

ENV APP_NAME=openjre

ENV JAVA_VERSION=1.8.0 \
	JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk

ENV JRE_HOME="${JAVA_HOME}/jre" \
	CLASSPATH="${JAVA_HOME}/lib:${JAVA_HOME}/jre/lib" \
	PATH="${JAVA_HOME}/bin:${JAVA_HOME}/jre/bin:${PATH}"

LABEL   "Version"="v1.8" \
	"Description"="Alpine image for OpenJRE 1.8." \
	"Dockerfile"="https://github.com/colovu/docker-openjre" \
	"Vendor"="Endial Fang (endial@126.com)"

RUN select_source ${apt_source}
RUN install_pkg openjdk8-jre; \
# 解决应用安装jre-headless时错误：update-alternatives: error: error creating symbolic link '/usr/share/man/man
	mkdir -p /usr/share/man/man1; \
# 验证安装的应用软件是否正常
	java -version;

WORKDIR /

CMD []
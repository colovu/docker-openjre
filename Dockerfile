# Ver: 1.2 by Endial Fang (endial@126.com)
#
FROM colovu/dbuilder as builder

# sources.list 可使用版本：default / tencent / ustc / aliyun / huawei
ARG apt_source=tencent

# 编译镜像时指定用于加速的本地服务器地址
ARG local_url=""

RUN set -eux; \
	appVersion=8u252b09; \
	appName=OpenJDK8U-jre_x64_linux_${appVersion}.tar.gz; \
	appKeys="0xCA5F11C6CE22644D42C6AC4492EF8D39DC13168F 0xEAC843EBD3EFDB98CC772FADA5CD6035332FA671"; \
	appUrls=" \
		${local_url}/openjdk \
		https://github.com/AdoptOpenJDK/openjdk8-upstream-binaries/releases/download/jdk8u252-b09 \
		"; \
	download_pkg unpack ${appName} "${appUrls}" -g "${appKeys}";

# 镜像生成 ========================================================================
FROM colovu/debian:10
ARG apt_source=default

ENV JAVA_VERSION=1.8.0-252 \
	JAVA_HOME=/usr/local/java-1.8-openjdk

ENV JRE_HOME="${JAVA_HOME}/jre" \
	CLASSPATH="${JAVA_HOME}/lib:${JAVA_HOME}/jre/lib" \
	PATH="${JAVA_HOME}/bin:${JAVA_HOME}/jre/bin:${PATH}"

LABEL \
	"Version"="v${JAVA_VERSION}" \
	"Description"="Docker image for openJRE v${JAVA_VERSION}." \
	"Dockerfile"="https://github.com/colovu/docker-openjdk" \
	"Vendor"="Endial Fang (endial@126.com)"

RUN select_source ${apt_source}
RUN install_pkg p11-kit ca-certificates

RUN mkdir -p ${JAVA_HOME}
COPY --from=builder /usr/local/openjdk-8u252-b09-jre/ ${JAVA_HOME}

RUN set -eux; \
# 更新 OpenJDK 绑定的证书
	{ \
		echo '#!/usr/bin/env bash'; \
		echo 'set -Eeuo pipefail'; \
		echo 'if ! [ -d "${JAVA_HOME}" ]; then echo >&2 "error: missing JAVA_HOME environment variable"; exit 1; fi'; \
# 8-jdk uses "${JAVA_HOME}/jre/lib/security/cacerts" and 8-jre and 11+ uses "${JAVA_HOME}/lib/security/cacerts" directly (no "jre" directory)
		echo 'cacertsFile=; for f in "${JAVA_HOME}/lib/security/cacerts" "${JAVA_HOME}/jre/lib/security/cacerts"; do if [ -e "$f" ]; then cacertsFile="$f"; break; fi; done'; \
		echo 'if [ -z "$cacertsFile" ] || ! [ -f "$cacertsFile" ]; then echo >&2 "error: failed to find cacerts file in ${JAVA_HOME}"; exit 1; fi'; \
		echo 'trust extract --overwrite --format=java-cacerts --filter=ca-anchors --purpose=server-auth "$cacertsFile"'; \
	} > /etc/ca-certificates/update.d/docker-openjdk; \
	chmod +x /etc/ca-certificates/update.d/docker-openjdk; \
	/etc/ca-certificates/update.d/docker-openjdk; \
	\
	find "${JAVA_HOME}/lib" -name '*.so' -exec dirname '{}' ';' | sort -u > /etc/ld.so.conf.d/docker-openjdk.conf; \
	ldconfig; \
# 解决应用安装jre-headless时错误：update-alternatives: error: error creating symbolic link '/usr/share/man/man
	mkdir -p /usr/share/man/man1; \
	\
# 验证安装的软件是否可以正常运行，常规情况下放置在命令行的最后
	java -version;

WORKDIR /

CMD []
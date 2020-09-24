# Ver: 1.2 by Endial Fang (endial@126.com)
#
FROM colovu/abuilder as builder

# sources.list 可使用版本：default / tencent / ustc / aliyun / huawei
ARG apt_source=tencent

# 编译镜像时指定用于加速的本地服务器地址
ARG local_url=""
RUN set -eux; \
	appVersion=8u262b10; \
	appName=OpenJDK8U-jre_x64_linux_${appVersion}.tar.gz; \
	appKeys="0xCA5F11C6CE22644D42C6AC4492EF8D39DC13168F 0xEAC843EBD3EFDB98CC772FADA5CD6035332FA671"; \
	[ -n ${local_url} ] && localURL=${local_url}/openjdk; \
	appUrls="${localURL:-} \
		https://github.com/AdoptOpenJDK/openjdk8-upstream-binaries/releases/download/jdk8u262-b10 \
		"; \
	download_pkg unpack ${appName} "${appUrls}" -g "${appKeys}";

# 镜像生成 ========================================================================
FROM colovu/alpine:3.12
ARG apt_source=default
ARG local_url=""

ENV JAVA_VERSION=8u262-b10 \
	JAVA_HOME=/usr/local/openjdk8

ENV JRE_HOME="${JAVA_HOME}/jre" \
	CLASSPATH="${JAVA_HOME}/lib:${JAVA_HOME}/jre/lib" \
	LANG=zh_CN.UTF-8 \
	PATH="${JAVA_HOME}/bin:${JAVA_HOME}/jre/bin:${PATH}"

LABEL \
	"Version"="v${JAVA_VERSION}" \
	"Description"="Docker image for openJRE v${JAVA_VERSION}." \
	"Dockerfile"="https://github.com/colovu/docker-openjre" \
	"Vendor"="Endial Fang (endial@126.com)"

RUN select_source ${apt_source}
RUN install_pkg p11-kit p11-kit-trust ca-certificates dmidecode

RUN mkdir -p ${JAVA_HOME}
COPY --from=builder /usr/local/openjdk-8u262-b10-jre/ ${JAVA_HOME}

# 安装 Glibc
RUN set -eux; \
	wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub; \
	appVersion=2.32-r0; \
	appName=glibc-${appVersion}.apk; \
	[ -n ${local_url} ] && localURL=${local_url}/glibc; \
	appUrls="${localURL:-} \
		https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${appVersion} \
		"; \
	download_pkg install ${appName} "${appUrls}"; \
	apk add --no-cache /usr/local/bin/glibc-2.32-r0.apk; \
	\
# 解决 /usr/glibc-compat/sbin/ldconfig: /usr/glibc-compat/lib/ld-linux-x86-64.so.2 is not a symbolic link
	cd /usr/glibc-compat/lib; \
	mv ld-linux-x86-64.so.2 ld-linux-x86-64.so; \
	ln -s ld-linux-x86-64.so ld-linux-x86-64.so.2; \
	\
	rm -rf /usr/local/bin/glibc-${appVersion}.apk /tmp/glibc-${appVersion}.apk;

# 安装 Glibc-bin；系统自带的 ldconfig 存在 bug
RUN set -eux; \
	wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub; \
	appVersion=2.32-r0; \
	appName=glibc-bin-${appVersion}.apk; \
	[ -n ${local_url} ] && localURL=${local_url}/glibc; \
	appUrls="${localURL:-} \
		https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${appVersion} \
		"; \
	download_pkg install ${appName} "${appUrls}"; \
	apk add --no-cache /usr/local/bin/glibc-bin-2.32-r0.apk; \
	rm -rf /usr/local/bin/glibc-bin-${appVersion}.apk /tmp/glibc-bin-${appVersion}.apk;

# 更新 OpenJDK 绑定的证书
# 8-jdk uses "${JAVA_HOME}/jre/lib/security/cacerts" and 
# 8-jre and 11+ uses "${JAVA_HOME}/lib/security/cacerts" directly (no "jre" directory)
RUN set -eux; \
	{ \
		echo '#!/usr/bin/env bash'; \
		echo 'set -Eeuo pipefail'; \
		echo 'if ! [ -d "${JAVA_HOME}" ]; then echo >&2 "error: missing JAVA_HOME environment variable"; exit 1; fi'; \
		echo 'cacertsFile=; for f in "${JAVA_HOME}/lib/security/cacerts" "${JAVA_HOME}/jre/lib/security/cacerts"; do if [ -e "$f" ]; then cacertsFile="$f"; break; fi; done'; \
		echo 'if [ -z "$cacertsFile" ] || ! [ -f "$cacertsFile" ]; then echo >&2 "error: failed to find cacerts file in ${JAVA_HOME}"; exit 1; fi'; \
		echo 'trust extract --overwrite --format=java-cacerts --filter=ca-anchors --purpose=server-auth "$cacertsFile"'; \
	} > /etc/ca-certificates/update.d/docker-openjdk; \
	chmod +x /etc/ca-certificates/update.d/docker-openjdk; \
	/etc/ca-certificates/update.d/docker-openjdk; \
	\
# 增加 Java 库目录，并使用 Glibc 的 ldconfig 进行配置；系统自带的 ldconfig 存在 bug
	find "${JAVA_HOME}/lib" -name '*.so' -exec dirname '{}' ';' | sort -u >> /usr/glibc-compat/etc/ld.so.conf; \
	/usr/glibc-compat/sbin/ldconfig; \
	\
# 解决应用安装jre-headless时错误：update-alternatives: error: error creating symbolic link '/usr/share/man/man
	mkdir -p /usr/share/man/man1; \
	\
# 验证安装的软件是否可以正常运行，常规情况下放置在命令行的最后
	java -version;

WORKDIR /

CMD []
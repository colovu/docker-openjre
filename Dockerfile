# Ver: 1.4 by Endial Fang (endial@126.com)
#

# 预处理 =========================================================================
ARG registry_url="registry.cn-shenzhen.aliyuncs.com"
FROM ${registry_url}/colovu/dbuilder as builder

# sources.list 可使用版本：default / tencent / ustc / aliyun / huawei
ARG apt_source=aliyun

# 编译镜像时指定用于加速的本地服务器地址
ARG local_url=""

# 下载并解压软件包
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
FROM ${registry_url}/colovu/debian:10

# sources.list 可使用版本：default / tencent / ustc / aliyun / huawei
ARG apt_source=aliyun

ENV APP_NAME=openjdk8 \
	APP_VERSION=8u262-b10

# 纯 JRE 版本仅包含 JRE 相关资源
ENV JAVA_HOME=/usr/local/${APP_NAME} \
	JRE_HOME=/usr/local/${APP_NAME}

ENV PATH="${JAVA_HOME}/bin:${PATH}" \
	CLASSPATH=".:${JAVA_HOME}/lib" \
	LANG=zh_CN.UTF-8

LABEL \
	"Version"="v${APP_VERSION}" \
	"Description"="Docker image for openJRE v${APP_VERSION}." \
	"Dockerfile"="https://github.com/colovu/docker-openjre" \
	"Vendor"="Endial Fang (endial@126.com)"

# 从预处理过程中拷贝软件包(Optional)，可以使用阶段编号或阶段命名定义来源
COPY --from=builder /usr/local/openjdk-8u262-b10-jre ${JAVA_HOME}

# 选择软件包源(Optional)，以加速后续软件包安装
RUN select_source ${apt_source}

# 安装依赖的软件包及库(Optional)
RUN install_pkg p11-kit ca-certificates dmidecode

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
	find "${JAVA_HOME}/lib" -name '*.so' -exec dirname '{}' ';' | sort -u > /etc/ld.so.conf.d/docker-openjdk.conf; \
	ldconfig; \
	\
# 解决应用安装jre-headless时错误：update-alternatives: error: error creating symbolic link '/usr/share/man/man
	mkdir -p /usr/share/man/man1; 

# 执行预处理脚本，并验证安装的软件包
RUN set -eux; \
	override_file="/usr/local/overrides/overrides-${APP_VERSION}.sh"; \
	[ -e "${override_file}" ] && /bin/bash "${override_file}"; \
	java -version; \
	gosu --version;

# 应用程序的服务命令，必须使用非守护进程方式运行。如果使用变量，则该变量必须在运行环境中存在（ENV可以获取）
CMD []


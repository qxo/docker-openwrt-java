# OpenWrt with a Java installation
#
# Many thanks to the original author:
#
# Jean Blanchard <jean@blanchard.io>
#
# cf. https://github.com/jeanblanchard/docker-busybox-java
#

FROM mcreations/openwrt-x64
MAINTAINER Kambiz Darabi <darabi@m-creations.net>

# Java Version
ENV JAVA_VERSION_MAJOR 7
ENV JAVA_VERSION_MINOR 80
ENV JAVA_VERSION_BUILD 15
ENV JAVA_PACKAGE       server-jre
ENV JNA_VERSION 4.1.0

# Runtime environment
ENV JAVA_HOME /opt/jre
ENV PATH ${PATH}:${JAVA_HOME}/bin

CMD [ "java", "-version" ]

# Download and unarchive Java
RUN opkg update && opkg install curl &&\
  curl -kLOH "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie"\
    http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz &&\
    mkdir /opt &&\
    tar -xzf ${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz -C /opt &&\
    cp -r /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR}/jre /opt/ &&\
    curl -kL -o /opt/jre/lib/ext/jna.jar https://github.com/twall/jna/raw/${JNA_VERSION}/dist/jna.jar &&\
    opkg remove curl libcurl libpolarssl &&\
    rm -rf ${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz \
           /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR}/ \
           /opt/jre/lib/plugin.jar \
           /opt/jre/lib/ext/jfxrt.jar \
           /opt/jre/bin/javaws \
           /opt/jre/lib/javaws.jar \
           /opt/jre/lib/desktop \
           /opt/jre/plugin \
           /opt/jre/lib/deploy* \
           /opt/jre/lib/*javafx* \
           /opt/jre/lib/*jfx* \
           /opt/jre/lib/amd64/libdecora_sse.so \
           /opt/jre/lib/amd64/libprism_*.so \
           /opt/jre/lib/amd64/libfxplugins.so \
           /opt/jre/lib/amd64/libglass.so \
           /opt/jre/lib/amd64/libgstreamer-lite.so \
           /opt/jre/lib/amd64/libjavafx*.so \
           /opt/jre/lib/amd64/libjfx*.so

CMD [ "java", "-version" ]

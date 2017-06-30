# OpenWrt with a Java installation
#
# Many thanks to the original author:
#
# Jean Blanchard <jean@blanchard.io>
#
# cf. https://github.com/jeanblanchard/docker-java
#

FROM mcreations/openwrt-x64
MAINTAINER Kambiz Darabi <darabi@m-creations.net>

# Java Version
ENV JAVA_VERSION_MAJOR 8
ENV JAVA_VERSION_MINOR 131
ENV JAVA_VERSION_BUILD 11
ENV JAVA_PACKAGE       jdk
ENV JAVA_URL_TOKEN d54c1d3a095b4ff2b6607d096fa80163
ENV JNA_VERSION 4.4.0

# Runtime environment
ENV JAVA_HOME /opt/jdk
ENV PATH ${PATH}:${JAVA_HOME}/bin

# Download and unarchive Java
RUN opkg update && opkg install curl unzip &&\
    curl -kLOH "Cookie: oraclelicense=accept-securebackup-cookie" \
    http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/${JAVA_URL_TOKEN}/${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz &&\
    mkdir /opt &&\
    tar -xzf ${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz -C /opt &&\
    mv /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR}/ /opt/jdk &&\
    curl -jkLH "Cookie: oraclelicense=accept-securebackup-cookie" -o jce_policy-8.zip http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip &&\
    unzip jce_policy-8.zip -d /tmp &&\
    cp /tmp/UnlimitedJCEPolicyJDK8/*.jar /opt/jdk/jre/lib/security/ &&\
    rm -rf jce_policy-8.zip /tmp/UnlimitedJCEPolicyJDK8 &&\
    curl -kL -o /opt/jdk/jre/lib/ext/jna.jar https://github.com/twall/jna/raw/${JNA_VERSION}/dist/jna.jar &&\
    echo "export PATH=\$PATH:${JAVA_HOME}/bin" >> /etc/profile &&\
    opkg remove curl libcurl libpolarssl &&\
    rm -rf ${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz \
           /opt/jdk/*src.zip \
           /opt/jdk/db/ \
           /opt/jdk/include/ \
           /opt/jdk/jre/bin/javaws \
           /opt/jdk/jre/lib/*javafx* \
           /opt/jdk/jre/lib/*jfx* \
           /opt/jdk/jre/lib/amd64/libdecora_sse.so \
           /opt/jdk/jre/lib/amd64/libfxplugins.so \
           /opt/jdk/jre/lib/amd64/libglass.so \
           /opt/jdk/jre/lib/amd64/libgstreamer-lite.so \
           /opt/jdk/jre/lib/amd64/libjavafx*.so \
           /opt/jdk/jre/lib/amd64/libjfx*.so \
           /opt/jdk/jre/lib/amd64/libprism_*.so \
           /opt/jdk/jre/lib/applet/ \
           /opt/jdk/jre/lib/deploy* \
           /opt/jdk/jre/lib/desktop \
           /opt/jdk/jre/lib/ext/jfxrt.jar \
           /opt/jdk/jre/lib/javaws.jar \
           /opt/jdk/jre/lib/plugin.jar \
           /opt/jdk/jre/plugin \
           /opt/jdk/lib/*.idl \
           /opt/jdk/lib/dt.jar \
           /opt/jdk/lib/jconsole.jar \
           /opt/jdk/lib/jexec \
           /opt/jdk/lib/missioncontrol/ \
           /opt/jdk/lib/sa-jdi.jar \
           /opt/jdk/lib/visualvm/ \
           /opt/jdk/man/

CMD [ "java", "-version" ]

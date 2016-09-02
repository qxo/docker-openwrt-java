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
ENV JAVA_VERSION_MAJOR 8
ENV JAVA_VERSION_MINOR 101
ENV JAVA_VERSION_BUILD 13
# jdk or server-jre
ENV JAVA_PACKAGE       jdk
#jdk or jre
ENV JAVA_PACKAGE_TYPE  jdk

ENV JNA_VERSION 4.2.2

# Runtime environment
ENV JAVA_HOME /opt/${JAVA_PACKAGE_TYPE}
ENV PATH ${PATH}:${JAVA_HOME}/bin
ENV JNA_JRE_LIB_EXT_PATH  ${JAVA_HOME}/lib/ext/jna.jar
ENV JNA_JDK_LIB_EXT_PATH  ${JAVA_HOME}/jre/lib/ext/jna.jar

CMD [ "java", "-version" ]

# Download and unarchive Java
RUN opkg update && opkg install curl &&\
  curl -kLOH "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
    http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz &&\
  mkdir /opt &&\
  tar -xzf ${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz -C /opt &&\
  ([ "$JAVA_PACKAGE_TYPE" == "jre" ] \
   && cp -r /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR}/jre /opt \
   || cp -r /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR} $JAVA_HOME) &&\
  [ "$JAVA_PACKAGE_TYPE" == "jre" ] && JNA_PATH="$JNA_JRE_LIB_EXT_PATH" || JNA_PATH="$JNA_JDK_LIB_EXT_PATH" &&\
  curl -kL -o "$JNA_PATH" https://github.com/twall/jna/raw/${JNA_VERSION}/dist/jna.jar &&\
  echo "export PATH=\$PATH:${JAVA_HOME}/bin" >> /etc/profile &&\
  opkg remove curl libcurl libpolarssl &&\
  rm -rf ${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz \
         /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR}/

CMD [ "java", "-version" ]

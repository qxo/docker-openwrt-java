## OpenWrt Docker image with Oracle Java

Basic [Docker](https://www.docker.com/) image to run
[Java](https://www.java.com/) applications.  This is based off
[OpenWrt](http://openwrt.org/) to keep the size minimal.

This is a version of jeanblanchard/docker-busybox-java with a small
modification to base it on the OpenWrt docker image
[mcreations/openwrt-x64](https://registry.hub.docker.com/u/mcreations/openwrt-x64/).
Note that we only install the server JRE.

### Tags

* `latest` or `8`: Oracle Java 8 (Server JRE)
* `7`: Oracle Java 7 (Server JRE)

### Usage

To just run it and see the java version:

```
docker run -it --rm mcreations/openwrt-java
```

The script [list-system-properties.sh](test/list-system-properties.sh)
shows how to pass a classpath with `-v` to the container.


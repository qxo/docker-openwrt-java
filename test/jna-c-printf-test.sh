#!/bin/bash

dir=$(dirname $0)
cd $dir

docker run -it --rm -v "$(pwd)":/tmp/classpath mcreations/openwrt-java java -cp /tmp/classpath JnaNativeCPrintfTest


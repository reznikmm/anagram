
[ -d /tmp/ag ] || mkdir /tmp/ag
cd /tmp/ag

T=/home/max/cvs_root/tendra-last/src/producers/ada/

gnatmake -g -I$T/xml_io -I$T/encoding -I$T/encoding/auto -I$HOME/ada/ag/asis \
 -I$HOME/ada/ag \
 read.adb \
-bargs -E
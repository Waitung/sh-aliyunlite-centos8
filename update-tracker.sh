#!/bin/bash

# 通过rpc方式更新tracker,不用重启aria2生效，同时也会写进aria2.conf配置文件里，重启aria2依然有效。
# 可以在配置文件目录下新建文件 tracker.txt 写入自定义tracker，格式为一行一条，带有#的行会忽略，脚本更新时会把补充到tracke列表后面。
# 配置文件默认目录为 /etc/aria2 ，配置文件默认为aria2.conf ，不同的需要手动修改。
# 默认是获取 https://github.com/ngosang/trackerslist 的 trackers_all 更新，附带 https://github.com/XIU2/TrackersListCollection 的列表，默认注释掉不启用，若要选择这个列表修改注释即可。

conf_path=/etc/aria2
rpc_listen_port=`grep rpc-listen-port ${conf_path}/aria2.conf | cut -d= -f2`
rpc_secret=`grep rpc-secret ${conf_path}/aria2.conf | cut -d= -f2`
tracker_1=$(curl -Ls https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all.txt | sed '/^$/d' | sed ':a;N;$!ba;s/\n/,/g')
#tracker_1=$(curl -Ls https://trackerslist.com/all_aria2.txt)
if [ -e ${conf_path}/tracker.txt ]; then tracker_2=$(cat ${conf_path}/tracker.txt | sed '/#/d' | sed '/^$/d' | sed ':a;N;$!ba;s/\n/,/g'); fi
if [ ! ${tracker_2} ]; then
    bt_tracker=${tracker_1}
else
    bt_tracker=${tracker_1},${tracker_2}
fi
curl "http://localhost:${rpc_listen_port}/jsonrpc" -fsSd '{"jsonrpc":"2.0","method":"aria2.changeGlobalOption","id":"trackers","params":["token:'${rpc_secret}'",{"bt-tracker":"'${bt_tracker}'"}]}'
sed -i "s#bt-tracker=.*#bt-tracker=${bt_tracker}#g" ${conf_path}/aria2.conf
echo -e "\n-- bt tracker更新完成 --"
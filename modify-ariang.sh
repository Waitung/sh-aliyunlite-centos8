#!/bin/bash

# 修改AriaNG,在详情页可以点击标题直接跳转到FileBrowser页面。

ariang_path=/www/ariang
fb_url=https://pan.waitung.cn/files
text1="<span class=\"allow-word-break\" ng-bind=\"task.taskName\" ng-tooltip-container=\"body\" ng-tooltip-placement=\"bottom\" ng-tooltip=\"{{(task.bittorrent \&\& task.bittorrent.comment) ? task.bittorrent.comment : task.taskName}}\"></span>"
text2="<a ng-href=\"${fb_url}{{task.dir}}/{{task.taskName}}\" title=\"点击打开\" target=\"view_window\">${text1}</a>"
sed -i "s#${text1}#${text2}#g" ${ariang_path}/js/aria-ng-*.min.js
echo -e "更改完毕，浏览器可能需要Ctrl+F5刷新才能立刻生效"
#!/bin/bash

readme="
    ==========  ==========  ==========
    阿里云轻量 CentOS 8.2 自用脚本
    ----- ----- ----- ----- -----
    选择要更新的工具
      1. Caddy
      2. FileBrowser
      3. AriaNG
      4. Cloudreve
    ==========  ==========  ========== "


run(){
    echo -e "${readme}"
    choose
    confirm_update
}

choose(){
    while true; do
        read -p "输入数字：" -n 1 num
        case ${num} in 
            1 ) get_version_caddy; break;;
            2 ) get_version_filebrowser; break;;
            3 ) get_version_ariang; break;;
            4 ) get_version_cloudreve; break;;
            * ) echo -e "\n 请输入正确的数字！\n";;
        esac
    done
}

confirm_update(){
    echo -e "检测到最新版本：\n     ${new_version} \n ----- ----- \n当前版本： \n     ${old_version} \n ----- ----- \n安装指定版本号按 S\n===== ===== =====\n"
    while true; do
        read -p "是否执行更新? [Y/n]：" -n 1 yn
        case ${yn} in 
            y | Y ) echo -e "\n 确定安装 \n "; update; break;;
            n | N ) echo -e "\n ----- ----- ----- \n 已经退出 \n"; exit 0;;
            s | S ) echo -e "\n 指定版本号 \n "; select_version; break;;
            * ) echo -e "\n 请输入 \033[31mY\033[0m 或者 \033[31mn\033[0m \n";;
        esac
    done
}

update(){
    if [ ${num} -eq 1 ]; then update_caddy; fi
    if [ ${num} -eq 2 ]; then update_filebrowser; fi
    if [ ${num} -eq 3 ]; then update_ariang; fi
    if [ ${num} -eq 4 ]; then update_cloudreve; fi
}

select_version(){
    echo -e "\n===== ===== =====\n\n指定安装的版本号，版本号必须以github release的tag为准\n\n===== ===== =====\n"
    read -p "版本号：" s_version
    update
}

get_date(){
    date_n=$(date +%Y/%m/%d-%T)
}

determine(){
    if [ ! -e ${object} ]; then echo -e "\n  未能找到${object},已退出脚本 \n"; exit 0; fi
}

get_version_caddy(){
    object="/usr/local/bin/caddy"
    determine
    new_version=`curl -s https://api.github.com/repos/caddyserver/caddy/releases/latest | grep 'tag_name' | cut -d\" -f4`
    old_version=`caddy version | cut -d" " -f1`
    echo -e "\n===== Caddy =====\n"
}

get_version_filebrowser(){
    object="/usr/local/bin/filebrowser"
    determine
    new_version=`curl -s https://api.github.com/repos/Waitung/FileBrowser-DailyBuild/releases/latest | grep 'tag_name' | cut -d\" -f4`
    old_version=`filebrowser version | cut -d" " -f3 | cut -d/ -f1`
    echo -e "\n===== FileBwoser =====\n"
}

get_version_ariang(){
    object="/www/ariang"
    determine
    ariang_tag_name=`curl -s https://api.github.com/repos/mayswind/AriaNg/releases/latest | grep 'tag_name' | cut -d\" -f4`
    new_version="v${ariang_tag_name}"
    ariang_t=`cat /www/ariang/js/aria-ng-*.min.js`
    old_version=`echo ${ariang_t#*buildVersion:\"} | cut -d\" -f1`
    echo -e "\n===== AriaNG =====\n"
}

get_version_cloudreve(){
    object="/usr/local/bin/cloudreve"
    determine
    cloudreve_tag_name=`curl -s https://api.github.com/repos/cloudreve/Cloudreve/releases/latest | grep 'tag_name' | cut -d\" -f4`
    new_version="v${cloudreve_tag_name}"
    old_version="暂时没好的办法获取，请到网页查看"
    echo -e "\n===== Cloudreve =====\n"
}

update_caddy(){
    if  [ -n "${s_version}" ] ;then echo "因为插件原因，caddy不支持安装指定版本号。"; exit 0; fi
    rm -f /usr/local/bin/caddy.old
    mv /usr/local/bin/caddy /usr/local/bin/caddy.old
    wget -O /usr/local/bin/caddy 'https://caddyserver.com/api/download?os=linux&arch=amd64&p=github.com%2Fmholt%2Fcaddy-webdav'
    chown root:root /usr/local/bin/caddy
    chmod 755 /usr/local/bin/caddy
    systemctl restart caddy
    systemctl status caddy -l
    get_date
    echo "${date_n}：Caddy 更新完毕" >> ~/update.log
    echo -e "\n ----- ----- ----- ----- ----- \n ${date_n}：Caddy 更新完毕"
}

update_filebrowser(){
    if  [ -n "${s_version}" ] ;then new_version=${s_version}; fi
    rm -f /usr/local/bin/filebrowser.old
    mv /usr/local/bin/filebrowser /usr/local/bin/filebrowser.old
    wget https://github.com/Waitung/FileBrowser-DailyBuild/releases/download/${new_version}/linux-amd64-filebrowser.zip
    unzip linux-amd64-filebrowser.zip -d /usr/local/bin
    chown root:root /usr/local/bin/filebrowser
    chmod 755 /usr/local/bin/filebrowser
    rm -f linux-amd64-filebrowser.zip
    systemctl restart filebrowser
    systemctl status filebrowser -l
    get_date
    echo "${date_n}：FileBrowser 更新完毕" >> ~/update.log
    echo -e "\n ----- ----- ----- ----- ----- \n ${date_n}：FileBrowser 更新完毕"
}

update_ariang(){
    if  [ -n "${s_version}" ] ;then ariang_tag_name=${s_version}; fi
    rm -rf /www/ariang
    wget https://github.com/mayswind/AriaNg/releases/download/${ariang_tag_name}/AriaNg-${ariang_tag_name}.zip
    unzip AriaNg-${ariang_tag_name}.zip -d /www/ariang
    rm -f AriaNg-${ariang_tag_name}.zip
    get_date
    echo "${date_n}：AriaNG 更新完毕" >> ~/update.log
    echo -e "\n ----- ----- ----- ----- ----- \n ${date_n}：AriaNG 更新完毕"
}

update_cloudreve(){
    if  [ -n "${s_version}" ] ;then cloudreve_tag_name=${s_version}; fi
    rm -f /usr/local/bin/cloudreve.old
    mv /usr/local/bin/cloudreve /usr/local/bin/cloudreve.old
    wget https://github.com/cloudreve/Cloudreve/releases/download/${cloudreve_tag_name}/cloudreve_${cloudreve_tag_name}_linux_amd64.tar.gz
    tar -xzvf cloudreve_${cloudreve_tag_name}_linux_amd64.tar.gz -C /usr/local/bin
    rm -rf cloudreve_${cloudreve_tag_name}_linux_amd64.tar.gz
    chown root:root /usr/local/bin/cloudreve
    chmod 755 /usr/local/bin/cloudreve
    systemctl restart cloudreve
    systemctl status cloudreve -l
    get_date
    echo "${date_n}：Cloudreve 更新完毕" >> ~/update.log
    echo -e "\n ----- ----- ----- ----- ----- \n ${date_n}：Cloudreve 更新完毕"
}

run
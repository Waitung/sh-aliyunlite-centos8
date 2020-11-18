#!/bin/bash

url_repo="https://github.com/Waitung/sh-aliyunlite-centos8/raw/main"

check_root(){
    if [ "${UID}" -ne '0' ]; then
        echo "错误：必须以root用户运行此脚本！"
        exit 1
    fi
}

check_linux(){
    if [ $(uname) != 'Linux' ]; then
        echo "错误：这不是Linux！请在CentOS 8 x64上运行此脚本！"
        exit 1
    fi
}

check_os(){
    if [ -z $(grep -i 'CentOS-8' /etc/os-release) ]; then
        echo "错误：这不是CentOS 8！请在CentOS 8 x64上运行此脚本！"
        exit 1
    fi
}

check_machine(){
    if [ $(uname -m) != 'x86_64' -a $(uname -m) != 'amd64' ]; then
        echo "错误：这不是amd64！请在CentOS 8 x64上运行此脚本！"
        exit 1
    fi
}

check_selinux(){
    if [ $(getenforce) != 'Disabled' ]; then
        echo "错误：selinux处于开启状态！"
        while true; do
            read -p "是否关闭selinux并重启系统！[Y/n]" -n 1 yn
            case ${yn} in
                y | Y ) echo -e "\n确定关闭并重启系统！"; sed -i 's/^SELINUX=\(enforcing\|permissive\)/SELINUX=disabled/g' /etc/selinux/config; reboot; break;;
                n | N ) echo -e "\n已经退出脚本！"; exit 0;;
                * ) echo -e "\n请输入 \033[31mY\033[0m 或者 \033[31mn\033[0m";;
            esac
        done
    fi
}

check_sh(){
    if [ ! -d ~/sh ]; then
        mkdir ~/sh
        curl -Ls ${url_repo}/menu.sh -o ~/sh/menu.sh
        chmod 755 ~/sh/menu.sh
    fi   
    if [ ! -e /usr/local/bin/menu ]; then
        echo "#!/bin/bash" > /usr/local/bin/menu
        echo "~/sh/menu.sh" >> /usr/local/bin/menu
        chmod 755 /usr/local/bin/menu
    fi
}

check_env(){
    check_root
    check_linux
    check_os
    check_machine
    check_selinux
    check_sh
}

main(){
    check_env
    choose
    run "${name[@]}"
}

choose(){
    readme="
    ========== ========== ==========
    阿里云轻量 CentOS 8.2 自用脚本
    ----- ----- ----- ----- -----
    选择一个执行。
        ----- ----- -----
        0.更新脚本
        ----- ----- -----
        1.执行升级脚本
        2.执行安装脚本       
        ----- ----- -----
        3.修改 AriaNG
        4.升级 aria2 bt-tracker
    ========== ========== =========="
    echo -e "${readme}"
    while true; do
        read -p "输入数字：" -n 1 choose
        echo -e "\n ----- ----- -----"
        case "${choose}" in
            0 ) name=(menu update install modify-ariang update-tracker); break;;
            1 ) name=(update); break;;
            2 ) name=(install); break;;
            3 ) name=(modify-ariang); break;;
            4 ) name=(update-tracker); break;;
            * ) echo -e "\n 输入正确的数字 \n";;
        esac
    done
}

run(){
    while [ -n "$1" ]; do
        if [ ${choose} -eq 0 ]; then
            if [ -e ~/sh/$1.sh ]; then curl -Ls ${url_repo}/$1.sh -o ~/sh/$1.sh; echo "$1.sh 更新完毕"; fi
        else
            if [ ! -e ~/sh/$1.sh ]; then curl -Ls ${url_repo}/$1.sh -o ~/sh/$1.sh; chmod 755 ~/sh/$1.sh; fi
            ~/sh/$1.sh
        fi
        shift
    done
}

main
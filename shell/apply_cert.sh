#!/bin/bash

# Colorful echo
RED="31m"    # Error message
GREEN="32m"  # Success message
YELLOW="33m" # Warning message
BLUE="36m"   # Info message
colorEcho() {
	echo -e "\033[${1}${@:2}\033[0m" 1>&2
}

# Obtain system release
if [[ -f /etc/redhat-release ]]; then
	release="centos"
	systemPackage="yum"
	systempwd="/usr/lib/systemd/system/"
elif cat /etc/issue | grep -Eqi "debian"; then
	release="debian"
	systemPackage="apt-get"
	systempwd="/lib/systemd/system/"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
	release="ubuntu"
	systemPackage="apt-get"
	systempwd="/lib/systemd/system/"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
	release="centos"
	systemPackage="yum"
	systempwd="/usr/lib/systemd/system/"
elif cat /proc/version | grep -Eqi "debian"; then
	release="debian"
	systemPackage="apt-get"
	systempwd="/lib/systemd/system/"
elif cat /proc/version | grep -Eqi "ubuntu"; then
	release="ubuntu"
	systemPackage="apt-get"
	systempwd="/lib/systemd/system/"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
	release="centos"
	systemPackage="yum"
	systempwd="/usr/lib/systemd/system/"
fi

apply_cert() {
	colorEcho ${BLUE} "正在关闭nginx，请稍后"
	systemctl stop nginx

	colorEcho ${BLUE} "请输入域名"
	read YOUR_DOMAIN

	~/.acme.sh/acme.sh --issue -d ${YOUR_DOMAIN} --standalone
	if
		
		exit 1 
	fi
	CERT_PATH=/usr/src/web_cert/${YOUR_DOMAIN}
	mkdir -p ${CERT_PATH}

	~/.acme.sh/acme.sh --installcert -d ${YOUR_DOMAIN} \
	--key-file ${CERT_PATH}/private.key \
	--fullchain-file ${CERT_PATH}/fullchain.cer
	
	if test -s ${CERT_PATH}/fullchain.cer; then
		colorEcho ${echo} "Application approved. "
	else
		colorEcho ${RED} "证书申请失败"
	fi

	systemctl start nginx
}

main() {
	clear
	colorEcho ${BLUE} " 1. 安装证书工具"
	colorEcho ${BLUE} " 2. 申请证书"
	colorEcho ${BLUE} " 0. 退出脚本"
	read -p "请输入数字:" num
	case "$num" in
	1)
		curl https://get.acme.sh | sh
		$systemPackage -y install socat

		;;
	2)
		apply_cert
		;;
	0)
		exit 1
		;;
	*)
		clear
		colorEcho ${RED} "请输入正确数字"
		sleep 1s
		main
		;;
	esac
}

main

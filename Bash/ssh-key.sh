#!/bin/bash
# PS: 禁用Root账户登录并使用SSH-KEY密钥进行配对登录
# Time: 2024年5月29日

# 定义SSH公钥
ssh_key="ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAYEAv8ySwgI+z3KNAz/CanO3g/1fh+RjyfKQMpqv2Yrym08Dkm3qfWJVU5Hr2mOvMoSioR/CQOCu8wKpFOCp7c7C9brmS8bTwjSUCEmSGLc2FDweK6yRknzw/6d8gTjdCG/JPGUD2Q8ENzdcAqQRRFN3frTpRSB4aH+Cr1fqeu8g5ZkK43fW16ZxrT1HoF1e4pUmpM8xIpMHncsS3prsKTqdQ0bSUZ77i8BFcDXvqv8waRQNgoCksiESTPR7BUZ9lWMT8RS0VYYXrl8SodpkBPvqaz5w9xTe3h9/vcSAdwwejrHymD91pHMbt0eypMd0GAkald0fzW7LdfLNtbbIPB/CEue6Hc3kDseopft8uOLsPWrR2I+sQ+RXIn2SOTXYTM4X+XBCcxf3mrjktQVYAd+/gHZU2NUCVv01fx5Jo3rQ+tZ5L3khPfsVMOBiwNTK+bNwGdAMi8Y+Sz+z17CXOKxiPS91mDUa1JfiTm3fFxtLbWIAyiLi0wDszUU0agQLHm1h"

# 创建 .ssh 目录并设置权限，如果不存在的话
[ ! -d ~/.ssh ] && mkdir -m 700 ~/.ssh

# 备份并更新 authorized_keys 文件
[ -f ~/.ssh/authorized_keys ] && mv ~/.ssh/authorized_keys ~/.ssh/authorized_keys-$(date +%s).bak
echo "$ssh_key" > ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys

# 更新 sshd_config 文件
if [ -f /etc/ssh/sshd_config ]; then
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
    sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

    # 重启 SSH 服务
    if command -v systemctl &>/dev/null; then
        systemctl restart sshd
    elif command -v service &>/dev/null; then
        service sshd restart
    else
        echo -e "\e[31m无法重启 SSH 服务，请手动重启。\e[0m"
    fi
else
    echo -e "\e[31m未找到 sshd_config 文件，请手动检查并配置 SSH 服务。\e[0m"
fi

echo -e "\e[33mSSH 配置已更新，已禁用密码登录和Root账户登录，只允许公钥认证登录。\e[0m"
#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# 官方文档：https://docs.gitlab.com/ee/install/docker.html

init_var() {
  ECHO_TYPE="echo -e"

  GITLAB_DATA="/jydata/gitlab/"
  GITLAB_CONFIG="${GITLAB_DATA}config/"
  GITLAB_LOG="${GITLAB_DATA}logs/"
  GITLAB_OPT="${GITLAB_DATA}opt/"
  gitlab_ip="jy-gitlab"
  gitlab_http_port=80
  gitlab_https_port=443
  gitlab_ssh_port=22
}

echo_content() {
  case $1 in
  "red")
    ${ECHO_TYPE} "\033[31m$2\033[0m"
    ;;
  "green")
    ${ECHO_TYPE} "\033[32m$2\033[0m"
    ;;
  "yellow")
    ${ECHO_TYPE} "\033[33m$2\033[0m"
    ;;
  "blue")
    ${ECHO_TYPE} "\033[34m$2\033[0m"
    ;;
  "purple")
    ${ECHO_TYPE} "\033[35m$2\033[0m"
    ;;
  "skyBlue")
    ${ECHO_TYPE} "\033[36m$2\033[0m"
    ;;
  "white")
    ${ECHO_TYPE} "\033[37m$2\033[0m"
    ;;
  esac
}

mkdir_tools() {
  mkdir -p ${GITLAB_DATA}
  mkdir -p ${GITLAB_CONFIG}
  mkdir -p ${GITLAB_LOG}
  mkdir -p ${GITLAB_OPT}
}

install_gitlab() {
  if [[ -z $(docker ps -q -f "name=^${gitlab_ip}$") ]]; then
    echo_content green "---> 安装GitLab"

    read -r -p "请输入GitLab的HTTP端口(默认:80): " gitlab_http_port
    [[ -z "${gitlab_http_port}" ]] && gitlab_http_port=80
    read -r -p "请输入GitLab的HTTPS端口(默认:443): " gitlab_https_port
    [[ -z "${gitlab_https_port}" ]] && gitlab_https_port=443
    read -r -p "请输入GitLab的SSH端口(默认:22): " gitlab_ssh_port
    [[ -z "${gitlab_ssh_port}" ]] && gitlab_ssh_port=22

    docker pull gitlab/gitlab-ce:15.11.11-ce.0 &&
      docker run -d --name ${gitlab_ip} --restart always \
        -e TZ=Asia/Shanghai \
        -p ${gitlab_http_port}:80 \
        -p ${gitlab_https_port}:443 \
        -p ${gitlab_ssh_port}:22 \
        -v ${GITLAB_CONFIG}gitlab.rb:/etc/gitlab/gitlab.rb \
        -v ${GITLAB_LOG}:/var/log/gitlab \
        -v ${GITLAB_OPT}:/var/opt/gitlab \
        gitlab/gitlab-ce:15.11.11-ce.0

    if [[ -n $(docker ps -q -f "name=^${gitlab_ip}$") ]]; then
      gitlab_password=$(docker exec cat ${GITLAB_CONFIG}initial_root_password)
      echo_content skyBlue "---> GitLab安装完成"
      echo_content yellow "---> GitLab的用户号名(请妥善保存): root"
      echo_content yellow "---> GitLab的密码(请妥善保存): ${gitlab_password}"
    else
      echo_content red "---> GitLab安装失败或运行异常,请尝试修复或卸载重装"
      exit 1
    fi
  else
    echo_content skyBlue "---> 你已经安装了GitLab"
  fi
}

cd "$HOME" || exit 0
init_var
mkdir_tools
clear
install_docker
install_gitlab

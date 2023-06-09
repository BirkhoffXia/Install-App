#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

init_var() {
  ECHO_TYPE="echo -e"

  GITLAB_DATA="/jsdata/gitlab/"
  GITLAB_CONFIG="/jsdata/gitlab/config/"
  GITLAB_LOG="/jsdata/gitlab/logs/"
  GITLAB_OPT="/jsdata/gitlab/opt/"
  gitlab_ip="js-gitlab"
  gitlab_http_port=8080
  gitlab_https_port=8443
  gitlab_ssh_port=8022
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

    read -r -p "请输入GitLab的HTTP端口(默认:8080): " gitlab_http_port
    [[ -z "${gitlab_http_port}" ]] && gitlab_http_port=8080
    read -r -p "请输入GitLab的HTTPS端口(默认:8443): " gitlab_https_port
    [[ -z "${gitlab_https_port}" ]] && gitlab_https_port=8443
    read -r -p "请输入GitLab的SSH端口(默认:8022): " gitlab_ssh_port
    [[ -z "${gitlab_ssh_port}" ]] && gitlab_ssh_port=8022

    docker pull gitlab/gitlab-ce:15.9.3-ce.0 &&
      docker run -d --name ${gitlab_ip} --restart always \
        --network=js-network \
        -v ${GITLAB_CONFIG}:/etc/gitlab \
        -v ${GITLAB_LOG}:/var/log/gitlab \
        -v ${GITLAB_OPT}:/var/opt/gitlab \
        -e GITLAB_HTTP_PORT=${gitlab_http_port} \
        -e GITLAB_HTTPS_PORT=${gitlab_https_port} \
        -e GITLAB_SSH_PORT=${gitlab_ssh_port} \
        -e TZ=Asia/Shanghai \
        gitlab/gitlab-ce:15.9.3-ce.0

    if [[ -n $(docker ps -q -f "name=^${gitlab_ip}$") ]]; then
      echo_content skyBlue "---> GitLab安装完成"
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
clear
install_docker
install_gitlab

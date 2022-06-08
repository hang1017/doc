#!/bin/bash
# ZCM 构建脚本
set -eo pipefail
set -x

export LANG=en_US.UTF-8

# 输出时间以便观察各步骤耗时
date --rfc-3339=seconds

# 预装的 nodejs, yarn 版本较旧，删除并重新安装
unset NODE_PATH NODE_HOME
rm -rf /usr/local/bin/node /usr/local/bin/npm

# yum install -y http://gitlab.iwhalecloud.com/rlc/cicd/raw/master/files/nodejs-latest.rpm
# yum install -y http://gitlab.iwhalecloud.com/bianjp/static/raw/master/files/nodejs-latest.rpm
# yum install -y http://gitlab.iwhalecloud.com/bianjp/static/raw/master/files/yarn-latest.rpm
#curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo
yum install git -y
#yum install -y yarn

date --rfc-3339=seconds

# 淘宝镜像比内网镜像更快
# yarn config set http://npm.iwhalecloud.com:8081/repository/npm-all/
# npm config set http://npm.iwhalecloud.com:8081/repository/npm-all/
yarn config set registry https://registry.npm.taobao.org --global
yarn config set disturl https://npm.taobao.org/dist --global
#npm config set registry http://registry.npm.taobao.org
#npm install -g cordova
# ZCM 尚未提供 npm, yarn 缓存，借用一下 maven 缓存目录
if [[ -d "$MAVEN_LOCAL_REPOS_CACHE" ]]; then
    yarn config set cache-folder "$MAVEN_LOCAL_REPOS_CACHE/yarn"
    npm config set cache "$MAVEN_LOCAL_REPOS_CACHE/npm"
fi

# CI 镜像预装的 nodejs 配置有问题
# npm config set user $(id -u)

date --rfc-3339=seconds
#yarn global add cordova
yarn install
date --rfc-3339=seconds
set +eo pipefail
yarn build || true
date --rfc-3339=seconds

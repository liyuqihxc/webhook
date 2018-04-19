#!/bin/bash

WEB_USER="root"
WEB_USERGROUP="root"
BRANCH_NAME=
URL=
TARGET_DIR=
SUB_SCRIPT=

show_help() {
  echo ""
  echo "下载指定仓库的代码到本地并运行部署脚本。"
  echo "作者liyuqihxc，版本0.0.1"
  echo "Usage:"
  echo "  $(basename $0) [options]"
  echo ""
  echo "Options:"
  echo "  -h, --help          显示帮助信息并退出"
  echo "  -b, --branch-name   分支名。可选，默认为master"
  echo "  -u, --url           仓库Url"
  echo "  -t, --target-dir    目标路径"
  echo "  -s, --sub-script    部署脚本路径"
  echo ""
  echo "Example:"
  echo "  $(basename $0) -b master -u ssh://git@localhost/example.git -t /www/example -s ./deploy.sh"
  echo ""
  exit 1
}

git_clone() {
  echo "mkdir $TARGET_DIR"
  mkdir -p $TARGET_DIR
  git clone -b $BRANCH_NAME $URL --single-branch $TARGET_DIR
  echo "changing permissions... "$WEB_USER":"$WEB_USERGROUP
  chown -R $WEB_USER:$WEB_USERGROUP $TARGET_DIR
}

git_checkout() {
  cd $TARGET_DIR
  echo "pulling source code..."
  git reset --hard origin/$BRANCH_NAME
  git clean -f
  git pull
  git checkout $BRANCH_NAME
}

ARGS=`getopt -a -o b:u:t:s:h -l branch-name:,url:,target-dir:,sub-script:,help -- "$@"`
[ $? -ne 0 ] && show_help
eval set -- "${ARGS}"
while true
do
  case "$1" in
    -b|--branch-name)
      BRANCH_NAME="$2"
      echo "b=$BRANCH_NAME"
      shift
      ;;
    -u|--url)
      URL="$2"
      echo "u=$URL"
      shift
      ;;
    -t|--target-dir)
      TARGET_DIR="$2"
      echo "t=$TARGET_DIR"
      shift
      ;;
    -s|--sub-script)
      SUB_SCRIPT="$2"
      echo "s=$SUB_SCRIPT"
      shift
      ;;
    -h|--help)
      show_help
      ;;
    --)
      shift
      break
      ;;
    esac

  shift
done

type git >/dev/null 2>&1 || { echo >&2 "找不到git的可执行文件，无法检出项目。"; exit 1; }

if [ -z "$BRANCH_NAME" ]; then
  echo "set \"master\" for default branch."
  BRANCH_NAME="master"
fi

if [ -z "$URL" -o -z "$TARGET_DIR" -o -z "$SUB_SCRIPT" ]; then
  echo >&2 "必须提供所有必须参数。"
  exit 1
fi

if [ ! -d $TARGET_DIR/.git ]; then
  git_clone
else
  git_checkout
fi

echo "Start deployment...."
source $SUB_SCRIPT
echo "Finished."

exit 1

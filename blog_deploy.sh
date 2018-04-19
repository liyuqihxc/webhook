#!/bin/bash

BASE_DIR="$1"
FRONT_DIR="myblog.front"
BACKEND_DIR="myblog.backend"

if [ ! -b $BASE_DIR ]
  echo >&2 "指定的文件夹 $ BASE_DIR 不存在。"
  exit 1
fi

type dotnet >/dev/null 2>&1 || { echo >&2 "找不到dotnet的可执行文件，无法部署项目。"; exit 1; }

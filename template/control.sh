#!/bin/bash

echo '
########################################################

control.sh 使用提示:
  ----for 本地----
  运行 ./control.sh debug   启动调试
  运行 ./control.sh gozero  重新生成工程脚手架
  运行 ./control.sh swagger 生成swagger文档

  ----for 线上----
  运行 ./control.sh pack    编译打包，生成app.tar.gz
  运行 ./control.sh docker  启动容器运行
  运行 ./control.sh start   启动服务-非容器运行 (日志存于/var/log)
  运行 ./control.sh stop    停止服务-非容器运行
  运行 ./control.sh restart 重启服务-非容器运行
  运行 ./control.sh status  查看服务运行状态-非容器运行

########################################################
'

project='template'
image="$project:latest"
maingo="$project.go"
apipath="api/$project.api"
app=$project
pidfile="/var/run/$app.pid"
logfile="/var/log/$app.log"

function debug() {
  if [ -f $maingo ]; then
    go run $maingo
  fi

  return 0
}

function docker_() {
  docker ps >> /dev/null
  if [ $? -gt 0 ]; then
    return 1
  fi

  if [ $(docker ps | grep $app | wc -l | tr -s ' ') -gt 0 ]; then
      docker rm -f $app
  fi

  docker build -t $image .
  if [ $? -gt 0 ]; then
    echo "docker build failed..."
    return 1
  fi

  docker run -d -p 8880:8888 --name $app $image
  if [ $? -gt 0 ]; then
    echo "docker run failed..."
    return 1
  fi

  return 0
}

function pack() {
  if [ -f $maingo ]; then
    echo '正在编译...'

    mkdir -p app

    CGO_ENABLED=0 GOARCH=amd64 GOOS=linux go build -mod vendor -o app/$app $maingo
    if [ $? -gt 0 ]; then
      echo "go build failed..."
      return 1
    fi

    echo '正在打包...'

    cp -fr ./etc app/etc
    cp -fr ./.env_online app/.env
    cp -fr ./control.sh app/control.sh
    tar zcf app.tar.gz app
    rm -fr ./app

    if [ -f ./app.tar.gz ]; then
      echo '已打包完成...'
      echo '文件位置：./app.tar.gz'
      echo `md5 ./app.tar.gz`
    else
      echo '编译打包失败...'
      return 1
    fi
  fi

  return 0
}

function gozero() {
  if [ -f $apipath ]; then
    goctl api go -api $apipath -dir . -style go_zero
    return 0
  fi

  return 1
}

function swagger() {
  if [ -f $apipath ]; then
    goctl api plugin -plugin goctl-swagger="swagger -filename swagger.json" -api $apipath -dir .
    return 0
  fi

  return 1
}


function check_pid() {
  if [ -f $pidfile ]; then
    pid=`cat $pidfile`
    if [ $pid -gt 0 ]; then
      running=`ps -p $pid | grep -v "PID TTY" | wc -l`
      return $running
    fi
  else
    echo "$pidfile not found..."
  fi

  return 1
}

function start() {
  check_pid
  running=$?
  if [ $? -gt 0 ]; then
    echo -n "$app now is running already, pid="
    cat $pidfile
    return 1
  fi

  nohup ./$app >> $logfile 2>&1 &

  echo $! > $pidfile

  echo "$app started... pid=$!"

  return 0
}

function stop() {
  pid=`cat $pidfile`
  if [ $pid -gt 0 ]; then
    kill -9 $pid >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      echo "$app stoped... pid=$pid"
      return 0
    fi
  fi

  return 1
}

function restart() {
    stop
    sleep 1
    start
}

function status() {
    check_pid
    if [ $? -gt 0 ]; then
      echo "$app is running..."
    else
      echo "$app is stoped..."
    fi
}

case $1 in
  debug)
    debug
    ;;
  docker)
    docker_
    ;;
  pack)
    pack
    ;;
  gozero)
    gozero
    ;;
  swagger)
    swagger
    ;;
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    restart
    ;;
  status)
    status
    ;;
esac
#!/bin/bash
REPOSITORY=/home/ubuntu
PROJECT_NAME=demo

cd $REPOSITORY/$PROJECT_NAME/

echo "> Git Pull"
git pull

echo "> step1 디렉토리로 이동"
cd $REPOSITORY

echo "> Build 파일 복사"
cp $REPOSITORY/$PROJECT_NAME/target/*.jar $REPOSITORY/

echo "> 현재 구동중인 애플리케이션 pid 확인"
CURRENT_PID=$(pgrep -f ${PROJECT_NAME}.jar)

echo "현재 구동 중인 애플리케이션 pid: $CURRENT_PID"
if [ -z "$CURRENT_PID" ]; then
        echo "> 현재 구동 중인 애플리케이션이 없으므로 종료하지 않습니다."
else
        echo "> kill -15 $CURRENT_PID"
        kill -15 $CURRENT_PID
        sleep 5
fi

echo "> 새 애플리케이션 배포"
JAR_NAME=$(ls -tr $REPOSITORY/*.jar | grep -v "plain" | tail -n 1)

echo "> JAR Name: $JAR_NAME"
nohup java -Xms512m -Xmx1024m -jar $JAR_NAME > $REPOSITORY/nohup.out 2>&1 &
#!/bin/bash

JAR_NAME="flink-1.0-SNAPSHOT.jar"
CONTAINER_NAME="flink_jobmanager"
LOCAL_JAR_PATH="build/libs/$JAR_NAME"
DOCKER_JAR_PATH="/tmp/$JAR_NAME"

JOB_INPUT=$1
if [ -z "$JOB_INPUT" ]; then
    JOB_NAME="KafkaIngestionJob"
else
    JOB_NAME=$JOB_INPUT
fi

MAIN_CLASS="com.tuancao.job.$JOB_NAME"

echo "🚀 Bắt đầu quy trình triển khai cho $JAR_NAME..."
echo "📍 Job mục tiêu: $MAIN_CLASS"

./gradlew clean shadowJar
if [ $? -ne 0 ]; then
    echo "❌ Build thất bại!"
    exit 1
fi

echo "🚚 Đang copy file vào $CONTAINER_NAME..."
docker cp "$LOCAL_JAR_PATH" "$CONTAINER_NAME":"$DOCKER_JAR_PATH"

echo "🔍 Đang kiểm tra xem $JOB_NAME có đang chạy không..."
OLD_JOB_ID=$(docker exec "$CONTAINER_NAME" flink list | grep "$JOB_NAME" | awk '{print $4}')

if [ ! -z "$OLD_JOB_ID" ]; then
    echo "🛑 Đang dừng Job cũ ID: $OLD_JOB_ID"
    docker exec "$CONTAINER_NAME" flink cancel "$OLD_JOB_ID"
fi

echo "🌟 Khởi chạy Job $JOB_NAME..."
docker exec -d "$CONTAINER_NAME" flink run \
    -c "$MAIN_CLASS" \
    "$DOCKER_JAR_PATH"

echo "✅ Triển khai hoàn tất!"
echo "----------------------------------------------------"
echo "📊 Kiểm tra danh sách Job: docker exec -it $CONTAINER_NAME flink list"
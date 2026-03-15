#!/bin/bash

# --- Cấu hình ---
JAR_NAME="flink-1.0-SNAPSHOT.jar"
CONTAINER_NAME="flink_jobmanager"
LOCAL_JAR_PATH="build/libs/$JAR_NAME"
DOCKER_JAR_PATH="/tmp/$JAR_NAME"

# Danh sách các Job muốn chạy (Tên class trong package com.tuancao.job)
JOBS=("KafkaIngestionJob" "KafkaToElasticsearchJob")

echo "🚀 Bắt đầu quy trình đóng gói..."

# 1. Build ShadowJar (Dùng chung cho tất cả các Job)
./gradlew clean shadowJar
if [ $? -ne 0 ]; then
    echo "❌ Build thất bại!"
    exit 1
fi

# 2. Copy JAR vào Container
echo "🚚 Đang copy file vào $CONTAINER_NAME..."
docker cp "$LOCAL_JAR_PATH" "$CONTAINER_NAME":"$DOCKER_JAR_PATH"

# 3. Lặp qua danh sách Job để Cancel cũ và Run mới
for JOB_NAME in "${JOBS[@]}"; do
    MAIN_CLASS="com.tuancao.job.$JOB_NAME"
    echo "----------------------------------------------------"
    echo "📍 Đang xử lý Job: $JOB_NAME"

    # Kiểm tra và dừng Job cũ nếu đang chạy
    OLD_JOB_ID=$(docker exec "$CONTAINER_NAME" flink list | grep "$JOB_NAME" | awk '{print $4}')
    if [ ! -z "$OLD_JOB_ID" ]; then
        echo "🛑 Đang dừng Job cũ ID: $OLD_JOB_ID"
        docker exec "$CONTAINER_NAME" flink cancel "$OLD_JOB_ID"
    fi

    # Khởi chạy Job mới ở chế độ Detached (-d) để script không bị treo
    echo "🌟 Khởi chạy Job $JOB_NAME..."
    docker exec "$CONTAINER_NAME" flink run -d \
        -c "$MAIN_CLASS" \
        "$DOCKER_JAR_PATH"
done

echo "----------------------------------------------------"
echo "✅ Tất cả Jobs đã được triển khai!"
echo "📊 Kiểm tra Dashboard tại: http://localhost:8082"
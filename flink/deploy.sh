#!/bin/bash

# --- Cấu hình ---
# Lưu ý: Kiểm tra xem Gradle xuất ra file tên gì (thường là -all.jar nếu dùng shadow)
JAR_NAME="flink-1.0-SNAPSHOT.jar"
CONTAINER_NAME="flink_jobmanager"
LOCAL_JAR_PATH="build/libs/$JAR_NAME"
DOCKER_JAR_PATH="/tmp/$JAR_NAME"

# SỬA: Xóa dấu phẩy giữa các phần tử
JOBS=("KafkaIngestionJob" "KafkaToElasticsearchJob" "KafkaToPostgresJob")

echo "🚀 Bắt đầu quy trình đóng gói..."

# 1. Build ShadowJar
./gradlew clean shadowJar
if [ $? -ne 0 ]; then
    echo "❌ Build thất bại!"
    exit 1
fi

# Kiểm tra file tồn tại trước khi copy
if [ ! -f "$LOCAL_JAR_PATH" ]; then
    echo "❌ Không tìm thấy file JAR tại $LOCAL_JAR_PATH. Kiểm tra lại thư mục build/libs"
    exit 1
fi

# 2. Copy JAR vào Container
echo "🚚 Đang copy file vào $CONTAINER_NAME..."
docker cp "$LOCAL_JAR_PATH" "$CONTAINER_NAME":"$DOCKER_JAR_PATH"

# 3. Lặp qua danh sách Job
for JOB_NAME in "${JOBS[@]}"; do
    # Loại bỏ khoảng trắng hoặc ký tự thừa nếu có
    JOB_NAME=$(echo $JOB_NAME | xargs)
    MAIN_CLASS="com.tuancao.job.$JOB_NAME"

    echo "----------------------------------------------------"
    echo "📍 Đang xử lý Job: $JOB_NAME"

    # Lấy ID của Job đang chạy (grep chính xác tên class hoặc tên Job)
    # Cải tiến lệnh grep để bắt đúng ID
    OLD_JOB_ID=$(docker exec "$CONTAINER_NAME" flink list | grep "RUNNING" | grep "$JOB_NAME" | awk '{print $4}')

    if [ ! -z "$OLD_JOB_ID" ]; then
        echo "🛑 Đang dừng Job cũ ID: $OLD_JOB_ID"
        docker exec "$CONTAINER_NAME" flink cancel "$OLD_JOB_ID"
    fi

    # Khởi chạy Job mới
    echo "🌟 Khởi chạy Job $JOB_NAME..."
    docker exec "$CONTAINER_NAME" flink run -d \
        -c "$MAIN_CLASS" \
        "$DOCKER_JAR_PATH"
done

echo "----------------------------------------------------"
echo "✅ Tất cả Jobs đã được triển khai!"
echo "📊 Kiểm tra Dashboard tại: http://localhost:8082"
import psycopg2
import json
import os

CONFIG_FILE = "database_config.json"

def get_db_params():
    if not os.path.exists(CONFIG_FILE):
        print(f"Lỗi: Không tìm thấy file {CONFIG_FILE}")
        return None

    with open(CONFIG_FILE, 'r') as f:
        config = json.load(f)

    return config.get("db_datamanagement_test")

def run_cleanup():
    params = get_db_params()
    if not params:
        return

    # Danh sách các câu lệnh DROP để dọn dẹp sạch sẽ
    cleanup_queries = [
        "DROP SCHEMA IF EXISTS sale CASCADE;",
        "DROP SCHEMA IF EXISTS customer CASCADE;",
        "DROP SCHEMA IF EXISTS store CASCADE;",
        "DROP SCHEMA IF EXISTS product CASCADE;",
        "DROP TABLE IF EXISTS geography CASCADE;",
        "DROP FUNCTION IF EXISTS update_modified_column();"
    ]

    conn = None
    try:
        print(f"Đang kết nối tới database: {params['database']} ({params['host']})...")
        # Lưu ý: Nếu chạy từ Mac, đảm bảo host trong JSON là 'localhost'
        conn = psycopg2.connect(**params)
        cur = conn.cursor()

        print("🧹 Đang thực hiện dọn dẹp toàn bộ Schema...")

        for query in cleanup_queries:
            cur.execute(query)
            print(f" Đã thực thi: {query.split('CASCADE')[0].strip()}")

        conn.commit()
        print("\n✨ CHÚC MỪNG: Database hiện tại đã sạch bóng (Cleaned)!")

    except Exception as e:
        print(f"Lỗi trong quá trình dọn dẹp: {e}")
        if conn:
            conn.rollback()
    finally:
        if conn:
            cur.close()
            conn.close()

if __name__ == "__main__":
    run_cleanup()
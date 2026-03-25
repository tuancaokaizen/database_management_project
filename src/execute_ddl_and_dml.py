import psycopg2
import json
import os

CONFIG_FILE = "database_config.json"
DDL_PATH = os.path.join("postgres_ddl", "create_schema_and_table.sql")
DML_PATH = os.path.join("postgres_ddl", "import_postgre.sql")


def load_db_config():
    if not os.path.exists(CONFIG_FILE):
        print(f"Lỗi: Không tìm thấy file {CONFIG_FILE}")
        return None

    with open(CONFIG_FILE, 'r') as f:
        config = json.load(f)
    return config.get("db_datamanagement_test")


def execute_sql_file(cur, file_path):
    if not os.path.exists(file_path):
        print(f"Cảnh báo: Không tìm thấy file {file_path}")
        return False

    with open(file_path, 'r', encoding='utf-8') as f:
        sql_content = f.read()
        if sql_content.strip():
            cur.execute(sql_content)
            return True
    return False


def check_master_data_exists(cur):
    master_tables = [
        ("public", "geography"),
        ("product", "product"),
        ("store", "store"),
        ("customer", "customer")
    ]
    try:
        for schema, table in master_tables:
            cur.execute(f"""
                SELECT EXISTS (
                    SELECT FROM information_schema.tables 
                    WHERE table_schema = '{schema}' AND table_name = '{table}'
                );
            """)
            if cur.fetchone()[0]:
                cur.execute(
                    f"SELECT COUNT(*) FROM {schema}.{table}" if schema != 'public' else f"SELECT COUNT(*) FROM {table}")
                if cur.fetchone()[0] > 0:
                    print(f"Đã tìm thấy dữ liệu trong {schema}.{table}")
                    return True
        return False
    except Exception:
        return False


def main():
    conn = None
    try:
        db_params = load_db_config()
        if not db_params:
            return

        print(f"Đang kết nối đến Database: {db_params['database']} ({db_params['host']})...")
        conn = psycopg2.connect(**db_params)
        cur = conn.cursor()

        print(f"Thực thi DDL từ {DDL_PATH}...")
        if execute_sql_file(cur, DDL_PATH):
            conn.commit()
            print("Đã cập nhật cấu trúc Schema.")

        if not check_master_data_exists(cur):
            print(f"Hệ thống trống. Đang nạp dữ liệu từ {DML_PATH}...")
            if execute_sql_file(cur, DML_PATH):
                conn.commit()
                print("Đã hoàn tất nạp dữ liệu!")
        else:
            print("SKIP: Dữ liệu Master đã tồn tại. Không chạy file Import.")

    except Exception as e:
        print(f"Lỗi: {e}")
        if conn:
            conn.rollback()
    finally:
        if conn:
            cur.close()
            conn.close()


if __name__ == "__main__":
    main()

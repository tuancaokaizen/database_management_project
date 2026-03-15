import psycopg2
import random
import uuid
import json
from datetime import datetime, timedelta
from airflow.providers.postgres.hooks.postgres import PostgresHook

def generate_data(target_db='db_datamanagement_test'):
    config_file = '/opt/airflow/src/database_config.json'

    with open(config_file, 'r') as f:
        configs = json.load(f)
    db_params = configs.get(target_db)

    if not db_params:
        raise ValueError(f"Not found config {target_db}")

    print(f"Connecting to database: {db_params['database']} in Host: {db_params['host']}")

    try:
        conn = psycopg2.connect(**db_params)
        cur = conn.cursor()

        for i in range(1, 1000):
            order_id = str(uuid.uuid4())
            order_code = f"ORD-{random.randint(10000, 99999)}-{i}"
            shop_code = random.choice(['S001', 'S002', 'S003', 'S004', 'S005'])
            status = random.randint(1, 4)

            created_date = (datetime.now() - timedelta(days=random.randint(5, 10))).date()
            modified_date = datetime.now().date()
            transaction_date = created_date
            customer_code = f"C-{random.randint(100, 999)}"

            insert_query = """
                           INSERT INTO public.orders
                           ("OrderId", "OrderCode", "ShopCode", "OrderStatus", "CreatedDate", "ModifiedDate",
                            "TransactionDate", "CustomerCode")
                           VALUES (%s, %s, %s, %s, %s, %s, %s, %s) \
                           """

            record_to_insert = (order_id, order_code, shop_code, status, created_date, modified_date, transaction_date, customer_code)

            cur.execute(insert_query, record_to_insert)
            print(f"Đã chèn: {order_code}")

        conn.commit()
        print("--- 10 Rows have been synced to Postgres successfully ---")

    except Exception as error:
        print(f"Sync data errors: {error}")
        conn.rollback()
    finally:
        cur.close()

try:
    connection = psycopg2.connect(**conn_params)
    generate_data(connection)
except Exception as error:
    print(f"Can't connect to Postgres: {error}")
finally:
    if 'connection' in locals() and connection:
        connection.close()

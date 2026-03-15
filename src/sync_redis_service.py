import psycopg2
from psycopg2.extras import RealDictCursor
import redis
import json
import logging

def run_metadata_sync(config_path, db_key="db_datamanagement_test"):
    with open(config_path, 'r') as f:
        configs = json.load(f)

    pg_params = configs.get(db_key)

    conn = psycopg2.connect(
        host="postgres",
        database=pg_params['database'],
        user=pg_params['user'],
        password=pg_params['password'],
        port=pg_params['port']
    )

    r = redis.Redis(host='redis_cache', port=6379, decode_responses=True)
    cur = conn.cursor(cursor_factory=RealDictCursor)

    try:
        tables = [
            {"name": "Shop", "pk": "ShopCode", "redis_prefix": "shop"},
            {"name": "Product", "pk": "ItemCode", "redis_prefix": "product"},
            {"name": "Customer", "pk": "CustomerCode", "redis_prefix": "customer"}
        ]

        pipe = r.pipeline()

        for table in tables:
            table_name = table["name"]
            pk = table["pk"]
            prefix = table["redis_prefix"]

            cur.execute(f'SELECT * FROM public."{table_name}"')
            rows = cur.fetchall()

            if rows:
                pipe.delete(f"sync:{prefix}s")

                for row in rows:
                    code = str(row[pk]).strip()
                    pipe.sadd(f"sync:{prefix}s", code)

                    row_data = {k: str(v) if v is not None else "" for k, v in row.items()}
                    pipe.hset(f"{prefix}:info:{code}", mapping=row_data)

                pipe.execute()
                logging.info(f"Sync {len(rows)} docs from {table_name} to Redis Sucessfully.")

    except Exception as e:
        logging.error(f"Sync Errors: {e}")
        raise e
    finally:
        cur.close()
        conn.close()
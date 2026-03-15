import json
import uuid
import random
import psycopg2
from datetime import datetime
from psycopg2.extras import execute_values
from elasticsearch import Elasticsearch, helpers

CONFIG_PATH = '/opt/airflow/src/database_config.json'

def get_configs():
    with open(CONFIG_PATH, 'r') as f:
        return json.load(f)

def run_full_sync_pg_es(target_db):
    configs = get_configs()
    db_params = configs.get(target_db)
    es_params = configs.get("elasticsearch_config")

    conn = psycopg2.connect(**db_params)
    es = Elasticsearch(es_params['host'])
    cur = conn.cursor()

    try:
        cur.execute('SELECT "ShopCode" FROM public."Shop" WHERE "IsActive" = true')
        shops = [r[0].strip() for r in cur.fetchall()]
        cur.execute('SELECT "CustomerCode" FROM public."Customer"')
        customers = [r[0].strip() for r in cur.fetchall()]
        cur.execute('SELECT "ItemCode", "SellPrice" FROM public."Product"')
        products = [{"code": r[0].strip(), "price": r[1]} for r in cur.fetchall()]

        payloads_for_es = []
        pg_invoices = []
        pg_orders = []
        pg_items = []

        now = datetime.now()
        now_str = now.isoformat()

        for i in range(200):
            s_code = random.choice(shops)
            c_code = random.choice(customers)
            order_id = str(uuid.uuid4())
            order_code = f"ORD{s_code}{now.strftime('%y%m%d')}{str(i).zfill(5)}"
            inv_header = f"INV{str(i).zfill(7)}"

            order_items_nested = []
            for idx in range(random.randint(1, 3)):
                p = random.choice(products)
                item_id = str(uuid.uuid4())
                qty = random.randint(1, 5)

                order_items_nested.append({
                    "OrderItemId": item_id,
                    "ItemCode": p["code"],
                    "Price": p["price"],
                    "LineNum": idx + 1,
                    "Quantity": qty,
                    "IsPromotion": False,
                    "Unit": "Hộp"
                })

                pg_items.append((
                    item_id, order_code, p["code"], p["price"],
                    idx + 1, qty, False, "Hộp", now_str, now_str
                ))

            full_payload = {
                "OrderId": order_id,
                "OrderCode": order_code,
                "OrderStatus": 1,
                "ShopCode": s_code,
                "CustomerCode": c_code,
                "InvoiceHeader": inv_header,
                "CreatedDate": now_str,
                "ModifiedDate": now_str,
                "EInvoice": {
                    "Id": str(uuid.uuid4()),
                    "InvoiceHeader": inv_header,
                    "InvoiceSymbol": "1C26TY",
                    "InvoiceDate": now_str
                },
                "OrderItems": order_items_nested
            }
            payloads_for_es.append(full_payload)

            pg_invoices.append((
                full_payload["EInvoice"]["Id"], inv_header, "1C26TY", now_str, now_str, now_str
            ))
            pg_orders.append((
                order_id, order_code, 1, s_code, c_code, inv_header, now_str, now_str, 1, 1, 1
            ))

        execute_values(cur, """INSERT INTO public."EInvoice" VALUES %s ON CONFLICT DO NOTHING""", pg_invoices)
        execute_values(cur, """INSERT INTO public."Orders" VALUES %s ON CONFLICT DO NOTHING""", pg_orders)
        execute_values(cur, """INSERT INTO public."OrderItems" VALUES %s""", pg_items)

        conn.commit()
        print("Synced to Postgres successfully")

        actions = [
            {
                "_index": es_params['index_name'],
                "_id": p["OrderId"],
                "_source": p
            } for p in payloads_for_es
        ]
        helpers.bulk(es, actions)
        print(f"Synced {len(payloads_for_es)} docs to Elasticsearch.")

    except Exception as e:
        conn.rollback()
        print(f"System Error: {e}")
        raise e
    finally:
        cur.close()
        conn.close()

def task_sync_all_wrapper(target_db, **kwargs):
    run_full_sync_pg_es(target_db)
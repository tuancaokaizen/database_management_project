from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime
import sys

sys.path.insert(0, '/opt/airflow/src')
from orders_service import task_sync_all_wrapper

with DAG(
        'pharmacy_dual_sync_pg_and_es',
        start_date=datetime(2026, 3, 1),
        schedule_interval=None,
        catchup=False,
        tags=['postgres', 'elasticsearch', 'sync']
) as dag:

    sync_all = PythonOperator(
        task_id='sync_to_postgres_and_es',
        python_callable=task_sync_all_wrapper,
        op_kwargs={'target_db': 'db_datamanagement_test'}
    )
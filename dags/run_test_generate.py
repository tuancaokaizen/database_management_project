from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime
import sys

sys.path.insert(0, '/opt/airflow/src')

from test_generate import generate_data

with DAG(
        'generate_orders_workflow',
        start_date=datetime(2026, 3, 9),
        schedule_interval=None,
        catchup=False
) as dag:

    run_insert = PythonOperator(
        task_id='task_generate_data',
        python_callable=generate_data,
        op_kwargs={'target_db': 'db_datamanagement_test'}# Gọi hàm này
    )
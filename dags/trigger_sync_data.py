from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime
import sys
import os

# Đảm bảo Airflow tìm thấy module trong thư mục src
sys.path.append('/opt/airflow/src')
from sync_redis_service import run_metadata_sync

CONFIG_PATH = '/opt/airflow/src/database_config.json'

default_args = {
    'owner': 'Tuan Cao',
    'start_date': datetime(2026, 3, 15),
}

with DAG(
        'metadata_to_redis_sync',
        default_args=default_args,
        schedule_interval=None, # Trigger tay hoặc gọi từ DAG khác
        catchup=False
) as dag:

    sync_task = PythonOperator(
        task_id='call_sync_logic',
        python_callable=run_metadata_sync,
        op_kwargs={'config_path': CONFIG_PATH}
    )
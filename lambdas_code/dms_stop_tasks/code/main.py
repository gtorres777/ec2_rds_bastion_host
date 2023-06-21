import boto3

def stop_dms_tasks():
    dms_client = boto3.client('dms')
    
    # List all DMS replication tasks
    response = dms_client.describe_replication_tasks()
    tasks = response['ReplicationTasks']
    
    # Stop each DMS task
    for task in tasks:
        task_arn = task['ReplicationTaskArn']
        
        # Stop the DMS task
        dms_client.stop_replication_task(ReplicationTaskArn=task_arn)
    
    print("All DMS tasks stopped.")


def lambda_handler(event, context):
    stop_dms_tasks()

import boto3

def stop_dms_tasks():
    client = boto3.client('dms')
    response = client.describe_replication_tasks()
    tasks = response['ReplicationTasks']

    sns_client = boto3.client('sns')
    sns_topic_arn = 'arn:aws:sns:us-east-1:881422822893:Slack'
    subject = "Failed to stop DMS task replication on Premiere-prod"

    for task in tasks:
        if task['Status'] == 'running':
            task_arn = task['ReplicationTaskArn']

            try:
                client.stop_replication_task(ReplicationTaskArn=task_arn)
                print(f"Stopped DMS task: {task_arn}")
            except Exception as e:
                sns_message = f"Failed to stop DMS task: {task_arn}. Error: {str(e)}"
                print(sns_message)
                sns_client.publish(TopicArn=sns_topic_arn, Message=sns_message, Subject=subject)

    print("All DMS tasks stopped.")

def start_dms_tasks():
    client = boto3.client('dms')
    response = client.describe_replication_tasks()
    tasks = response['ReplicationTasks']

    sns_client = boto3.client('sns')
    sns_topic_arn = 'arn:aws:sns:us-east-1:881422822893:Slack'
    subject = "Failed to start DMS task replication on Premiere-prod"

    for task in tasks:
        if task['Status'] != 'running':
            task_arn = task['ReplicationTaskArn']

            try:
                client.start_replication_task(ReplicationTaskArn=task_arn,StartReplicationTaskType='resume-processing')
                print(f"Started DMS task: {task_arn}")
            except Exception as e:
                sns_message = f"Failed to start DMS task: {task_arn}. Error: {str(e)}"
                print(sns_message)
                sns_client.publish(TopicArn=sns_topic_arn, Message=sns_message, Subject=subject)
                client.stop_replication_task(ReplicationTaskArn=task_arn)

    print("All DMS tasks started.")

def lambda_handler(event, context):
    # Extract the CloudWatch alarm status change information from the event payload
    alarm_name = event['detail']['alarmName']
    alarm_state = event['detail']['state']['value']

    # Perform actions based on the CloudWatch alarm status change
    if alarm_state == 'ALARM':
        print(f"The alarm {alarm_name} is now in ALARM state.")
        stop_dms_tasks()
    elif alarm_state == 'OK':
        print(f"The alarm {alarm_name} is now in OK state.")
        start_dms_tasks()

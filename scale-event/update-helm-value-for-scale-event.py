import http.client
import logging
import os

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

""" 

"""


def update_dynamodb_helm_status(event):
    "helm_status 상태가 pending 인 경우, 해당 행의 helm_status를 finished 혹은 failed로 변경하는 코드"
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('ktown4u-scale-event')
    response_ = table.update_item(
        Key={
            'request_id': event['request_id']['S'],
            'request_user': event['request_user']['S']
        },
        UpdateExpression="set helm_status = :value",
        ExpressionAttributeValues={
            ':value': 'finished'
        },
        ReturnValues="UPDATED_NEW"
    )


def lambda_handler(event, context):
    logger.info('update-helm-value-for-scale-event')
    if event['helm_status']['S'] == 'pending':
        if event['request_type']['S'] == 'scale-out':
            try:
                post_helm_size_increase()
                update_dynamodb_helm_status(event)
            except:
                pass
        elif event['request_type']['S'] == 'scale-in':
            try:
                post_helm_size_decrease()
                update_dynamodb_helm_status(event)
            except:
                pass
    else:
        pass


def post_helm_size_increase():

    conn = http.client.HTTPSConnection("api.github.com")

    payload = "{\"ref\":\"refs/heads/main\"}"

    headers = {
        'Accept': "application/vnd.github+json",
        'Authorization': f"Bearer {os.environ['GITHUB_PAT_TOKEN']}",
        'X-GitHub-Api-Version': "2022-11-28",
        'User-Agent': "ktown4u-update-helm-value-for-scale-event-lambda"
    }
    conn.request(
        "POST", f"{os.environ['API_ENDPOINT']}{os.environ['INCREASE_WORKFLOW_ID']}/dispatches", payload, headers)
    res = conn.getresponse()
    data = res.read()
    return {
        'statusCode': 200,
        'body': data.decode("utf-8")
    }


def post_helm_size_decrease():

    conn = http.client.HTTPSConnection("api.github.com")

    payload = "{\"ref\":\"refs/heads/main\"}"

    headers = {
        'Accept': "application/vnd.github+json",
        'Authorization': f"Bearer {os.environ['GITHUB_PAT_TOKEN']}",
        'X-GitHub-Api-Version': "2022-11-28",
        'User-Agent': "ktown4u-update-helm-value-for-scale-event-lambda"
    }
    conn.request(
        "POST", f"{os.environ['API_ENDPOINT']}{os.environ['DECREASE_WORKFLOW_ID']}/dispatches", payload, headers)

    res = conn.getresponse()
    data = res.read()
    return {
        'statusCode': 200,
        'body': data.decode("utf-8")
    }

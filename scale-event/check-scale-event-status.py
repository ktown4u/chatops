import os
import logging
import json

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)
client = boto3.client('dynamodb')

""" 
event example
{'Records': [
    {
        'eventID': '7b085cc40415132f21eaa94dbfb8e9e8', 
        'eventName': 'INSERT', 
        'eventVersion': '1.1', 
        'eventSource': 'aws:dynamodb', 
        'awsRegion': 'ap-northeast-2', 
        'dynamodb': {
            'ApproximateCreationDateTime': 1719389631.0, 
            'Keys': {
                'request_user': {'S': 'kyungyeol.gu'}, 
                'request_id': {'S': 'd3e69831-a638-447d-8074-5c3603f6510f'}
            }, 
            'NewImage': {
                'request_status': {'S': 'pending'}, 
                'datetime': {'S': '2024-06-26 17:13:50.037461'}, 
                'request_channel_name': {'S': 'chatops'}, 
                'request_type': {'S': 'scale-out'}, 
                'request_user': {'S': 'kyungyeol.gu'}, 
                'rds_asg_status': {'S': 'pending'}, 
                'helm_status': {'S': 'pending'}, 
                'request_id': {'S': 'd3e69831-a638-447d-8074-5c3603f6510f'}
            }, 
            'SequenceNumber': '111100000000019550696073', 
            'SizeBytes': 272, 
            'StreamViewType': 'NEW_AND_OLD_IMAGES'
        }, 
        'eventSourceARN': 'arn:aws:dynamodb:ap-northeast-2:170023315897:table/ktown4u-scale-event/stream/2024-06-26T07:09:02.314'
    }
]}
"""


def parse_dynamodb_stream(event):
    for record in event['Records']:
        if record['eventName'] == 'INSERT':
            body = record['dynamodb']['NewImage']
            return body
        else:
            return False


def lambda_handler(event, context):
    logger.info(event)
    try:
        body = parse_dynamodb_stream(event)
    except Exception as e:
        logger.info(f"dynamodb strem eventName is not INSERT")
        return {
            'statusCode': 200,
            'body': 'not INSERT event'
        }
    logger.info('validation_check_finished')
    lambda_client = boto3.client('lambda')
    try:
        if body['helm_status']['S'] == "pending":
            response = lambda_client.invoke(
                FunctionName='update-helm-value-for-scale-event',
                InvocationType='Event',
                Payload=json.dumps(body)
            )
            logger.info('send event to update-helm-value-for-scale-event')

        else:
            pass
    except Exception as e:
        logger.info(f"helm status is not pending {e}")
        pass

    try:
        if body['rds_asg_status']['S'] == "pending":
            response = lambda_client.invoke(
                FunctionName='update-aurora-asg-policy-for-scale-event',
                InvocationType='Event',
                Payload=json.dumps(body)
            )
            logger.info(
                'send event to update-aurora-asg-policy-for-scale-event')
        else:
            pass

    except Exception as e:
        logger.info(f"aurora asg policy is not pending {e}")
        pass

    return {
        'statusCode': 200,
        'body': 'success_sending_request'
    }

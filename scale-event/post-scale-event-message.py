import os
import json
import urllib.parse
import logging
import hmac
import hashlib
import base64
import boto3
from datetime import datetime
from datetime import timedelta


logger = logging.getLogger()


def decode_slack_message_body(body):
    # Slack signature verification
    slack_signature = body['headers']['x-slack-signature']
    slack_request_timestamp = body['headers']['x-slack-request-timestamp']
    request_body = body['body']

    # Decode the base64 encoded body
    decoded_body = base64.b64decode(request_body).decode('utf-8')

    # validation check
    # Slack signing secret
    slack_signing_secret = os.environ['SIGNING_SECRET']

    # Create the basestring as described in Slack API docs
    basestring = f"v0:{slack_request_timestamp}:{decoded_body}"

    # Make the HMAC-SHA256 hash
    my_signature = 'v0=' + hmac.new(
        bytes(slack_signing_secret, 'utf-8'),
        bytes(basestring, 'utf-8'),
        hashlib.sha256
    ).hexdigest()

    # Compare the signatures
    if not hmac.compare_digest(my_signature, slack_signature):
        message_valid = False
        return False

    # Parse the request body
    parsed_body = dict(urllib.parse.parse_qsl(decoded_body))

    return parsed_body


def check_scale_event_status_in_dynamodb_table():
    # 동시에 여러 scale 작업을 하지 않도록 막는 함수
    # dynamodb에서 request_status가 pending인 row가 1개라도 있는지 확인

    pass


def post_message_to_dynamodb_table(body):
    utc_time = datetime.now(tz=None)
    kst_time = str(utc_time + timedelta(hours=9))
    client = boto3.client('dynamodb')
    try:
        client.put_item(
            TableName=os.environ['DYNAMODB_TABLE_NAME'],
            Item={
                "request_id": {"S": body['request_id']},
                "datetime": {"S": kst_time},
                "request_user": {"S": body['user_name']},
                "request_channel_name": {"S": body['channel_name']},
                "request_type": {"S": body['command']},
                "request_status": {"S": "pending"},
                "helm_status": {"S": "pending"},
                "rds_asg_status": {"S": "pending"}
            }
        )
    except Exception as e:
        print(e)
        logger.error(
            f"dynamodb putItem 요청이 실패했습니다. {e}"
        )


def lambda_handler(event, context):
    print(event)
    body = decode_slack_message_body(event)
    response_message = f''
    if body is not False:
        body['request_id'] = context.aws_request_id
        body['command'] = body['command'][1:]
        check_scale_event_status_in_dynamodb_table()
        post_message_to_dynamodb_table(body)
        return {
            'statusCode': 200,
            'body': json.dumps({
                "response_type": "in_channel",
                "text": response_message
            })
        }
    else:
        return {
            'statusCode': 400,
            'body': json.dumps({
                "response_type": "in_channel",
                "text": '적상적이지 못한 요청입니다.'
            })
        }

import os
import json
import urllib.parse
import logging
import hmac
import hashlib
import base64
from datetime import datetime
from datetime import timedelta

import json
import boto3


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


def lambda_handler(event, context):
    body = decode_slack_message_body(event)
    if body is not False and 'text' not in body:
        return {
            'statusCode': 200,
            'body': json.dumps({
                "response_type": "in_channel",
                "text": '생성할 프로젝트 이름을 입력해주세요.'
            })
        }
    else:
        pass

    client = boto3.client('ecr')

    repository_name = event.get('repository_name', body['text'])

    try:
        response = client.create_repository(
            repositoryName=repository_name,
            tags=[
                {
                    'Key': 'Name',
                    'Value': repository_name
                },
            ],
            imageTagMutability='MUTABLE',
            imageScanningConfiguration={
                'scanOnPush': True
            }
        )

        return {
            'statusCode': 200,
            'body': json.dumps({
                "response_type": "in_channel",
                "text": f"{body['text']} 프로젝트의 ecr이 생성되었습니다."
            })
        }

    except client.exceptions.RepositoryAlreadyExistsException:
        return {
            'statusCode': 200,
            'body': json.dumps({
                "response_type": "in_channel",
                "text": f"동일한 이름의 ecr 존재합니."
            })
        }
    except Exception as e:
        return {
            'statusCode': 200,
            'body': json.dumps({
                "response_type": "in_channel",
                "text": f"알 수 없는 에러가 발생했습니다."
            })
        }

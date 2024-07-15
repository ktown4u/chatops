import os
import json

import requests


def lambda_handler(event, context):
    print(event)
    # TODO implement
    event_time = event['detail']['eventTime']
    event_account = event['detail']['recipientAccountId']
    event_region = event['detail']['awsRegion']
    event_login_method = event['detail']['eventName']
    event_assumed_role = event['detail']['responseElements']['assumedRoleUser']['arn']
    event_user = event['detail']['requestParameters']['roleSessionName']
    event_ip = event['detail']['sourceIPAddress']
    event_expire_date = event['detail']['responseElements']['credentials']['expiration']
    url = os.environ['URL']

    payload = {
        "channel_id": os.environ['CHANNEL_ID'],
        "message": "aws login",
        "blocks": [
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": ":mega: *AWS Web Console Login*"
                }
            },
            {
                "type": "context",
                "elements": [
                    {
                        "type": "mrkdwn",
                        "text": "*Date*"
                    },
                    {
                        "type": "plain_text",
                        "text": event_time
                    }
                ]
            },
            {
                "type": "context",
                "elements": [
                    {
                        "type": "mrkdwn",
                        "text": "*Account ID*"
                    },
                    {
                        "type": "plain_text",
                        "text": event_account
                    }
                ]
            },
            {
                "type": "context",
                "elements": [
                    {
                        "type": "mrkdwn",
                        "text": "*Type*"
                    },
                    {
                        "type": "plain_text",
                        "text": event_login_method
                    }
                ]
            },
            {
                "type": "context",
                "elements": [
                    {
                        "type": "mrkdwn",
                        "text": "*Region*"
                    },
                    {
                        "type": "plain_text",
                        "text": event_region
                    }
                ]
            },
            {
                "type": "context",
                "elements": [
                    {
                        "type": "mrkdwn",
                        "text": "*Source IP*"
                    },
                    {
                        "type": "plain_text",
                        "text": event_ip
                    }
                ]
            },
            {
                "type": "context",
                "elements": [
                    {
                        "type": "mrkdwn",
                        "text": "*User*"
                    },
                    {
                        "type": "plain_text",
                        "text": event_user
                    }
                ]
            },
            {
                "type": "context",
                "elements": [
                    {
                        "type": "mrkdwn",
                        "text": "*Expire date*"
                    },
                    {
                        "type": "plain_text",
                        "text": event_expire_date
                    }
                ]
            },
            {
                "type": "context",
                "elements": [
                    {
                        "type": "mrkdwn",
                        "text": "*ARN*"
                    },
                    {
                        "type": "plain_text",
                        "text": event_assumed_role
                    }
                ]
            }

        ]
    }
    headers = {
        "Content-Type": "application/json"
    }

    response = requests.request("POST", url, json=payload, headers=headers)
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }

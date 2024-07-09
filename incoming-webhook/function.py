import logging
import json
import os
# Import WebClient from Python SDK (github.com/slackapi/python-slack-sdk)
from slack_sdk import WebClient
from slack_sdk.errors import SlackApiError

# WebClient instantiates a client that can call API methods
# When using Bolt, you can use either `app.client` or the `client` passed to listeners.

client = WebClient(token=os.environ['SLACK_TOKEN'])
logger = logging.getLogger(__name__)


def lambda_handler(event, context):
    # ID of channel you want to post message to
    body = json.loads(event['body'])
    channel_id = body['channel_id']
    try:
        message = body['message']
    except:
        message = "no message"
    try:
        blocks = body['blocks']
    except:
        blocks = [{"type": "section", "text": {
            "type": "plain_text", "text": " "}}]
    try:
        # Call the conversations.list method using the WebClient
        result = client.chat_postMessage(
            channel=channel_id,
            text=message,
            blocks=blocks
        )
        print(result)
        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json"
            },
            "body": f"success"
        }

    except SlackApiError as e:
        print(f"Error: {e}")
        return {
            "statusCode": 503,
            "headers": {
                "Content-Type": "application/json"
            },
            "body": f"error message: {e}"
        }

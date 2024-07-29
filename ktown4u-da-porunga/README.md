# lambda-gurumi-ai-bot

A serverless Slack bot using AWS Lambda, API Gateway, and DynamoDB.

![Gurumi Bot](images/gurumi-bot.png)

## Install

```bash
brew install python@3.9
npm install -g serverless@3.38.0
sls plugin install -n serverless-python-requirements
sls plugin install -n serverless-dotenv-plugin
python3 -m pip install --upgrade -r requirements.txt
# .env 파일에 토큰 반영 (ssm parameter store 참고)
sls deploy
# slack app에서 api gateway의 주소를 반영
# https://api.slack.com/apps/A079YLSSNKT/event-subscriptions
```

## update

```bash
sls deploy
```
## Setup

Setup a Slack app by following the guide at https://slack.dev/bolt-js/tutorial/getting-started

Set scopes to Bot Token Scopes in OAuth & Permission:

```
app_mentions:read
channels:history
channels:join
channels:read
chat:write
files:read
files:write
im:read
im:write
```

Set scopes in Event Subscriptions - Subscribe to bot events

```
app_mention
message.im
```

## Credentials

```bash
$ cp .env.example .env
```

### Slack Bot

```bash
SLACK_BOT_TOKEN="xoxb-xxxx"
SLACK_SIGNING_SECRET="xxxx"
```

## Deployment

In order to deploy the example, you need to run the following command:

```bash
$ sls deploy
```

## Slack Test

- `An error occurred (AccessDeniedException) when calling the InvokeModel operation: You don't have access to the model with the specified model ID.` 에러 발생시
  - us-east-1 리전에서, bedrock 서비스 활성화 필요.
- `An error occurred (AccessDeniedException) when calling the InvokeModel operation: Your account does not have an agreement to this model.` 에러 발생시
  - .env 파일에서 지정한 BedRock 모델 활성화 필요 (5분 정도 소요됨)

```bash
curl -X POST -H "Content-Type: application/json" \
-d " \
{ \
    \"token\": \"Jhj5dZrVaK7ZwHHjRyZWjbDl\", \
    \"challenge\": \"3eZbrw1aBm2rZgRNFdxV2595E9CY3gmdALWMmHkvFXO7tYXAYM8P\", \
    \"type\": \"url_verification\" \
}" \
https://jhz21gawvg.execute-api.us-east-1.amazonaws.com/dev/slack/events
```

## References

* <https://docs.aws.amazon.com/ko_kr/code-library/latest/ug/python_3_bedrock-runtime_code_examples.html>

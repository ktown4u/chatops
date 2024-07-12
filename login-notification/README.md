# login-notification

## AWS Cloud login

- region: us-east-1 # AWS Login은 global 서비스이므로 ue-east-1에서 발생함.
  - eventbus
    - default
  - lambda
    - chatops-login-notification
  - iam role
    - chatops-login-notification

### EVENTBRIDGE

rule: chatops-login-notification
pattern:
    ```json
    {
        "source": [
            "aws.sts"
        ],
        "detail": {
            "eventName": [
            "AssumeRoleWithSAML"
            ]
        }
    }
    ```

### LMBDA

name: chatops-login-notification
role: chatops-login-notification
environ:
    - CHANNEL_ID: C07C4M9K97D
    - URL: `https://hook.ktown4u.io`
layers:
  - requests

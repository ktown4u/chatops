# incoming-hook

## 설명

## 사용 예시

- slack의 특정 채널에 알림을 받고 싶은 경우
- 애플리케이션에서 특정 상황이 발생했을 때 알람을 받고 싶은 경우
- 애플리케이션 배포 주기 완료시 (새로운 파드가 생성되고, readiness probe 활성화된 다음)
- 주기적인 업무에 대한 리마인드

## 사용법

- 상세 사용법 [notion link](https://www.notion.so/ktown4u/slack-message-hook-ca8e2bf31ed3402599d0abbc49c33819?pvs=4)
- 간단 사용법

  ```bash
  # alarm-test 채널 (C077PB69QAF)
    curl --request POST \
    --url https://hook.ktown4u.io \
    --header 'Content-Type: application/json' \
    --data '{
        "channel_id":"C077PB69QAF",  
        "blocks" : [
            {
                "type" : "section",
                "text" : {
                    "type": "plain_text",
                    "text" : "hi"
                }
            }
        ]
    }'
  ```

## 기능

- 단순 텍스트 전송 가능
- slack block build kit 사용 가능
  - [slack build kit url](https://www.notion.so/ktown4u/slack-message-hook-ca8e2bf31ed3402599d0abbc49c33819?pvs=4#31ceb69d0e9144c89c9bc9ab85b8d275)

### Todo List

- 테라폼 전환
  - lambda
    - functional url
    - lambda code
    - iam
  - dns
    - cloudfront
    - cloudflare

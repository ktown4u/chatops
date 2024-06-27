# scale-event

## 운영 채널에 적용시 변경할 점

- 환경 변수 변경
- aws profile 변경
- parameter store 설정
  - /chatops/github/pat-token
  - /chatops/slack/token
  - /chatops/slack/signing-secret

## ToDo List

- IAM 권한 축소
  - RDS Full access, Dynamodb Full Access는 위험함.
- slack 응답 시간은 최대 3초임.
- github PAT Token은 1년 만료. 없앨 수 있는지 확인
- 운영으로 변경시

## slack permissions

- app_mentions:read
- channels:history
- channels:join
- channels:manage
- channels:read
- chat:write
- chat:write.public
- commands
- users:read
- users:read.email

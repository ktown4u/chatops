import boto3
import logging
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def update_dynamodb_rds_asg_policy_status(event):
    "rds_asg_status 상태가 pending 인 경우, 해당 행의 rds_asg_status finished 혹은 failed로 변경하는 코드"
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('ktown4u-scale-event')
    response_ = table.update_item(
        Key={
            'request_id': event['request_id']['S'],
            'request_user': event['request_user']['S']
        },
        UpdateExpression="set rds_asg_status = :value",
        ExpressionAttributeValues={
            ':value': 'finished'
        },
        ReturnValues="UPDATED_NEW"
    )


def update_aurora_auto_scaling_policy(cluster_identifier, min_replicas, max_replicas):
    client = boto3.client('application-autoscaling')

    # Scalable target 등록
    response = client.register_scalable_target(
        ServiceNamespace='rds',
        ResourceId=f'cluster:{cluster_identifier}',
        ScalableDimension='rds:cluster:ReadReplicaCount',
        MinCapacity=min_replicas,
        MaxCapacity=max_replicas
    )

    print("Scalable target registered successfully:", response)

    # 현재 Auto Scaling Policy 가져오기
    response = client.describe_scaling_policies(
        ServiceNamespace='rds',
        ResourceId=f'cluster:{cluster_identifier}',
        ScalableDimension='rds:cluster:ReadReplicaCount'
    )

    policies = response.get('ScalingPolicies', [])

    if not policies:
        raise Exception(
            f"No scaling policies found for cluster: {cluster_identifier}")

    policy_name = policies[0]['PolicyName']

    # Auto Scaling Policy 업데이트
    response = client.put_scaling_policy(
        PolicyName=policy_name,
        ServiceNamespace='rds',
        ResourceId=f'cluster:{cluster_identifier}',
        ScalableDimension='rds:cluster:ReadReplicaCount',
        PolicyType='TargetTrackingScaling',
        TargetTrackingScalingPolicyConfiguration={
            'TargetValue': policies[0]['TargetTrackingScalingPolicyConfiguration']['TargetValue'],
            'PredefinedMetricSpecification': {
                'PredefinedMetricType': policies[0]['TargetTrackingScalingPolicyConfiguration']['PredefinedMetricSpecification']['PredefinedMetricType']
            },
            'ScaleInCooldown': policies[0]['TargetTrackingScalingPolicyConfiguration']['ScaleInCooldown'],
            'ScaleOutCooldown': policies[0]['TargetTrackingScalingPolicyConfiguration']['ScaleOutCooldown']
        }
    )

    print("Auto Scaling Policy updated successfully:", response)
    return response


# 테이블 생성 함수
def lambda_handler(event, context):
    logger.info('update-helm-value-for-scale-event')
    cluster_identifier = os.environ['CLUSTER_IDENTIFIER']
    if event['helm_status']['S'] == 'pending':
        if event['request_type']['S'] == 'scale-out':
            try:
                update_aurora_auto_scaling_policy(
                    cluster_identifier=cluster_identifier,
                    min_replicas=10,
                    max_replicas=15
                )
                update_dynamodb_rds_asg_policy_status(event)
            except:
                pass
        elif event['request_type']['S'] == 'scale-in':
            try:
                update_aurora_auto_scaling_policy(
                    cluster_identifier=cluster_identifier,
                    min_replicas=1,
                    max_replicas=15
                )
                update_dynamodb_rds_asg_policy_status(event)
            except:
                pass
    else:
        pass

    return {
        'statusCode': 200,
        'body': 'success_sending_request'
    }

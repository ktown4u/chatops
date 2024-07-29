import boto3
from botocore.config import Config

bedrock_config = Config(
    region_name='us-east-1',
    signature_version='v4',
)

bedrock_agent_runtime = boto3.client(
    service_name="bedrock-agent-runtime",
    config=bedrock_config
)


def retrieve(input):
    print('use rag')
    try:
        kbId = 'JRPEHTOTEI'
        modelArn = 'anthropic.claude-3-sonnet-20240229-v1:0'
        response = bedrock_agent_runtime.retrieve_and_generate(
            input={
                'text': input,
            },
            retrieveAndGenerateConfiguration={
                "type": "KNOWLEDGE_BASE",
                "knowledgeBaseConfiguration": {
                    "knowledgeBaseId": "JRPEHTOTEI",
                    "retrievalConfiguration": {
                        "vectorSearchConfiguration": {
                            "overrideSearchType": "SEMANTIC",
                            "numberOfResults": 5
                        }
                    },
                    "generationConfiguration": {}
                }
            }
        )
        output = response['output']
        return output

    except Exception as e:
        print(f'retrieve error with {e}')

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


def retrieve(query, kbId='2SKKIDNPZM', numberOfResults=20):
    print('use rag')
    try:
        print(kbId)
        print(numberOfResults)
        response = bedrock_agent_runtime.retrieve_and_generate(
            input={
                'text': query,
            },
            retrieveAndGenerateConfiguration={
                "type": "KNOWLEDGE_BASE",
                "knowledgeBaseConfiguration": {
                    "knowledgeBaseId": kbId,
                    "modelArn":  'anthropic.claude-3-sonnet-20240229-v1:0',
                    "retrievalConfiguration": {
                        "vectorSearchConfiguration": {
                            "overrideSearchType": "HYBRID",
                            "numberOfResults": numberOfResults
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


if __name__ == "__main__":
    query = 'hello ktown4u java에 대해 설명해줘.'
    print(retrieve(query))

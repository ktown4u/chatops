resource "aws_opensearchserverless_security_policy" "network_policy" {
  name = "network-policy"
  type = "network"
  # linter가 ([{  순서 깨뜨리지 않았는 지 확인
  policy = jsonencode([{
    "Rules" = [
      {
        ResourceType = "collection"
        Resource = [
          "collection/slack-bot-aoss"
        ]
      },
      {
        ResourceType = "dashboard"
        Resource = [
          "collection/slack-bot-aoss"
        ]
      },
    ],
    AllowFromPublic = true
  }])
}
resource "aws_opensearchserverless_security_policy" "encryption_policy" {
  name = "encryption-policy"
  type = "encryption"
  # linter가 ({  순서 깨뜨리지 않았는 지 확인
  policy = jsonencode({
    Rules = [
      {
        Resource = [
          "collection/*"
        ],
        ResourceType = "collection"
      }
    ],
    AWSOwnedKey = true
  })
}

resource "aws_opensearchserverless_access_policy" "access_policy" {
  name        = "access-policy"
  type        = "data"
  description = "read and write permissions"
  # linter가 ([{  순서 깨뜨리지 않았는 지 확인
  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "index",
          Resource = [
            "index/slack-bot-aoss/*"
          ],
          Permission = [
            "aoss:*"
          ]
        },
        {
          ResourceType = "collection",
          Resource = [
            "collection/slack-bot-aoss"
          ],
          Permission = [
            "aoss:*"
          ]
        }
      ],
      Principal = [
        aws_iam_role.AmazonBedrockExecutionRoleForKnowledgeBase.arn,
        data.aws_caller_identity.current.arn,
        aws_iam_role.lambda_role.arn
      ]
    }
  ])
}

resource "aws_opensearchserverless_collection" "kb_vector_db" {
  name = "slack-bot-aoss"
  type = "VECTORSEARCH"
  depends_on = [
    aws_opensearchserverless_security_policy.network_policy,
    aws_opensearchserverless_security_policy.encryption_policy,
    aws_opensearchserverless_access_policy.access_policy
  ]
}
# Configure the OpenSearch provider
provider "opensearch" {
  url         = aws_opensearchserverless_collection.kb_vector_db.collection_endpoint
  healthcheck = false
}
resource "opensearch_index" "knowledge_base_index" {
  name                           = "bedrock-knowledge-base-default-index"
  number_of_shards               = "1"
  number_of_replicas             = "0"
  index_knn                      = true
  index_knn_algo_param_ef_search = "512"
  mappings                       = <<-EOF
    {
      "properties": {
        "bedrock-knowledge-base-default-vector": {
          "type": "knn_vector",
          "dimension": 1536,
          "method": {
            "name": "hnsw",
            "engine": "faiss",
            "parameters": {
              "m": 16,
              "ef_construction": 512
            },
            "space_type": "l2"
          }
        },
        "AMAZON_BEDROCK_METADATA": {
          "type": "text",
          "index": "false"
        },
        "AMAZON_BEDROCK_TEXT_CHUNK": {
          "type": "text",
          "index": "true"
        }
      }
    }
  EOF
  force_destroy                  = true
  depends_on                     = [aws_opensearchserverless_collection.kb_vector_db]
}

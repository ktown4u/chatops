
resource "aws_s3_bucket" "knowledgebase_source" {
  bucket = "slack-bot-kb-bucket"
}


resource "aws_bedrockagent_knowledge_base" "slack_bot_kb" {
  name     = "${local.name}_knowledge_base"
  role_arn = aws_iam_role.AmazonBedrockExecutionRoleForKnowledgeBase.arn
  knowledge_base_configuration {
    vector_knowledge_base_configuration {
      embedding_model_arn = "arn:aws:bedrock:${local.region}::foundation-model/amazon.titan-embed-text-v1"
    }
    type = "VECTOR"
  }
  storage_configuration {
    type = "OPENSEARCH_SERVERLESS"
    opensearch_serverless_configuration {
      collection_arn    = aws_opensearchserverless_collection.kb_vector_db.arn
      vector_index_name = "bedrock-knowledge-base-default-index"
      field_mapping {
        vector_field   = "bedrock-knowledge-base-default-vector"
        text_field     = "AMAZON_BEDROCK_TEXT_CHUNK"
        metadata_field = "AMAZON_BEDROCK_METADATA"
      }
    }
  }
  depends_on = [
    aws_opensearchserverless_collection.kb_vector_db,
    opensearch_index.knowledge_base_index
  ]
}


resource "aws_bedrockagent_data_source" "knowledge_base_data_source" {
  knowledge_base_id = aws_bedrockagent_knowledge_base.slack_bot_kb.id
  name              = "${local.name}_datasource"
  vector_ingestion_configuration {
    chunking_configuration {
      chunking_strategy = "SEMANTIC"
      #Potential expected config follows.
      semantic_chunking_configuration {
        breakpoint_percentile_threshold = 95
        buffer_size                     = 0
        max_token                       = 512
      }

    }
    parsing_configuration {
      bedrock_foundation_model_configuration {
        model_arn = "arn:aws:bedrock:${local.region}::foundation-model/anthropic.claude-3-5-sonnet-20240620-v1:0"
      }
      parsing_strategy = "BEDROCK_FOUNDATION_MODEL"
    }
  }
  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn = aws_s3_bucket.knowledgebase_source.arn
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
  default_tags {
    tags = {
      service = "chatops"
    }
  }
}

provider "aws" {
  region  = "ap-northeast-2"
  profile = "lab"
  default_tags {
    tags = {
      service = "chatops"
    }
  }
}

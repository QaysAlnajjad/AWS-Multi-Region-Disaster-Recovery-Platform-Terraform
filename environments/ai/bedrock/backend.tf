terraform {

  backend "s3" {

    key = "environments/ai/bedrock/terraform.tfstate"

  }

}

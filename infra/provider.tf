###############################################################
# infra/provider.tf
###############################################################

provider "aws" {
  region = "us-east-1" # N. Virginia - matches your 'gitnew' keypair
}


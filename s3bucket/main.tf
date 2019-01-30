# Configure aws with a default region
provider "aws" {
  region = "us-east-1"
}

# Create a demo s3 bucket
resource "aws_s3_bucket" "david74-demo-bucket" {
  bucket = "david74-demo-bucket"

  tags {
    Name = "david74-demo-bucket"
    Environment = "internal"
    Purpose = "demo"
  }
}

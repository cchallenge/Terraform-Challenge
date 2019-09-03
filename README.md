# Terraform-Challenge
Requirements: terraform v0.11.8e

Steps to run setup S3 Bucket and Dynamodb

1. git clone https://github.com/cchallenge/Terraform-Challenge.git

2. cd into dynamodb-s3-bucket
3. Run the following:
   # terraform init; terraform plan; terraform apply

4. Populate the s3 bucket with test data by running the following:
   # cd into src/testdata
   # ./upload.py

5. cd into lambda
6. Run the following to run the lambda.
   # terraform init; terraform plan; terraform apply

7. Check Dynamodb tables for the data.


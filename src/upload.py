#!/usr/local/bin/python3

import boto3
from pathlib import Path
import os, sys

# Create an S3 client
s3 = boto3.client('s3')

filename = 'file.txt'
bucket_name = 'foo-medopad'

basepath = Path('./')
files_in_basepath = basepath.iterdir()
for item in files_in_basepath:
    if item.is_file():
        print(item.name)
        s3.upload_file(item.name, bucket_name, item.name)
 



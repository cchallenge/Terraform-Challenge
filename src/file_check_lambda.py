#!/usr/local/bin/python3

import boto3
import datetime
from pathlib import Path

bucket_name = 'foo-medopad'
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('Timestamp')



s3 = boto3.resource('s3')
bucket = s3.Bucket(bucket_name)

if bucket.creation_date:
  for obj in bucket.objects.all():
    filename = obj.key
    obj = s3.Object(bucket_name, filename)
    obj.delete()

    print (filename)
    timestamp = str(datetime.datetime.now())
    print (timestamp)

    table.put_item(
       Item={
           'object_name': '%s' % filename,
           'deleted_at': '%s' % timestamp,
           }
    )
else:
    print("The bucket does not exist")

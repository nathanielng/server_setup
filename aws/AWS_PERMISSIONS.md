# AWS Permissions

## S3 

### S3 Single Bucket Policy Example

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListAccessPoints",
                "s3:ListAllMyBuckets",
                "s3:ListJobs",
                "s3:ListMultiRegionAccessPoints"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation",
                "s3:PutLifecycleConfiguration",
                "s3:GetLifecycleConfiguration",
                "s3:ListBucketMultipartUploads"
            ],
            "Resource": "arn:aws:s3:::mys3bucketname"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:RestoreObject",
                "s3:AbortMultipartUpload",
                "s3:GetObjectAttributes"
            ],
            "Resource": "arn:aws:s3:::mys3bucketname/*"
        }
    ]
}
```

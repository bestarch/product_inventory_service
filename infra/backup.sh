#!/bin/bash

TIMESTAMP=$(date +"%Y-%m-%d-%H-%M")

BACKUP_DIR="/tmp/backup-$TIMESTAMP"

ARCHIVE_NAME="mongo-$TIMESTAMP.tar.gz"

S3_BUCKET="s3://abhi-data-128765417052026"

# Create backup
mongodump \
    --username admin \
    --password admin \
    --authenticationDatabase admin \
    --out $BACKUP_DIR

# Compress backup
tar -czf /tmp/$ARCHIVE_NAME $BACKUP_DIR

# Upload to S3
aws s3 cp /tmp/$ARCHIVE_NAME $S3_BUCKET/
#!/bin/bash
set -e

# 1. Install MongoDB
apt-get update -y
apt-get install -y gnupg curl

curl -fsSL https://pgp.mongodb.com/server-5.0.asc | \
gpg -o /usr/share/keyrings/mongodb-server-5.0.gpg --dearmor

echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-5.0.gpg ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | \
tee /etc/apt/sources.list.d/mongodb-org-5.0.list

sudo apt-get update -y
sudo apt-get install -y mongodb-org

sed -i 's/^  bindIp: .*/  bindIp: 0.0.0.0/' /etc/mongod.conf

systemctl enable mongod
systemctl start mongod

sleep 10

mongosh --eval '
db = db.getSiblingDB("admin");
db.createUser({
  user: "admin",
  pwd: "admin",
  roles: [ { role: "root", db: "admin" } ]
});
'

cat <<EOF >> /etc/mongod.conf

security:
  authorization: enabled
EOF

systemctl restart mongod

sudo apt-get install mongodb-database-tools
sudo apt install -y curl unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Create backup script
cat > /home/ubuntu/backup.sh <<'EOF'
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
EOF

chmod +x /home/ubuntu/backup.sh

bash /home/ubuntu/backup.sh

# Add cron job for daily backup
echo "0 21 * * * /home/ubuntu/backup.sh >> /var/log/backup.log 2>&1" | crontab -




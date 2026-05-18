#!/bin/bash
set -e

# -------------------------
# 1. Install MongoDB
# -------------------------
apt-get update -y
apt-get install -y gnupg curl

curl -fsSL https://pgp.mongodb.com/server-5.0.asc | \
gpg -o /usr/share/keyrings/mongodb-server-5.0.gpg --dearmor

echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-5.0.gpg ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | \
tee /etc/apt/sources.list.d/mongodb-org-5.0.list

apt-get update -y
apt-get install -y mongodb-org

# -------------------------
# 2. Configure MongoDB (NO AUTH YET)
# -------------------------
sed -i 's/^  bindIp: .*/  bindIp: 0.0.0.0/' /etc/mongod.conf

systemctl enable mongod
systemctl start mongod

# wait until MongoDB is ready
sleep 10

# -------------------------
# 3. Create admin user (IMPORTANT)
# -------------------------
mongosh --eval '
db = db.getSiblingDB("admin");
db.createUser({
  user: "admin",
  pwd: "admin",
  roles: [ { role: "root", db: "admin" } ]
});
'

# -------------------------
# 4. Enable authentication
# -------------------------
cat <<EOF >> /etc/mongod.conf

security:
  authorization: enabled
EOF

# -------------------------
# 5. Restart MongoDB with auth enabled
# -------------------------
systemctl restart mongod
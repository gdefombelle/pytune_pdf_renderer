#!/bin/bash

SERVICE_NAME="pytune_pdf_renderer"
SERVER="gabriel@195.201.9.184"
REMOTE_DIR="/home/gabriel/deploy/$SERVICE_NAME"

echo "🚀 Building Docker image..."
docker build -t $SERVICE_NAME:latest -f src/services/$SERVICE_NAME/Dockerfile .

echo "📦 Saving image..."
docker save $SERVICE_NAME:latest | gzip > $SERVICE_NAME.tar.gz

echo "📤 Uploading to server..."
ssh $SERVER "mkdir -p $REMOTE_DIR"
scp $SERVICE_NAME.tar.gz $SERVER:$REMOTE_DIR/

echo "🐳 Deploying on server..."
ssh $SERVER << EOF
cd $REMOTE_DIR

gunzip -f $SERVICE_NAME.tar.gz
docker load < $SERVICE_NAME.tar

docker stop $SERVICE_NAME || true
docker rm $SERVICE_NAME || true

docker run -d \
  --name $SERVICE_NAME \
  --restart always \
  --network pytune_network \
  --env-file /home/gabriel/pytune.env \
  $SERVICE_NAME:latest

echo "✅ $SERVICE_NAME deployed successfully"
EOF
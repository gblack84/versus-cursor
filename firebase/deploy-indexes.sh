#!/bin/bash

# Deploy Firestore indexes to Firebase
echo "🚀 Deploying Firestore indexes..."

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI is not installed. Please install it first:"
    echo "   npm install -g firebase-tools"
    exit 1
fi

# Deploy only Firestore indexes
firebase deploy --only firestore:indexes

if [ $? -eq 0 ]; then
    echo "✅ Firestore indexes deployed successfully!"
    echo ""
    echo "⏱️  Note: New indexes may take a few minutes to build."
    echo "    You can monitor the progress in the Firebase Console:"
    echo "    https://console.firebase.google.com/project/versus-space-1lwwiw/firestore/indexes"
else
    echo "❌ Failed to deploy Firestore indexes"
    exit 1
fi
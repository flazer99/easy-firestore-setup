#!/bin/bash

# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# Capture arguments from Python
PROJECT_ID=$1
REGION=$2

echo "Starting Firestore deployment for Project: $PROJECT_ID..."

# =============================================================================
# STEP 1: Configure Project
# =============================================================================
gcloud config set project $PROJECT_ID

# =============================================================================
# STEP 2: Enable Required APIs
# =============================================================================
echo "Enabling required APIs..."
gcloud services enable firestore.googleapis.com aiplatform.googleapis.com storage.googleapis.com

# =============================================================================
# STEP 3: Check if Firestore database exists
# =============================================================================
echo "Checking Firestore database status..."
if gcloud firestore databases describe --database="(default)" > /dev/null 2>&1; then
    echo "Firestore database already exists. Skipping creation."
else
    echo "Creating Firestore database in Native mode..."
    if ! gcloud firestore databases create \
        --location=$REGION \
        --type=firestore-native; then
        echo "ERROR: Failed to create Firestore database."
        echo "Note: If you see 'already exists' error, the database is ready."
    fi
fi

# =============================================================================
# STEP 4: Display Firestore Details
# =============================================================================
echo ""
echo "============================================"
echo "Firestore Database Details:"
echo "============================================"
gcloud firestore databases describe --database="(default)" --format="table(name,locationId,type)" 2>/dev/null || echo "Database info not available yet"

echo ""
echo "============================================"
echo "Connection Information:"
echo "============================================"
echo "Project ID:        $PROJECT_ID"
echo "Location:          $REGION"
echo "Database Mode:     Native (required for Vector Search)"
echo ""
echo "============================================"
echo "How to Connect (from Python):"
echo "============================================"
echo ""
echo "from google.cloud import firestore"
echo ""
echo "db = firestore.Client(project='$PROJECT_ID')"
echo ""
echo "# Add a document"
echo "db.collection('items').add({'name': 'test', 'value': 123})"
echo ""
echo "============================================"
echo "Vector Search Setup (Optional):"
echo "============================================"
echo ""
echo "To enable vector search, create an index:"
echo ""
echo "gcloud firestore indexes composite create \\"
echo "    --project=$PROJECT_ID \\"
echo "    --collection-group=items \\"
echo "    --query-scope=COLLECTION \\"
echo "    --field-config=vector-config='{\"dimension\":\"768\",\"flat\": \"{}\"}',field-path=item_vector"
echo ""
echo "============================================"
echo "Deploy to Cloud Run:"
echo "============================================"
echo ""
echo "gcloud run deploy YOUR_SERVICE \\"
echo "    --source . \\"
echo "    --region=$REGION \\"
echo "    --allow-unauthenticated \\"
echo "    --set-env-vars GCP_PROJECT_ID=$PROJECT_ID"
echo ""
echo "Note: NO VPC configuration needed! Firestore uses ADC."
echo ""
echo "Deployment Complete. Check Console at: https://console.cloud.google.com/firestore"

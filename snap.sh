#!/bin/bash

# Threshold in days
THRESHOLD_DAYS=10

# Get current date in seconds
CURRENT_DATE=$(date +%s)

echo "Snapshots older than $THRESHOLD_DAYS days:"
echo "------------------------------------------"

> snapshots.txt

# List all snapshots in JSON format
gcloud compute snapshots list --format="json" | jq -c '.[]' | while read -r snapshot; do
    # Extract snapshot details
    NAME=$(echo "$snapshot" | jq -r '.name')
    CREATION_TIMESTAMP=$(echo "$snapshot" | jq -r '.creationTimestamp')
    SIZE_GB=$(echo "$snapshot" | jq -r '.diskSizeGb')
    CREATION_TYPE=$(echo "$snapshot" | jq -r '.creationType // "Unknown"')

    # Convert creation timestamp to seconds
    SNAPSHOT_DATE=$(date -d "$CREATION_TIMESTAMP" +%s)
    AGE=$(( (CURRENT_DATE - SNAPSHOT_DATE) / 86400 ))

    if [ "$AGE" -gt "$THRESHOLD_DAYS" ]; then
        echo "Snapshot: $NAME | Age: $AGE days | Size: ${SIZE_GB}GB | Type: $CREATION_TYPE" >> snapshots.txt
    fi
done


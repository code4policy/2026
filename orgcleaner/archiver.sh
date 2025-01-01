#!/bin/bash

# Organization name
ORG="code4policy"

# List of assignment prefixes to archive (separate by spaces)
ASSIGNMENTS=("cli-filter" " functions" "cowsay" "universe" "simple-website" "fec-api" "mozilla-website" "fec-api-corrected" "dataviz-with-chatgpt")

# File to save archived repositories
ARCHIVED_REPOS_FILE="archived_repos.txt"

# GitHub CLI login
echo "Ensuring you're logged into GitHub CLI..."
gh auth status &> /dev/null
if [ $? -ne 0 ]; then
    echo "Not logged in. Please log in using your GitHub account."
    gh auth login
else
    echo "Already logged in."
fi

# Start fresh log file
echo "Archiving repositories for organization: $ORG" > $ARCHIVED_REPOS_FILE

# Iterate through assignment prefixes
for ASSIGNMENT in "${ASSIGNMENTS[@]}"; do
    echo "Processing assignment prefix: $ASSIGNMENT"

    # Fetch and filter repositories matching the assignment prefix
    REPOS=$(gh repo list $ORG --limit 1000 --json name --jq ".[] | select(.name | startswith(\"$ASSIGNMENT-\")) | .name")

    # Check if any repositories were found
    if [ -z "$REPOS" ]; then
        echo "No repositories found for $ASSIGNMENT."
        continue
    fi

    # Archive each filtered repository
    for REPO in $REPOS; do
        echo "Archiving $REPO..."
        gh repo archive "$ORG/$REPO" --yes
        if [ $? -eq 0 ]; then
            echo "$REPO" >> $ARCHIVED_REPOS_FILE
        else
            echo "Failed to archive $REPO."
        fi
    done

done

echo "Archiving complete. Archived repositories saved to $ARCHIVED_REPOS_FILE."

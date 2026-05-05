#!/usr/bin/env bash
# Publish a release artifact to Tangled by uploading a blob and creating an
# `sh.tangled.repo.artifact` record on the configured PDS.
#
# Required environment variables:
#   TAG            - git tag name (e.g. v1.0.0)
#   ARTIFACT_PATH  - path to the file to upload
#   ARTIFACT_NAME  - display name for the artifact
#   REPO_URL       - at:// URI or URL of the repository
#
# Assumes `goat` is on PATH and an authenticated session exists
# (e.g. via `goat account login`).
#
# Adapted from https://tangled.org/oppi.li/goat/blob/main/scripts/publish-artifact.sh

set -e

TAG_HASH=$(git rev-parse "$TAG"^{tag}) &&
TAG_BYTES=$(echo -n "$TAG_HASH" | xxd -r -p | base64 | tr -d '=') &&
BLOB_OUTPUT=$(goat blob upload "$ARTIFACT_PATH") &&
echo "$BLOB_OUTPUT" &&
ARTIFACT_JSON=$(echo "$BLOB_OUTPUT" | jq --arg tag "$TAG_BYTES" --arg name "$ARTIFACT_NAME" --arg repo "$REPO_URL" --arg created "$(date -Iseconds)" '{
    "tag": {"$bytes": $tag},
    "name": $name,
    "repo": $repo,
    "$type": "sh.tangled.repo.artifact",
    "artifact": .,
    "createdAt": $created
  }') &&
echo "$ARTIFACT_JSON" > temp_artifact.json &&
cat temp_artifact.json &&
goat record create temp_artifact.json -n

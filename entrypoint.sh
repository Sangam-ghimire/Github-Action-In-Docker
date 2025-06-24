#!/bin/bash
set -e

# Determine if FE or BE environment is active
if [[ -n "$REPO_URL" && -n "$GITHUB_RUNNER_TOKEN" ]]; then
  REPO_URL="$REPO_URL"
  RUNNER_NAME="${RUNNER_NAME:-docker-runner}"
  RUNNER_TOKEN="$GITHUB_RUNNER_TOKEN"
else
  echo "❌ Missing required runner environment variables."
  exit 1
fi

# Configure only if not already configured
if [ ! -f ".runner" ]; then
  echo "🔧 Configuring GitHub Actions runner..."
  ./config.sh --url "$REPO_URL" \
              --token "$RUNNER_TOKEN" \
              --name "$RUNNER_NAME" \
              --labels "$RUNNER_NAME" \
              --work _work \
              --unattended \
              --replace
  touch .runner
else
  echo "✅ Runner already configured"
fi

# Graceful shutdown
cleanup() {
  echo "🧹 Removing runner..."
  ./config.sh remove --token "$RUNNER_TOKEN"
  rm -f .runner
  exit 0
}

trap cleanup SIGINT SIGTERM

echo "🏃 Starting GitHub Actions runner..."
./run.sh & wait $!

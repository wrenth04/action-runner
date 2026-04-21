#!/bin/bash
set -e

if [ -z "$RUNNER_URL" ]; then
  echo "RUNNER_URL 未設定"
  exit 1
fi

if [ -z "$RUNNER_TOKEN" ]; then
  echo "RUNNER_TOKEN 未設定"
  exit 1
fi

RUNNER_NAME="${RUNNER_NAME:-$(hostname)}"
RUNNER_WORKDIR="${RUNNER_WORKDIR:-_work}"
RUNNER_LABELS="${RUNNER_LABELS:-docker}"
RUNNER_GROUP="${RUNNER_GROUP:-Default}"

trap 'exit 130' INT
trap 'exit 143' TERM

if [ ! -f .runner ]; then
  echo "Configuring runner..."
  ./config.sh \
    --unattended \
    --url "$RUNNER_URL" \
    --token "$RUNNER_TOKEN" \
    --name "$RUNNER_NAME" \
    --work "$RUNNER_WORKDIR" \
    --labels "$RUNNER_LABELS" \
    --runnergroup "$RUNNER_GROUP"
fi

echo "Starting runner..."
./run.sh &
wait $!

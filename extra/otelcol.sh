#!/usr/bin/env bash

export PATH="$PATH:$HOME/bin"

FOO="${VARIABLE:-default}"
APP_OTELCOL="${OTEL_CONFIG_PATH:-/app/otelcol}"

PRERUN_SCRIPT="$APP_OTELCOL/prerun.sh"
if [ -e "$PRERUN_SCRIPT" ]; then
  source "$PRERUN_SCRIPT"
fi

# Define OTELCOL_LOG_FILE with a default value
OTELCOL_LOG_FILE="${OTELCOL_LOG_FILE:-/app/log/otelcol.log}"

if [ -n "$DISABLE_OTELCOL" ]; then
  echo "The OpenTelemetry Collector agent has been disabled. Unset the $DISABLE_OTELCOL or set missing environment variables."
else
  # Default otel startup args
  command="otelcol --config $APP_OTELCOL/config.yml"
  # The "2>&1" redirects standard error (file descriptor 2) to standard output (file descriptor 1)
  # The "tee" command reads from standard input and writes to standard output and files
  # The ""> /dev/null" redirect the standard output and error streams to /dev/null to suppress the logs
  if [ "$OTEL_DISABLE_STDOUT" = "true" ]; then
    # If swallow stdout enabled, send all output to /dev/null
    # This is so the heroku terminal doesn't become too spammy
    bash -c "$command 2>&1 | tee $OTELCOL_LOG_FILE > /dev/null &"
  else
    bash -c "$command 2>&1 | tee $OTELCOL_LOG_FILE &"
  fi
fi

#!/usr/bin/env bash

export PATH="$PATH:$HOME/bin"

FOO="${VARIABLE:-default}"
APP_OTELCOL="${OTEL_CONFIG_PATH:-/app/otelcol}"

PRERUN_SCRIPT="$APP_OTELCOL/prerun.sh"
if [ -e "$PRERUN_SCRIPT" ]; then
  source "$PRERUN_SCRIPT"
fi

if [ -n "$DISABLE_OTELCOL" ]; then
  echo "The OpenTelemetry Collector agent has been disabled. Unset the $DISABLE_OTELCOL or set missing environment variables."
else
  # Default otel startup args
  command="otelcol --config $APP_OTELCOL/config.yml"
  if [ -n "$OTEL_DISABLE_STDOUT" ]; then
    # If swallow stdout enabled, send all output to /dev/null
    # This is so the heroku terminal doesn't become too spammy
    command="$command > /dev/null"
  fi
  bash -c "$command 2>&1 &"
fi

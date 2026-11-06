#!/usr/bin/env bash

# Helper script to manage BMS Ticket Notifier background process
PID_FILE="bms.pid"
LOG_FILE="bms.log"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

case "$1" in
  start)
    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
      echo "⚠️  BMS Notifier is already running (PID: $(cat "$PID_FILE"))."
      exit 0
    fi
    echo "🚀 Starting BMS Ticket Notifier in background (every 5 mins)..."
    nohup env PYTHONUNBUFFERED=1 uv run main.py --loop 5 > "$LOG_FILE" 2>&1 &
    echo $! > "$PID_FILE"
    echo "✅ Running with PID $(cat "$PID_FILE"). Logs: tail -f $LOG_FILE"
    ;;

  stop)
    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
      PID=$(cat "$PID_FILE")
      kill "$PID"
      rm -f "$PID_FILE"
      echo "🛑 Stopped BMS Notifier (PID: $PID)."
    else
      echo "ℹ️  BMS Notifier is not running."
      rm -f "$PID_FILE"
    fi
    ;;

  status)
    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
      echo "🟢 BMS Notifier is running (PID: $(cat "$PID_FILE"))."
    else
      echo "⚪ BMS Notifier is stopped."
    fi
    ;;

  logs)
    if [ -f "$LOG_FILE" ]; then
      tail -f "$LOG_FILE"
    else
      echo "Log file $LOG_FILE does not exist yet. Start the notifier first with ./daemon.sh start"
    fi
    ;;

  *)
    echo "Usage: $0 {start|stop|status|logs}"
    exit 1
    ;;
esac


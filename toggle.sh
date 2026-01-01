#!/bin/bash

# 通知のオンオフを切り替えるスクリプト

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.json"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "エラー: config.json が見つかりません"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "エラー: jq がインストールされていません"
    exit 1
fi

ACTION="$1"

case "$ACTION" in
    on)
        jq '.enabled = true' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
        echo "通知をオンにしました"
        ;;
    off)
        jq '.enabled = false' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
        echo "通知をオフにしました"
        ;;
    status)
        ENABLED=$(jq -r '.enabled' "$CONFIG_FILE")
        if [ "$ENABLED" = "true" ]; then
            echo "通知: オン"
        else
            echo "通知: オフ"
        fi
        ;;
    *)
        ENABLED=$(jq -r '.enabled' "$CONFIG_FILE")
        if [ "$ENABLED" = "true" ]; then
            jq '.enabled = false' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
            echo "通知をオフにしました"
        else
            jq '.enabled = true' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
            echo "通知をオンにしました"
        fi
        ;;
esac

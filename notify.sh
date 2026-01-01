#!/bin/bash

# Claude Code 完了通知スクリプト
# Discord Webhookを使用してiPhoneに通知を送信

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.json"

# 設定ファイルの存在確認
if [ ! -f "$CONFIG_FILE" ]; then
    echo "エラー: config.json が見つかりません"
    exit 1
fi

# jqがインストールされているか確認
if ! command -v jq &> /dev/null; then
    echo "エラー: jq がインストールされていません"
    echo "インストール: brew install jq"
    exit 1
fi

# 設定を読み込み
WEBHOOK_URL=$(jq -r '.webhook_url' "$CONFIG_FILE")
DISCORD_USER_ID=$(jq -r '.discord_user_id' "$CONFIG_FILE")
DEFAULT_MESSAGE=$(jq -r '.notification_message' "$CONFIG_FILE")

# 設定の検証
if [ "$WEBHOOK_URL" = "YOUR_DISCORD_WEBHOOK_URL_HERE" ] || [ -z "$WEBHOOK_URL" ]; then
    echo "エラー: webhook_url を config.json に設定してください"
    exit 1
fi

# カスタムメッセージがあれば使用、なければデフォルト
MESSAGE="${1:-$DEFAULT_MESSAGE}"

# User IDが設定されていればメンション付き、なければ普通に送信
if [ -n "$DISCORD_USER_ID" ] && [ "$DISCORD_USER_ID" != "YOUR_DISCORD_USER_ID_HERE" ] && [ "$DISCORD_USER_ID" != "null" ]; then
    CONTENT="<@$DISCORD_USER_ID> $MESSAGE"
else
    CONTENT="$MESSAGE"
fi

# Discord Webhookに送信
JSON_PAYLOAD=$(jq -n \
    --arg content "$CONTENT" \
    '{content: $content}')

RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Content-Type: application/json" \
    -d "$JSON_PAYLOAD" \
    "$WEBHOOK_URL")

if [ "$RESPONSE" = "204" ] || [ "$RESPONSE" = "200" ]; then
    echo "通知を送信しました"
else
    echo "エラー: 通知の送信に失敗しました (HTTP $RESPONSE)"
    exit 1
fi

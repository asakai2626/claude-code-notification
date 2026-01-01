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
ENABLED=$(jq -r '.enabled' "$CONFIG_FILE")
WEBHOOK_URL=$(jq -r '.webhook_url' "$CONFIG_FILE")
DISCORD_USER_ID=$(jq -r '.discord_user_id' "$CONFIG_FILE")

# 通知が無効なら終了
if [ "$ENABLED" != "true" ]; then
    exit 0
fi

# 設定の検証
if [ "$WEBHOOK_URL" = "YOUR_DISCORD_WEBHOOK_URL_HERE" ] || [ -z "$WEBHOOK_URL" ]; then
    echo "エラー: webhook_url を config.json に設定してください"
    exit 1
fi

# stdinからhook入力を読み取る
HOOK_INPUT=$(cat)

# transcript_pathを取得
TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path // empty')

# デフォルトメッセージ
REQUEST_TEXT="不明"
RESULT_TEXT="不明"

# transcript_pathがあれば会話内容を取得
if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
    # 最初のユーザーリクエストを取得（type: "user"）
    REQUEST_TEXT=$(grep -m1 '"type":"user"' "$TRANSCRIPT_PATH" 2>/dev/null | jq -r '.message.content // empty' | head -c 200)

    # 最後のAssistant出力を取得（type: "assistant"）
    # contentが配列の場合はtextを抽出、文字列ならそのまま使用
    RESULT_TEXT=$(grep '"type":"assistant"' "$TRANSCRIPT_PATH" 2>/dev/null | tail -1 | jq -r '.message.content | if type == "array" then map(select(.type == "text") | .text) | join("") else . end // empty' | head -c 200)

    # 空の場合はデフォルト
    [ -z "$REQUEST_TEXT" ] && REQUEST_TEXT="取得できませんでした"
    [ -z "$RESULT_TEXT" ] && RESULT_TEXT="取得できませんでした"
fi

# メッセージを組み立て
MESSAGE="【Claude Codeの作業が完了しました！】

**リクエスト:**
${REQUEST_TEXT}

**結果:**
${RESULT_TEXT}"

# User IDが設定されていればメンション付き、なければ普通に送信
if [ -n "$DISCORD_USER_ID" ] && [ "$DISCORD_USER_ID" != "YOUR_DISCORD_USER_ID_HERE" ] && [ "$DISCORD_USER_ID" != "null" ]; then
    CONTENT="<@$DISCORD_USER_ID>
$MESSAGE"
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

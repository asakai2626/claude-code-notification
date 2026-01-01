#!/bin/bash

# セットアップスクリプト
# Discord通知の設定を対話的に行います

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.json"

echo "=== Claude Code Discord通知 セットアップ ==="
echo ""

# jqの確認
if ! command -v jq &> /dev/null; then
    echo "jq がインストールされていません。インストールしますか？ (y/n)"
    read -r INSTALL_JQ
    if [ "$INSTALL_JQ" = "y" ]; then
        brew install jq
    else
        echo "jq が必要です。手動でインストールしてください: brew install jq"
        exit 1
    fi
fi

echo "Discord Webhook URLを入力してください:"
echo "(Discordサーバーの設定 > 連携サービス > ウェブフック で作成できます)"
read -r WEBHOOK_URL

echo ""
echo "Discord User IDを入力してください:"
echo "(開発者モードを有効にし、自分のプロフィールを右クリック > IDをコピー)"
read -r USER_ID

echo ""
echo "通知メッセージを入力してください (Enterでデフォルト):"
read -r MESSAGE

if [ -z "$MESSAGE" ]; then
    MESSAGE="Claude Codeの作業が完了しました！"
fi

# config.jsonを更新
cat > "$CONFIG_FILE" << EOF
{
  "webhook_url": "$WEBHOOK_URL",
  "discord_user_id": "$USER_ID",
  "notification_message": "$MESSAGE"
}
EOF

echo ""
echo "設定を保存しました！"
echo ""
echo "テスト通知を送信しますか？ (y/n)"
read -r TEST

if [ "$TEST" = "y" ]; then
    "$SCRIPT_DIR/notify.sh" "セットアップテスト通知"
fi

echo ""
echo "=== Claude Code hooks の設定方法 ==="
echo ""
echo "~/.claude/settings.json に以下を追加してください:"
echo ""
cat << 'EOF'
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "$SCRIPT_DIR/notify.sh"
          }
        ]
      }
    ]
  }
}
EOF
echo ""
echo "※ \$SCRIPT_DIR を実際のパスに置き換えてください:"
echo "   $SCRIPT_DIR/notify.sh"

# Claude Code Discord Notification

Claude Codeの作業が完了したときに、Discord経由でiPhoneに通知を送るツールです。

## 仕組み

Claude Codeの「hooks」機能を使い、作業完了時にDiscord Webhookで通知を送信します。
Discordアプリの通知をONにしておけば、iPhoneにプッシュ通知が届きます。

## 必要なもの

- Mac（Claude Codeが動作する環境）
- Discordアカウント
- iPhoneのDiscordアプリ（通知を受け取る用）
- Homebrew（jqのインストールに使用）

---

## セットアップ手順

### Step 1: このリポジトリをクローン

```bash
git clone https://github.com/your-username/claude-code-notification.git
cd claude-code-notification
```

### Step 2: Discord側の準備

#### 2-1. 自分専用のサーバーを作成

1. Discordの左側にある「**＋**」ボタンをクリック
2. 「**オリジナルを作成**」を選択
3. 「**自分と友達のため**」を選択
4. サーバー名を入力（例：「通知」）
5. 「**新規作成**」をクリック

> 既存のサーバーを使う場合はこの手順をスキップしてください

#### 2-2. Webhook URLを取得

1. サーバー名を**右クリック** →「**サーバー設定**」
2. 左メニューの「**連携サービス**」をクリック
3. 「**ウェブフック**」をクリック
4. 「**新しいウェブフック**」をクリック
5. 「**ウェブフックURLをコピー**」をクリック

> このURLをメモしておいてください

#### 2-3. User IDを取得

1. 左下の**歯車アイコン**（ユーザー設定）をクリック
2. 「**詳細設定**」をクリック
3. 「**開発者モード**」を**ON**にする
4. 設定を閉じて、自分のアイコンを**右クリック**
5. 「**ユーザーIDをコピー**」をクリック

> このIDもメモしておいてください（メンション通知に使います）

### Step 3: セットアップスクリプトを実行

```bash
# jqをインストール（まだの場合）
brew install jq

# セットアップを実行
./setup.sh
```

質問に順番に答えてください：

```
Discord Webhook URLを入力してください:
→ Step 2-2でコピーしたURLを貼り付け

Discord User IDを入力してください:
→ Step 2-3でコピーしたIDを貼り付け

通知メッセージを入力してください:
→ そのままEnterでOK（カスタマイズも可能）

テスト通知を送信しますか？ (y/n)
→ y を入力
```

**Discordに通知が届いたら成功です！**

### Step 4: Claude Codeの設定

`~/.claude/settings.json` を編集します：

```bash
nano ~/.claude/settings.json
```

以下の内容を追加してください：

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/claude-code-notification/notify.sh"
          }
        ]
      }
    ]
  }
}
```

> `/path/to/` の部分は実際のパスに置き換えてください
> 例: `/Users/username/claude-code-notification/notify.sh`

**保存方法（nanoの場合）：**
1. `Ctrl + O` → `Enter`（保存）
2. `Ctrl + X`（終了）

### Step 5: iPhoneの通知設定

1. iPhoneで**Discordアプリ**を開く
2. 通知用の**サーバー**を開く
3. サーバー名をタップ →「**通知設定**」
4. 「**すべてのメッセージ**」または「**@mentionsのみ**」を選択

---

## 使い方

セットアップ完了後は、Claude Codeが作業を終了するたびに自動で通知が届きます。

### 手動で通知を送る

```bash
# デフォルトメッセージで送信
./notify.sh

# カスタムメッセージで送信
./notify.sh "ビルドが完了しました"
```

---

## 設定ファイル

`config.json` で設定を変更できます：

```json
{
  "webhook_url": "https://discord.com/api/webhooks/...",
  "discord_user_id": "123456789012345678",
  "notification_message": "Claude Codeの作業が完了しました！"
}
```

| 項目 | 説明 |
|------|------|
| `webhook_url` | Discord Webhook URL |
| `discord_user_id` | 通知を受け取るユーザーのID（メンションされます） |
| `notification_message` | デフォルトの通知メッセージ |

---

## トラブルシューティング

### 「jq がインストールされていません」と表示される

```bash
brew install jq
```

### 通知が届かない

1. Webhook URLが正しいか確認
2. User IDが正しいか確認
3. テスト送信を試す: `./notify.sh "テスト"`
4. Discordアプリの通知設定を確認

### Claude Codeで自動通知されない

1. `~/.claude/settings.json` のパスが正しいか確認
2. `notify.sh` に実行権限があるか確認: `chmod +x notify.sh`

---

## ライセンス

MIT

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
git clone https://github.com/asakai2626/claude-code-notification.git
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

#### 2-3. User IDを取得（オプション）

メンション通知が必要な場合のみ設定してください。設定しない場合は普通にメッセージが送信されます。

1. 左下の**歯車アイコン**（ユーザー設定）をクリック
2. 「**詳細設定**」をクリック
3. 「**開発者モード**」を**ON**にする
4. 設定を閉じて、**左下の自分のアイコン**を**右クリック**
5. 「**ユーザーIDをコピー**」をクリック

### Step 3: 設定ファイルを編集

```bash
# jqをインストール（まだの場合）
brew install jq
```

`config.example.json` をコピーして `config.json` を作成し、編集します：

```bash
cp config.example.json config.json
nano config.json
```

```json
{
  "enabled": true,
  "webhook_url": "ここにStep 2-2でコピーしたURLを貼り付け",
  "discord_user_id": "",
  "notification_message": "Claude Codeの作業が完了しました！"
}
```

| 項目 | 説明 |
|------|------|
| `enabled` | 通知のオンオフ（`true` / `false`） |
| `webhook_url` | Discord Webhook URL（必須） |
| `discord_user_id` | メンションが必要なら Step 2-3 のIDを入力（不要なら空欄） |
| `notification_message` | 通知メッセージ（お好みで変更可） |

保存したら、テスト送信してみましょう：

```bash
./notify.sh "テスト通知"
```

**Discordに通知が届いたら成功です！**

### Step 4: Claude Codeの設定

`~/.claude/settings.json` を編集します：

```bash
nano ~/.claude/settings.json
```

以下の内容を追加してください（`/path/to/` は実際のパスに置き換え）：

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
  },
  "commands": {
    "notify-on": {
      "description": "Discord通知をオンにする",
      "command": "/path/to/claude-code-notification/toggle.sh on"
    },
    "notify-off": {
      "description": "Discord通知をオフにする",
      "command": "/path/to/claude-code-notification/toggle.sh off"
    },
    "notify-status": {
      "description": "Discord通知の状態を確認",
      "command": "/path/to/claude-code-notification/toggle.sh status"
    }
  }
}
```

**設定の説明：**

| 設定 | 説明 |
|------|------|
| `hooks.Stop` | Claude Codeが作業を終了したときに `notify.sh` を実行して通知を送信 |
| `commands.notify-on` | `/notify-on` コマンドで通知をオンにする |
| `commands.notify-off` | `/notify-off` コマンドで通知をオフにする |
| `commands.notify-status` | `/notify-status` コマンドで現在の状態を確認 |

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

### 通知のオンオフを切り替える

```bash
# オンにする
./toggle.sh on

# オフにする
./toggle.sh off

# 現在の状態を確認
./toggle.sh status

# トグル（オン↔オフを切り替え）
./toggle.sh
```

### Claude Codeからスラッシュコマンドで切り替える

Step 4で設定済みの場合、Claude Code内で以下のコマンドが使えます：

| コマンド | 説明 |
|----------|------|
| `/notify-on` | 通知をオンにする |
| `/notify-off` | 通知をオフにする |
| `/notify-status` | 現在の状態を確認 |

### 手動で通知を送る

```bash
# デフォルトメッセージで送信
./notify.sh

# カスタムメッセージで送信
./notify.sh "ビルドが完了しました"
```

---

## トラブルシューティング

### 「jq がインストールされていません」と表示される

```bash
brew install jq
```

### 通知が届かない

1. Webhook URLが正しいか確認
2. テスト送信を試す: `./notify.sh "テスト"`
3. Discordアプリの通知設定を確認

### Claude Codeで自動通知されない

1. `~/.claude/settings.json` のパスが正しいか確認
2. `notify.sh` に実行権限があるか確認: `chmod +x notify.sh`

---

## ライセンス

MIT

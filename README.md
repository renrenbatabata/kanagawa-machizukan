# 🏙️ かながわくまち図鑑 – チーム開発用ルール

## 🔧 使用技術スタック

| 役割           | 技術               |
| -------------- | ------------------ |
| フロントエンド | Flutter (Dart)     |
| バックエンド   | Spring Boot (Java) |
| バージョン管理 | Git / GitHub       |

---

## 📁 プロジェクト構成

```
kanagawaku-matizukan/
├── frontend/       # Flutterプロジェクト
├── backend/        # Spring Bootプロジェクト
├── .gitignore
├── README.md
```

python 追加するか予定

---

## 🪜 Git 運用ルール

### ✅ ブランチ運用方針

| ブランチ名    | 用途                                       |
| ------------- | ------------------------------------------ |
| `main`        | 本番リリース用の安定ブランチ               |
| `develop`     | 開発の統合ブランチ                         |
| `feature/xxx` | 機能追加用ブランチ（例: `feature/camera`） |
| `fix/xxx`     | バグ修正用ブランチ                         |
| `design/xxx`  | UI 調整用ブランチ                          |

---

## 🧾 開発の流れ（作業手順）

1. `develop`ブランチから作業用ブランチを作成

   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/xxx
   ```

2. 作業してコミットする

   ```bash
   git add .
   git commit -m "〇〇を実装"
   ```

3. GitHub へ Push

   ```bash
   git push origin feature/xxx
   ```

4. GitHub で Pull Request を作成（マージ先：develop）

5. 他メンバーのレビュー後にマージ

---

## 🗒️ 命名ルール

- **ブランチ名**（例）:

  - `feature/camera`
  - `fix/api-error`
  - `design/home-page`

- **コミットメッセージ例**:
  - `Add: カメラ機能のUIを追加`
  - `Fix: APIエラーの修正`
  - `Design: ホーム画面のレイアウト調整`

---

## 🛑 禁止事項・注意点

- `main`と`develop`に直接 Push 禁止（必ず PR を使う）
- 機能ごとにブランチを切る
- コミットはできるだけ小さく＆わかりやすく

---

## ✍️ ローカル初期設定メモ（初回のみ）

```bash
# Git初期化（リーダーが実施済みなら不要）
git init
echo "backend/build/" >> .gitignore
echo "frontend/build/" >> .gitignore
echo ".DS_Store" >> .gitignore

# GitHubと紐づけ
git remote add origin https://github.com/xxx/kanagawaku-matizukan.git

# developブランチに切り替え
git checkout -b develop
```

---

## 🧑‍🤝‍🧑 チームメンバー

| 名前   | 担当        |
| ------ | ----------- |
| A さん | Flutter     |
| B さん | Flutter     |
| C さん | Spring Boot |

（必要に応じて更新してください）

---

## 🚀 開発の進め方メモ

- Flutter は `frontend/` で作業
- Spring Boot は `backend/` にて管理
- 環境構築や起動手順などは別ファイル（`docs/SETUP.md`など）にまとめても OK

---

## 📌 備考

- 質問・相談は GitHub の Issue でも管理可能
- 毎週 ◯ 曜日に進捗確認（など必要な運用ルールを自由に追加）

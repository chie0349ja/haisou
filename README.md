# 配送実績管理

Microsoft Accessで管理していた配送実績をWebで登録・検索するRails 7アプリです。取引先・店舗のあいまい検索、その場での仮登録、管理者による正式化・重複統合に対応しています。

## 必要環境

- Docker Desktop
- Docker Compose

## Dockerでセットアップ

```sh
docker compose build
docker compose run --rm web bin/rails db:create db:migrate db:seed
docker compose up
```

http://localhost:3000 を開いてください。

ダミーアカウント:

- 管理者: `admin@example.com` / `password123`
- 一般担当者: `staff@example.com` / `password123`

## 主な機能

- Deviseによるログイン必須化
- 配送実績の登録・編集・日付等による絞り込み
- 取引先・店舗のPostgreSQL trigramあいまい検索
- 配送登録画面からの取引先・店舗の仮登録
- 管理者による仮登録の正式化・既存マスタへの統合
- 取引先、店舗、全管理マスタの表形式インライン編集・一括保存
- 登録者・更新者の監査記録

## マスタを一括編集する

管理者でログインし、取引先、店舗、または「マスタ管理」内の画面を開きます。

1. 表のセルを直接編集します。
2. 必要に応じて「新規行を追加」から複数行を追加します。
3. 画面下部の「一括保存」で変更をまとめて確定します。

一行でも入力エラーがある場合は全件を保存せず、該当行に理由を表示します。取引先・店舗の審査待ちデータは「仮登録審査」で正式化してください。一般担当者は取引先・店舗を読み取り専用で閲覧できます。

## テスト

```sh
docker compose run --rm web bin/rails test
```

## ローカルで実行する場合

Ruby 3.3.7とPostgreSQL 14以降を用意し、接続情報を環境変数で指定します。

```sh
bundle install
export DATABASE_HOST=localhost
export DATABASE_USERNAME=postgres
export DATABASE_PASSWORD=postgres
bin/rails db:create db:migrate db:seed
bin/rails server
```

PostgreSQLではマイグレーションにより`pg_trgm`拡張が有効化されます。


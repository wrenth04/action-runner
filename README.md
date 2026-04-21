# GitHub Actions Runner Docker

這個專案用來建立與啟動 GitHub Actions self-hosted runner 容器。

## 內容

- `Dockerfile`: 建立 runner 映像
- `entrypoint.sh`: 容器啟動時自動註冊並執行 runner
- `docker-compose.yml`: 使用 Docker Compose 啟動 runner
- `.dockerignore`: 排除不需要加入 build context 的檔案

## 功能

- 使用 Ubuntu 22.04
- 下載 GitHub Actions Runner `2.333.1`
- 建立 `runner` 使用者
- `runner` 具有 `sudo` 權限且免密碼
- 容器啟動時自動執行 `config.sh`
- 容器停止時嘗試移除 runner 設定

## 需求

- Docker
- Docker Compose
- GitHub repository runner registration token

## 設定方式

請先修改 `docker-compose.yml` 內的環境變數：

```yaml
environment:
  RUNNER_URL: https://github.com/wrenth04/autosrt
  RUNNER_TOKEN: your_runner_registration_token
  RUNNER_NAME: docker-runner-01
  RUNNER_LABELS: docker,linux,x64
  RUNNER_GROUP: Default
  RUNNER_WORKDIR: _work
```

### 參數說明

- `RUNNER_URL`: GitHub repository 或 organization URL
- `RUNNER_TOKEN`: GitHub 提供的 runner registration token
- `RUNNER_NAME`: runner 名稱
- `RUNNER_LABELS`: runner labels，多個用逗號分隔
- `RUNNER_GROUP`: runner group 名稱
- `RUNNER_WORKDIR`: runner 工作目錄

## 建立與啟動

### 使用 Docker Compose

```bash
docker compose up -d --build
```

### 查看狀態

```bash
docker compose ps
docker compose logs -f
```

### 停止

```bash
docker compose down
```

## 單獨使用 docker build / run

### 建立映像

```bash
docker build -t my-github-runner .
```

### 啟動容器

```bash
docker run -d \
  --name github-runner \
  -e RUNNER_URL="https://github.com/wrenth04/autosrt" \
  -e RUNNER_TOKEN="your_runner_registration_token" \
  -e RUNNER_NAME="docker-runner-01" \
  -e RUNNER_LABELS="docker,linux,x64" \
  -e RUNNER_GROUP="Default" \
  -e RUNNER_WORKDIR="_work" \
  my-github-runner
```

## 注意事項

- `RUNNER_TOKEN` 具有時效性，過期後需要重新產生
- 建議不要把真實 token 直接提交到版本控制
- 目前 `docker-compose.yml` 內是明文設定，若要更安全可改成使用 `.env`
- 容器停止時會嘗試執行 `./config.sh remove`
- 若 runner 異常中止，GitHub 端可能仍殘留 runner 紀錄，需要手動移除

## 建議改進

如果要進一步優化，可以再加入：

- `.env` 管理敏感資訊
- volume 掛載 `_work`
- healthcheck
- 自動取得 ephemeral token 的流程
- organization 級 runner 支援

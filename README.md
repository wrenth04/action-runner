# GitHub Actions Runner Docker

這個專案用來建立與啟動 GitHub Actions self-hosted runner 容器。

## 內容

- `Dockerfile`: 建立 amd64 runner 映像
- `Dockerfile.arm64`: 建立 arm64 runner 映像
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

## Docker Hub 發佈 workflow

專案已包含 GitHub Actions workflow：`.github/workflows/docker-publish.yml`

### 觸發條件

- 推送 git tag `v*` 時自動 build 並 push 到 Docker Hub
- 可從 GitHub Actions 頁面手動執行 `workflow_dispatch`

### 需要設定的 GitHub Secrets

請在 GitHub repository secrets 設定：

- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`

建議 `DOCKERHUB_TOKEN` 使用 Docker Hub access token，不要直接使用帳號密碼。

### 需要修改的 image 名稱

workflow 內目前設定為：

```yaml
env:
  IMAGE_NAME: wrenth04/action-runner
```

如果你之後要改成其他 Docker Hub image 名稱，可直接修改這個值，例如：

```yaml
env:
  IMAGE_NAME: your-dockerhub-user/github-runner
```

### 發佈的 tags

workflow 會先分別使用：

- `Dockerfile` 建立 `linux/amd64`
- `Dockerfile.arm64` 建立 `linux/arm64`

接著合併成同一組 multi-arch tags。

當你推送例如 `v1.2.3` 時，workflow 會發佈：

- `1.2.3`
- `1.2`
- `1`
- `sha-<commit>`

手動觸發時會發佈：

- `sha-<commit>`
- `manual-<commit>`

### 驗證方式

1. 在 GitHub 建立並推送 tag，例如：

```bash
git tag v0.1.0
git push origin v0.1.0
```

2. 到 GitHub Actions 確認 workflow 成功
3. 到 Docker Hub 檢查對應 tags 是否已建立
4. 拉取映像驗證：

```bash
docker pull your-dockerhub-user/github-runner:0.1.0
```

## 注意事項

- `RUNNER_TOKEN` 具有時效性，過期後需要重新產生
- 建議不要把真實 token 直接提交到版本控制
- 目前 `docker-compose.yml` 內是明文設定，若要更安全可改成使用 `.env`
- 容器重新啟動時會沿用既有 runner 設定，不會自動執行 `./config.sh remove`
- 若你刪除容器或不再使用該 runner，需在 GitHub 端手動移除殘留 runner 紀錄

## 建議改進

如果要進一步優化，可以再加入：

- `.env` 管理敏感資訊
- volume 掛載 `_work`
- healthcheck
- 自動取得 ephemeral token 的流程
- organization 級 runner 支援

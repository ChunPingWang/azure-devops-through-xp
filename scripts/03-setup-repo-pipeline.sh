#!/usr/bin/env bash
# =============================================================
# Step 3：推送範例程式、建立 staging 環境、建立 CI/CD Pipeline、建立 Wiki
# 對應 README 第 5~8 章
# 前置：本機 git 已可存取 Azure Repos（Generate Git Credentials 或 Git Credential Manager）
# =============================================================
set -euo pipefail
source "$(dirname "$0")/00-env.sh"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PE=$(urlenc "$ADO_PROJECT")
WORK="$(mktemp -d)"

REPO_URL=$(az repos show --repository "$ADO_REPO" --query remoteUrl -o tsv)

echo ">> 推送 sample-app 到 main（XP：主幹開發 Trunk-based）"
cp -r "$ROOT/sample-app/." "$WORK/"
cd "$WORK"
git init -q -b main && git add . && git commit -q -m "chore: PointWallet 範例程式"
git remote add origin "$REPO_URL" && git push -u origin main
cd - >/dev/null

echo ">> 建立 staging 環境（Small Releases）"
ado_rest POST "$PE/_apis/distributedtask/environments?api-version=7.1" \
  '{"name":"staging","description":"每個 Iteration 結束前展示給客戶的預覽環境"}' >/dev/null || \
  echo "   （staging 可能已存在，略過）"

echo ">> 建立 CI/CD Pipeline"
az pipelines create --name "PointWallet-CI" \
  --repository "$ADO_REPO" --repository-type tfsgit \
  --branch main --yaml-path azure-pipelines.yml --skip-first-run true --output table

echo ">> 建立 Project Wiki 並匯入 wiki-pages/"
az devops wiki create --name "${ADO_PROJECT}.wiki" --type projectwiki --output none || true
for f in "$ROOT"/wiki-pages/*.md; do
  name=$(basename "$f" .md)
  az devops wiki page create --wiki "${ADO_PROJECT}.wiki" --path "/$name" \
    --file-path "$f" --encoding utf-8 --output none
  echo "   /$name"
done
echo "完成！"

#!/usr/bin/env bash
# =============================================================
# 清理：刪除教學專案（28 天內可在 Organization settings > Projects 還原）
# =============================================================
set -euo pipefail
source "$(dirname "$0")/00-env.sh"
PROJECT_ID=$(az devops project show --project "$ADO_PROJECT" --query id -o tsv)
read -r -p "確定刪除專案 '$ADO_PROJECT'？請輸入專案名稱確認：" ans
[ "$ans" = "$ADO_PROJECT" ] || { echo "名稱不符，已取消"; exit 1; }
az devops project delete --id "$PROJECT_ID" --yes
echo "已刪除 $ADO_PROJECT"

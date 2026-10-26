#!/usr/bin/env bash
# =============================================================
# 共用環境變數與輔助函式
# 使用方式：source scripts/00-env.sh
# =============================================================
export ADO_ORG="${ADO_ORG:-https://dev.azure.com/<your-org>}"
export ADO_PROJECT="${ADO_PROJECT:-PointWallet-XP-Demo}"
export ADO_TEAM="${ADO_TEAM:-${ADO_PROJECT} Team}"
export ADO_REPO="${ADO_REPO:-${ADO_PROJECT}}"

# 登入方式（擇一）：
#   1) az login                          （互動式登入，推薦）
#   2) export AZURE_DEVOPS_EXT_PAT=xxxx  （Personal Access Token，請勿寫進 Git）

if ! command -v az >/dev/null 2>&1; then
  echo "請先安裝 Azure CLI：https://learn.microsoft.com/cli/azure/install-azure-cli" >&2
  return 1 2>/dev/null || exit 1
fi
az extension show --name azure-devops >/dev/null 2>&1 || az extension add --name azure-devops
az devops configure --defaults organization="$ADO_ORG" project="$ADO_PROJECT"

# 呼叫 Azure DevOps REST API（CLI 未涵蓋的設定，例如團隊容量、Bug 行為）
# 用法：ado_rest <METHOD> <相對於 ORG 的路徑> [JSON body]
ado_rest() {
  local method="$1" path="$2" body="${3:-}"
  local auth
  if [ -n "${AZURE_DEVOPS_EXT_PAT:-}" ]; then
    auth=(-u ":${AZURE_DEVOPS_EXT_PAT}")
  else
    # 499b84ac-1321-427f-aa17-267ca6975798 為 Azure DevOps 的資源 ID
    local token
    token=$(az account get-access-token --resource 499b84ac-1321-427f-aa17-267ca6975798 --query accessToken -o tsv)
    auth=(-H "Authorization: Bearer ${token}")
  fi
  curl -fsS -X "$method" "${auth[@]}" -H "Content-Type: application/json" \
       ${body:+--data "$body"} "${ADO_ORG}/${path}"
}

# URL 編碼（專案 / 團隊名稱含空白時使用）
urlenc() { python3 -c 'import sys,urllib.parse;print(urllib.parse.quote(sys.argv[1]))' "$1"; }

echo "ADO_ORG=$ADO_ORG  ADO_PROJECT=$ADO_PROJECT"

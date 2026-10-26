#!/usr/bin/env bash
# =============================================================
# Step 1：建立 XP 專案（Agile 流程）、Release / Iteration、Area、團隊設定、容量
# 對應 README 第 2 章
# =============================================================
set -euo pipefail
source "$(dirname "$0")/00-env.sh"
P="$ADO_PROJECT"

echo ">> 建立專案（Agile 流程：User Story + Story Points 最貼近 XP）"
az devops project create --name "$P" \
  --description "零售會員「點數錢包」服務的 Extreme Programming (XP) 實戰教學專案" \
  --process Agile --source-control git --visibility private --output table

echo ">> Release Planning：建立 Release 1（3 週），把 Iteration 1~3（每週一個）移到底下"
az boards iteration project create --name "Release 1" --path "\\$P\\Iteration" \
  --start-date 2026-10-26 --finish-date 2026-11-13 --output none
declare -A START=( ["Iteration 1"]=2026-10-26 ["Iteration 2"]=2026-11-02 ["Iteration 3"]=2026-11-09 )
declare -A END=(   ["Iteration 1"]=2026-10-30 ["Iteration 2"]=2026-11-06 ["Iteration 3"]=2026-11-13 )
for it in "Iteration 1" "Iteration 2" "Iteration 3"; do
  id=$(az boards iteration project list --depth 1 --query "children[?name=='$it'].id | [0]" -o tsv)
  az boards iteration project update --path "\\$P\\Iteration\\Release 1" --child-id "$id" --output none
  az boards iteration project update --path "\\$P\\Iteration\\Release 1\\$it" \
    --start-date "${START[$it]}" --finish-date "${END[$it]}" --output table
done

echo ">> Area：依業務能力切分"
for area in "集點 Earn" "兌點 Redeem" "平台 Platform"; do
  az boards area project create --name "$area" --path "\\$P\\Area" --output none
done
az boards area team update --team "$ADO_TEAM" --path "\\$P" --include-sub-areas true --output none

PE=$(urlenc "$P"); TE=$(urlenc "$ADO_TEAM")

echo ">> 團隊設定：Bug 與 User Story 一起排在 Backlog（Agile 預設為 asTasks）"
ado_rest PATCH "$PE/$TE/_apis/work/teamsettings?api-version=7.1" '{"bugsBehavior":"asRequirements"}' >/dev/null

echo ">> Sustainable Pace：設定 Iteration 1 每人每天 6 小時（Development）"
IT1=$(ado_rest GET "$PE/$TE/_apis/work/teamsettings/iterations?api-version=7.1" \
      | python3 -c 'import sys,json;print([i["id"] for i in json.load(sys.stdin)["value"] if i["name"]=="Iteration 1"][0])')
for uid in $(ado_rest GET "_apis/projects/$PE/teams/$TE/members?api-version=7.1" \
             | python3 -c 'import sys,json;[print(m["identity"]["id"]) for m in json.load(sys.stdin)["value"]]'); do
  ado_rest PATCH "$PE/$TE/_apis/work/teamsettings/iterations/$IT1/capacities/$uid?api-version=7.1" \
    '{"activities":[{"name":"Development","capacityPerDay":6}],"daysOff":[]}' >/dev/null
done

echo "完成！$ADO_ORG/$PE"

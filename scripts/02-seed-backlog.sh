#!/usr/bin/env bash
# =============================================================
# Step 2：Planning Game — 建立 Feature / User Story / Spike / Bug / Task
# 對應 README 第 3、4 章
# =============================================================
set -euo pipefail
source "$(dirname "$0")/00-env.sh"
P="$ADO_PROJECT"; R="$P\\Release 1"
I1="$R\\Iteration 1"; I2="$R\\Iteration 2"; I3="$R\\Iteration 3"
ME="${ADO_ASSIGNEE:-$(az account show --query user.name -o tsv 2>/dev/null || echo '')}"

new_wi() { # new_wi <type> <title> <iteration> <area> [其他參數...]
  local type="$1" title="$2" it="$3" area="$4"; shift 4
  az boards work-item create --type "$type" --title "$title" --iteration "$it" --area "$area" "$@" --query id -o tsv
}
link_parent() { az boards work-item relation add --id "$1" --relation-type parent --target-id "$2" --output none; }

echo ">> Features（Release 1 範圍）"
F1=$(new_wi Feature "集點：消費自動累積點數" "$R" "$P\\集點 Earn")
F2=$(new_wi Feature "兌點：以點數折抵消費"   "$R" "$P\\兌點 Redeem")
F3=$(new_wi Feature "點數效期管理"           "$R" "$P\\集點 Earn")

story() { # story <title> <description> <acceptance> <points> <iteration> <area> <parent|-> [tags]
  local id
  id=$(new_wi "User Story" "$1" "$5" "$P\\$6" --description "$2" \
       --fields "Microsoft.VSTS.Common.AcceptanceCriteria=$3" "Microsoft.VSTS.Scheduling.StoryPoints=$4" \
                ${8:+"System.Tags=$8"})
  [ "$7" != "-" ] && link_parent "$id" "$7"
  echo "$id"
}
echo ">> User Stories（客戶寫故事、開發估點）"
U1=$(story "消費滿額自動累積點數" "身為會員，我想要消費後自動獲得點數，以便累積回饋。" \
  "每消費 NT\$100 得 1 點，未滿 100 元部分捨去（NT\$250 → 2 點）；消費金額 ≤ 0 不給點" 3 "$I1" "集點 Earn" "$F1")
U2=$(story "查詢點數餘額與明細" "身為會員，我想要查詢點數餘額與異動明細，以便掌握可用點數。" \
  "顯示目前餘額；明細依時間倒序" 2 "$I1" "集點 Earn" "$F1")
U3=$(story "Spike：評估 POS 系統串接方式" "在 4 小時時間盒內評估 Webhook vs. Message Queue。" \
  "產出一頁 Wiki 比較結論；時間盒到即停" 1 "$I1" "平台 Platform" "-" "Spike")
U4=$(story "以點數折抵消費" "身為會員，我想要結帳時使用點數折抵，以便省錢。" \
  "1 點 = NT\$1；最多折抵訂單金額 50%" 5 "$I2" "兌點 Redeem" "$F2")
U5=$(story "點數不足時拒絕兌換" "身為會員，點數不足時希望收到清楚提示。" \
  "兌換點數 > 餘額時回傳「點數不足」，餘額不變" 2 "$I2" "兌點 Redeem" "$F2")
U6=$(story "點數 12 個月到期" "身為營運人員，我希望點數自取得日起 12 個月到期。" \
  "先到期的點數先扣（FIFO）" 3 "$I3" "集點 Earn" "$F3")
U7=$(story "點數到期前 30 天通知" "身為會員，我想要在點數到期前收到通知。" \
  "到期前 30 天寄送 Email" 3 "$R" "集點 Earn" "$F3")

echo ">> Bug"
B1=$(new_wi Bug "退貨時未扣回已發放點數" "$I2" "$P\\集點 Earn" \
  --fields "Microsoft.VSTS.TCM.ReproSteps=1.消費 NT\$500 取得 5 點 2.整筆退貨 3.點數仍為 5 點" \
           "Microsoft.VSTS.Common.Severity=2 - High" "Microsoft.VSTS.Scheduling.StoryPoints=1")
link_parent "$B1" "$F1"

echo ">> Iteration Planning：開始 Iteration 1 的故事"
for id in "$U1" "$U2" "$U3"; do az boards work-item update --id "$id" --state Active ${ME:+--assigned-to "$ME"} --output none; done

task() { # task <title> <activity> <hours> <parent> [tag]
  local id
  id=$(new_wi Task "$1" "$I1" "$P" ${ME:+--assigned-to "$ME"} \
       --fields "Microsoft.VSTS.Common.Activity=$2" "Microsoft.VSTS.Scheduling.RemainingWork=$3" \
                "Microsoft.VSTS.Scheduling.OriginalEstimate=$3" ${5:+"System.Tags=$5"})
  link_parent "$id" "$4"
}
echo ">> Tasks（測試先行、Pair、重構都是一等公民）"
task "撰寫 Customer Test（驗收測試）：消費 250 元得 2 點" Testing 2 "$U1"
task "TDD：PointCalculator 計點規則（Red→Green→Refactor）" Development 4 "$U1" pair-programming
task "重構：抽出 Wallet 領域物件" Development 2 "$U1" refactoring
task "串接訂單完成事件並發放點數" Development 3 "$U1" pair-programming
task "TDD：Wallet 餘額與明細查詢" Development 3 "$U2" pair-programming
task "GET /wallets/{id} API" Development 2 "$U2"
task "驗收測試：明細倒序" Testing 2 "$U2"
task "Spike：Webhook vs. MQ 評估（時間盒 4h）" Requirements 4 "$U3" Spike

cat <<EOF
完成！
  Features: #$F1 #$F2 #$F3
  Stories : #$U1 #$U2 #$U3(Spike) #$U4 #$U5 #$U6 #$U7
  Bug     : #$B1
注意：sample-app 的 commit 訊息以 #27、#28 對應示範環境的 Work Item ID，
      請依你環境實際的 ID（上方 #$U1、#$U2）調整。
EOF

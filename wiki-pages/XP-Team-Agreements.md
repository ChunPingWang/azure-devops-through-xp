# XP 團隊工作約定

| XP 實踐 | 我們的約定 | ADO 落實方式 |
|---|---|---|
| Planning Game | 每週一 Iteration Planning，客戶排序、開發估點 | Backlogs + Planning 面板 + Forecast |
| Small Releases | 每個 Iteration 至少部署一次 staging | Pipelines Environment `staging` |
| Test-First / TDD | 先寫失敗的測試，commit 訊息標註 RED / GREEN / refactor | Repos Commits |
| Pair Programming | 所有正式程式碼都由兩人完成，每 25 分鐘交換 Driver | Task Tag `pair-programming`、commit `Co-authored-by` |
| Continuous Integration | 每天至少整合到 main 數次，分支存活 < 1 天 | CI trigger、Rebase and fast-forward |
| Collective Ownership | 任何人都可修改任何程式碼 | 不設必要審查者，所有人皆有 Contribute 權限 |
| Sustainable Pace | 每人每天投入 6 小時，不加班趕工 | Sprint Capacity |
| On-site Customer | PO 每天參與站會並驗收 Customer Test | Test Case（Tag `customer-test`） |

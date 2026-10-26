# Coding Standard

1. 測試檔與程式碼同名：`src/wallet.js` ↔ `test/wallet.test.js`
2. 測試名稱用中文描述業務規則，例如「消費金額 ≤ 0 不給點」
3. 禁止魔術數字，業務常數集中宣告（如 `AMOUNT_PER_POINT`）
4. commit 訊息格式：`type(#WorkItemId): 說明`，type 為 test / feat / refactor / fix / chore
5. Pair 完成的 commit 加上 `Co-authored-by: 姓名 <email>`

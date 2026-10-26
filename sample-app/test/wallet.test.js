const test = require('node:test');
const assert = require('node:assert');
const { Wallet } = require('../src/wallet');

test('累積點數後餘額正確', () => {
  const w = new Wallet();
  w.earn(2);
  w.earn(3);
  assert.strictEqual(w.balance, 5);
});

test('明細依時間倒序（最新在前）', () => {
  const w = new Wallet();
  w.earn(2, '訂單 A001');
  w.earn(3, '訂單 A002');
  assert.deepStrictEqual(w.history().map((e) => e.source), ['訂單 A002', '訂單 A001']);
});

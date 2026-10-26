const test = require('node:test');
const assert = require('node:assert');
const { calculatePoints } = require('../src/pointCalculator');

test('消費 NT$250 得 2 點（未滿 100 元捨去）', () => {
  assert.strictEqual(calculatePoints(250), 2);
});

test('消費金額 ≤ 0 不給點', () => {
  assert.strictEqual(calculatePoints(0), 0);
  assert.strictEqual(calculatePoints(-100), 0);
});

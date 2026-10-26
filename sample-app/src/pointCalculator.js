// 計點規則：每消費 NT$100 得 1 點，未滿部分捨去（User Story #27）
const AMOUNT_PER_POINT = 100;

function calculatePoints(amount) {
  if (amount <= 0) return 0;
  return Math.floor(amount / AMOUNT_PER_POINT);
}

module.exports = { calculatePoints, AMOUNT_PER_POINT };

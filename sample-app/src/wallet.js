// 點數錢包：餘額與異動明細（User Story #28）
class Wallet {
  constructor() {
    this.entries = [];
  }

  earn(points, source = '消費') {
    if (points <= 0) return;
    this.entries.push({ type: 'earn', points, source, at: new Date() });
  }

  get balance() {
    return this.entries.reduce((sum, e) => sum + (e.type === 'earn' ? e.points : -e.points), 0);
  }

  history() {
    return [...this.entries].reverse();
  }
}

module.exports = { Wallet };

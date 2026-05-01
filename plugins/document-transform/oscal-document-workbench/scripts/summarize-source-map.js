#!/usr/bin/env node
// Summarize source traceability map status counts.
import fs from 'node:fs';

const file = process.argv[2];
if (!file) {
  console.error('Usage: summarize-source-map.js <source-map.csv>');
  process.exit(2);
}
if (!fs.existsSync(file)) {
  console.error(`source map not found: ${file}`);
  process.exit(2);
}
const rows = fs.readFileSync(file, 'utf8').trim().split(/\r?\n/).filter(Boolean);
if (rows.length === 0) {
  console.error('source map is empty');
  process.exit(2);
}
const header = rows[0].split(',');
const statusIdx = header.indexOf('status');
if (statusIdx === -1) {
  console.error('source map missing status column');
  process.exit(2);
}
const counts = {};
for (const row of rows.slice(1)) {
  const cols = row.split(',');
  const status = cols[statusIdx] || 'unknown';
  counts[status] = (counts[status] || 0) + 1;
}
const summary = { file, total: rows.length - 1, counts };
console.log(JSON.stringify(summary, null, 2));
if ((counts.needs_review || 0) > 0) process.exit(3);

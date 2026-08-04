#!/usr/bin/env node
// Summarize source traceability map status counts.
const fs = require("fs");

function parseCsv(text) {
  const rows = [];
  let row = [];
  let cell = "";
  let inQuotes = false;
  for (let i = 0; i < text.length; i += 1) {
    const c = text[i];
    if (inQuotes) {
      if (c === '"') {
        if (text[i + 1] === '"') {
          cell += '"';
          i += 1;
        } else {
          inQuotes = false;
        }
      } else {
        cell += c;
      }
    } else if (c === '"') {
      inQuotes = true;
    } else if (c === ",") {
      row.push(cell);
      cell = "";
    } else if (c === "\n") {
      row.push(cell);
      cell = "";
      if (row.some((value) => String(value).trim() !== "")) rows.push(row);
      row = [];
    } else if (c !== "\r") {
      cell += c;
    }
  }
  if (cell.length > 0 || row.length > 0) {
    row.push(cell);
    if (row.some((value) => String(value).trim() !== "")) rows.push(row);
  }
  return rows;
}

const file = process.argv[2];
if (!file) {
  console.error("Usage: summarize-source-map.js <source-map.csv>");
  process.exit(2);
}
if (!fs.existsSync(file)) {
  console.error(`source map not found: ${file}`);
  process.exit(2);
}
const rows = parseCsv(fs.readFileSync(file, "utf8"));
if (rows.length === 0) {
  console.error("source map is empty");
  process.exit(2);
}
const header = rows[0];
const statusIdx = header.indexOf("status");
if (statusIdx === -1) {
  console.error("source map missing status column");
  process.exit(2);
}
const counts = {};
for (const row of rows.slice(1)) {
  const status = row[statusIdx] || "unknown";
  counts[status] = (counts[status] || 0) + 1;
}
const summary = { file, total: rows.length - 1, counts };
console.log(JSON.stringify(summary, null, 2));
if ((counts.needs_review || 0) > 0) process.exit(3);

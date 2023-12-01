#!/usr/bin/env node
const fs = require('node:fs');

function firstDigit(line) {
    const ds = line.match(/[1-9]/g);
    if (ds === null) {
        return null;
    }
    return Number.parseInt(ds[0]);
}

function lastDigit(line) {
    const ds = line.match(/[1-9]/g);
    if (ds === null) {
        return null;
    }
    return Number.parseInt(ds[ds.length - 1]);
}

function solve(lines) {
    let sum = 0;
    lines.forEach(line => {
        const d1 = firstDigit(line);
        const d2 = lastDigit(line);
        sum = sum + 10 * d1 + d2;
    });
    console.log('sum:', sum);
}

let fname = 'input.txt';
if (process.argv[2]) {
    fname = process.argv[2]
}

try {
    const data = fs.readFileSync(fname, 'utf8');
    const lines = data.split('\n');
    solve(lines);
} catch (err) {
    console.error(err);
}

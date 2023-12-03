#!/usr/bin/env node
"use strict";
const fs = require('node:fs');

// Read input.txt or another file, the script argument
// return array of string Not including \n
function inputLines() {
    let fname = 'input.txt';
    if (process.argv[2]) {
        fname = process.argv[2]
    }

    const data = fs.readFileSync(fname, 'utf8');
    let lines = data.split('\n');
    lines.pop();
    return lines;
}

function isPartNumber(lines, row, columns) {
    let candidates = [];

    let begin = columns[0];
    if (begin > 0) {
        --begin;
    }

    let end = columns[1];
    if (end < lines[row].length - 1) {
        ++end;
    }

    if (row > 0) {
        candidates.push(lines[row - 1].substring(begin, end));
    }
    candidates.push(lines[row].substring(begin, end));
    if (row < lines.length - 1) {
        candidates.push(lines[row + 1].substring(begin, end));
    }
    // console.log(candidates);
    // contains a symbol: anything but a digit or dot
    return candidates.some(s => s.match(/[^0-9.]/));
}

function solve(lines) {
    // bug: /\d+/gd.exec(s) looped on the first match
    const rx = RegExp('\\d+', 'gd');
    let partNumberSum = 0;
    let match;
    for (let i = 0; i < lines.length; ++i) {
        while ((match = rx.exec(lines[i])) !== null) {
            const number = Number.parseInt(match[0]);
            const indices = match.indices[0];
            // console.log(number, 'at', indices[0], indices[1]);
            if (isPartNumber(lines, i, indices)) {
                partNumberSum += number;
            }
        }
    }
    console.log("part number sum:", partNumberSum);
}

const lines = inputLines();
solve(lines);

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
    let begin = columns[0];
    if (begin > 0) {
        --begin;
    }

    let end = columns[1];
    if (end < lines[row].length - 1) {
        ++end;
    }

    let crows = []
    if (row > 0) {
        crows.push(row - 1);
    }
    crows.push(row);
    if (row < lines.length - 1) {
        crows.push(row + 1);
    }

    const candidates = crows.map(r => lines[r].substring(begin, end));
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

function parseNumbers(lines) {
    // tuples [value, row, begin_column, end_column]
    let numbers = [];
    const rx = RegExp('\\d+', 'gd');
    let match;
    for (let i = 0; i < lines.length; ++i) {
        while ((match = rx.exec(lines[i])) !== null) {
            const value = Number.parseInt(match[0]);
            const indices = match.indices[0];
            const number = [value, i, indices[0], indices[1]];
            // console.log(number);
            numbers.push(number);
        }
    }
    return numbers;
}

function adjacentValues(r, c, numbers) {
    // console.log('copmputing adjacent at', r, c);
    return numbers.filter(n => {
        const nr = n[1];
        const nbeg = n[2];
        const nend = n[3];
        return (r - 1 <= nr) && (nr <= r + 1) && (nbeg - 1 <= c ) && (c <= nend);
    }).map(n => n[0]);
}

function solve2(lines) {
    let gearRatioSum = 0;

    const numbers = parseNumbers(lines);
    // now find the gear symbols '*' and all their adjacent numbers
    // (going thru all of numbers is inefficient :blush:)
    const rx = RegExp('\\*', 'g');
    let match;
    for (let i = 0; i < lines.length; ++i) {
        while ((match = rx.exec(lines[i])) !== null) {
            const adjacent = adjacentValues(i, match.index, numbers);
            // console.log(adjacent);
            if (adjacent.length === 2) {
                gearRatioSum += adjacent[0] * adjacent[1];
            }
        }
    }
    console.log("gear ratio sum:", gearRatioSum);
}

const lines = inputLines();
solve(lines);
solve2(lines);

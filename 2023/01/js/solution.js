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

const digits = {
    "one": 1, "two": 2, "three": 3, "four": 4, "five": 5, "six": 6, "seven": 7, "eight": 8, "nine": 9
}

const digitWords = Object.keys(digits);
const digitChars = digitWords.map(dw => { return digits[dw].toString(); } )

function digitToInt(s) {
    if (s.length === 1) {
        return Number.parseInt(s);
    }
    else {
        return digits[s];
    }
}

function digits2(line) {
    const ds = line.match(/[1-9]|one|two|three|four|five|six|seven|eight|nine/g);
    return ds;
}

function firstDigit2(line) {
    const ds = digits2(line);
    if (ds === null) {
        return null;
    }
    return digitToInt(ds[0]);
}

function lastDigit2(line) {
    const a1 = digitWords.map(dw => {
        return [line.lastIndexOf(dw), digits[dw]];
    });
    const a2 = digitChars.map(dc => {
        return [line.lastIndexOf(dc), Number.parseInt(dc)];
    });
    const a = a1.concat(a2);
    const maxPair = a.reduce(function (p, v) {
        return ( p[0] > v[0] ? p : v );
    });
    // console.log(line, a, maxPair);
    if (maxPair[0] === -1) {
        return null;
    }
    return maxPair[1];
}

function solve2(lines) {
    let sum = 0;
    lines.forEach(line => {
        const d1 = firstDigit2(line);
        const d2 = lastDigit2(line);
        sum = sum + 10 * d1 + d2;
    });
    console.log('improved sum:', sum);
}

let fname = 'input.txt';
if (process.argv[2]) {
    fname = process.argv[2]
}

try {
    const data = fs.readFileSync(fname, 'utf8');
    const lines = data.split('\n');
    solve(lines);
    solve2(lines);
} catch (err) {
    console.error(err);
}

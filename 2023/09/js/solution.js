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


// "12 13    42" -> [12, 13, 42]
function parseNums(s) {
    return s.split(/\s+/).map(sn => (Number.parseInt(sn)))
}

class Sequence {
    constructor(ns) {
        this.ns = ns;
    }

    extrapolate() {
        if (this.ns.every(n => (n === 0))) {
            return 0;
        }
        else {
            const diffs = this.differences();
            const delta = diffs.extrapolate();
            return this.ns[this.ns.length - 1] + delta;
        }
    }

    extrapolate_back() {
        if (this.ns.every(n => (n === 0))) {
            return 0;
        }
        else {
            const diffs = this.differences();
            const delta = diffs.extrapolate_back();
            return this.ns[0] - delta;
        }
    }

    differences() {
        let ds = [];
        for (let i = 1; i < this.ns.length; ++i) {
            ds.push(this.ns[i] - this.ns[i - 1]);
        }
        return new Sequence(ds);
    }
}

function sum(ns) {
    return ns.reduce((e, a) => (e + a));
}

function solve(sequences) {
    const nexts = sequences.map(seq => (seq.extrapolate()));
    const s = sum(nexts);
    console.log("sum of extrapolated values", s);
}

function solve_back(sequences) {
    const nexts = sequences.map(seq => (seq.extrapolate_back()));
    const s = sum(nexts);
    console.log("sum of back-extrapolated values", s);
}

const lines = inputLines();
const sequences = lines.map(l => (new Sequence(parseNums(l))));
solve(sequences);
solve_back(sequences);

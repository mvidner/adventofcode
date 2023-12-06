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

class Race {
    constructor(time, distance) {
        this.time = time;
        this.distance = distance;
    }

    countWaysToWin() {
        let bestDistances = [];
        for (let hold = 0; hold <= this.time; ++hold) {
            const distance = (this.time - hold) * hold;
            bestDistances.push(distance);
        }
        // TODO: is there a functional way, like Ruby Enumerator#count ?
        let winningCount = 0;
        bestDistances.forEach(d => {
            if (d > this.distance) {
                winningCount += 1;
            }
        });

        return winningCount;
    }
}

// "12 13    42" -> [12, 13, 42]
function parseNums(s) {
    return s.split(/\s+/).map(sn => (Number.parseInt(sn)))
}

function parse(lines) {
    let match0 = lines[0].match(/Time:\s+(.*)/);
    let match1 = lines[1].match(/Distance:\s+(.*)/);
    let times = parseNums(match0[1]);
    let distances = parseNums(match1[1]);

    let races = [];
    for (let i = 0; i < times.length; ++i) {
        const race = new Race(times[i], distances[i]);
        races.push(race);
    }
    return races;
}

function solve(races) {
    const totalWaysToWin = races.map(r => (r.countWaysToWin())).reduce((e, a) => (e * a));
    console.log("total ways to win", totalWaysToWin);
}

const lines = inputLines();
const races = parse(lines);

solve(races);

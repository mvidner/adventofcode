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

class Sample {
    constructor(r, g, b) {
        this.r = r;
        this.g = g;
        this.b = b;
    }
}

// .id .samples[]
class GameRecord {
    constructor(id, samples) {
        this.id = id
        this.samples = samples
    }
}


function parse(lines) {
    // Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
    return lines.map(line => {
        const m = /^Game (\d+): (.*)/.exec(line);
        const id = Number.parseInt(m[1]);
        const samples = m[2].split("; ").map(s => {
            const rm = /(\d+) red/.exec(s);
            const gm = /(\d+) green/.exec(s);
            const bm = /(\d+) blue/.exec(s);
            const r = rm ? Number.parseInt(rm[1]) : 0;
            const g = gm ? Number.parseInt(gm[1]) : 0;
            const b = bm ? Number.parseInt(bm[1]) : 0;
            const sam = new Sample(r, g, b);
            // console.log(sam);
            return sam;
        });
        return new GameRecord(id, samples);
    });

}

function solve(games) {
    const limit = new Sample(12, 13, 14);

    const possible_games = games.filter(g => {
        // bug: trying to use .r .g. .b on GameRecord instead of Sample,
        // how do I prevent this?
        // return g.r <= limit.r && g.g <= limit.g && g.b <= limit.b;

        // bug: forgetting "return" in a bool function
        return g.samples.every(sam => (sam.r <= limit.r && sam.g <= limit.g && sam.b <= limit.b));
    });
    const id_sum = possible_games.map(g => g.id).reduce((i, acc) => (i + acc));
    console.log("Solution (possible games id sum):", id_sum);
}

function max2(a, b) {
    return (a > b) ? a : b;
}

function solve2(games) {
    const powers = games.map(g => {
        const min_sample = g.samples.reduce((i, acc) => {
            return new Sample(
                max2(i.r, acc.r),
                max2(i.g, acc.g),
                max2(i.b, acc.b)
            );
        });
        return min_sample.r * min_sample.g * min_sample.b;
    });
    const power_sum = powers.reduce((i, a) => (i+a));
    console.log("Solution (sum of game powers):", power_sum);
}

const lines = inputLines();
const games = parse(lines);
solve(games);
solve2(games);

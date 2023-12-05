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

class AlmanacRange {
    constructor(dest, src, len) {
        this.dest = dest;
        this.src = src;
        this.len = len;
    }
}

class AlmanacMap {
    constructor() {
        this.name = "?";
        this.ranges = [];
    }
}

class Almanac {
    constructor(seeds, maps) {
        this.seeds = seeds;
        this.maps = maps;
    }

    static parse(lines) {
        const seeds = this.parseSeeds(lines[0]);

        let maps = [];
        let curMap = null;

        let match;
        for (let i = 1; i < lines.length; ++i) {
            if (lines[i] === "") {
                // console.log(curMap);
                curMap = new AlmanacMap;
                maps.push(curMap);
            }
            else if (match = lines[i].match(/(.*) map/)) {
                curMap.name = match[0];
            }
            else {
                const nums = lines[i].split(/ +/).map(s => (Number.parseInt(s)));
                curMap.ranges.push(new AlmanacRange(nums[0], nums[1], nums[2]));
            }
        }

        return new Almanac(seeds, maps);
    }

    static parseSeeds(line) {
        const rest = line.split(": ");
        return rest[1].split(/ +/).map(s => (Number.parseInt(s)));
    }

    solve() {
    }
}

const lines = inputLines();
const almanac = Almanac.parse(lines);
almanac.solve();

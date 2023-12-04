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

class Card {
    // id: integer; lists of integers
    constructor(id, winning, mine) {
        this.id = id
        this.winning = winning;
        this.mine = mine;
    }

    // Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
    static parse(line) {
        // bug: must escape "|" in a RegExp!!!
        // bug: / / instead of / +/ again produces some "" -> NaN, so much FuN!!
        const match = line.match(/Card +(\d+): +([^|]+) +\| +(.*)/);
        // console.log(match);
        // raise if no match?
        const id = Number.parseInt(match[1]);
        const winning = Card.parseNumberList(match[2]);
        const mine = Card.parseNumberList(match[3]);
        const c = new Card(id, winning, mine);
        // console.log(c);
        return c;
    }

    static parseNumberList(s) {
        // bug: split(" ") producing empty strings
        const stringNums = s.split(/ +/);

        return stringNums.map(s => Number.parseInt(s));
    }

    score() {
        const ws = new Set(this.winning);
        const ms = new Set(this.mine);
        // WTF, not implemented yet??
        // const correct_set = ws.intersection(ms);
        let correctCount = 0;
        ms.forEach(n => {
            if (ws.has(n)) {
                correctCount += 1;
            }
        });

        if (correctCount === 0) {
            return 0;
        }
        else {
            return 2 ** (correctCount - 1);
        }
    }
}

function solve(cards) {
    const scores = cards.map(c => { return c.score()});
    // console.log(scores);
    const totalScore = scores.reduce((i, a) => (i+a));
    console.log("total score", totalScore);
}

const lines = inputLines();
// bug: map(line => Card.parse) does not do what I want
const cards = lines.map(line => { return Card.parse(line) });
solve(cards);

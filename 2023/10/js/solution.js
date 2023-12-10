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

// coordinates are screen oriented: [row, column]
class PipeMaze {
    constructor(lines) {
        this.rows = PipeMaze.parse(lines);
        this.start = this.findStart();
        this.connectStart();
    }

    static parse(lines) {
        let rows = [];
        for (let r = 0; r < lines.length; ++r) {
            const l = lines[r];
            let cells = [];
            for (let c = 0; c < l.length; ++c) {
                const ch = l[c];
                cells.push(new Cell(ch, r, c));
            }
            rows.push(cells)
        }
        return rows;
    }

    // return a pair of coords
    findStart() {
        const chIsStart = (c) => (c.ch === "S");
        let sc;
        const sr = this.rows.findIndex(cs => {
            sc = cs.findIndex(chIsStart);
            return sc !== -1;
        });
        return this.rows[sr][sc];
    }

    neighborsFor(r, c) {
        const cell = this.rows[r][c];
        // console.log("finding neis for", cell);
        const neighs = this.neighborsForBy(r, c, cell.neighborDeltas());
        return neighs;
    }

    // return array of cells: those neighbors for cell at [r, c],
    // but only by the directions given by _deltas_
    neighborsForBy(r, c, deltas) {
        let ns = [];
        deltas.forEach(delta => {
            const [nr, nc] = [r + delta[0], c + delta[1]];
            if (0 <= nr && nr < this.rows.length && 0 <= nc && nc < this.rows[nr].length) {
                const neigh = this.rows[nr][nc];
                ns.push(neigh);
            }
        });
        return ns;
    }

    // Mutate _this_ to put a regular Cell at sr sc.
    // Not needed. just need to find its connected neighbors.
    // connectStart() {...}

    // Fake!
    connectStart() {
        // true for my input and all examples but the last
        this.start.ch = "F";
    }
    // return array of cells connected to Start
    startNeighbors() {
        // const [sr, sc] = [this.sr, this.sc];
        // AAARGH bug, this.rows[sr, sc];
        // const startCell = this.rows[sr][sc];
        const [sr, sc] = [this.start.r, this.start.c];

        let startNs = [];
        const allNs = this.neighborsForBy(sr, sc, [d_up, d_down, d_left, d_right]);
        allNs.forEach(n => {
            const theirNs = this.neighborsFor(n.r, n.c);
            theirNs.forEach(cell => {
                // console.log("comparing", cell, this.start);
                if (cell === this.start) {
                    // console.log("yes");
                    startNs.push(n);
                }
            })
        });
        return startNs;
    }

    show() {
        const cellChar = (cell) => {
            return cell.isMainLoop ? cell.ch : ".";
        }
        this.rows.forEach(row => {
            const s = row.map(cellChar).join("");
            console.log(s);
        });
    }

    // solve part 1 but also mark the cells that ARE on the main loop
    solve() {
        const sNs = this.startNeighbors();

        this.start.isMainLoop = true;
        let steps = 0;
        let prev = this.start;
        // any of the pair will do
        let cur = sNs[0];

        while(cur !== this.start) {
            // console.log("steps", steps, "cur", cur);
            const ns = this.neighborsFor(cur.r, cur.c);
            // console.log(ns);
            const next = ns.find((cell) => (cell !== prev));

            cur.isMainLoop = true;
            prev = cur;
            cur = next;
            steps +=1 ;
        }
        const maxSteps = (steps + 1) / 2.0;
        console.log("furthest steps", maxSteps);
    }

    solve2() {
        let insideCount = 0;
        this.rows.forEach(row => {
            // let verticalCount = 0;
            let isInside = false;
            let isEdge = false;
            let edgeVertDelta;
            // console.log("row", row[0].r);

            for (let c = 0; c < row.length; ++c) {
                const cell = row[c];
                if (cell.isMainLoop) {
                    // console.log(cell.ch)
                    // "S" is assumed to not be a "-"
                    // if (cell.ch !== "-") {
                    if (cell.ch === "|") {
                        isInside = !isInside;
                        isEdge = false;
                        // console.log("vert, in", isInside, "c", c);
                    }
                    else if (cell.ch !== "-") { // if corner
                        if (!isEdge) {
                            // neighborDeltas always returns the vertical
                            // delta first
                            edgeVertDelta = cell.neighborDeltas()[0][0];
                            // console.log("eVD", edgeVertDelta);
                        }
                        else {
                            const newEdgeVertDelta = cell.neighborDeltas()[0][0];
                            // console.log("nEVD", newEdgeVertDelta);
                            if (edgeVertDelta !== newEdgeVertDelta) {
                                // edge has flipped us
                                isInside = !isInside;
                            }
                        }
                        isEdge = !isEdge;
                        // console.log("corner, edge", isEdge, "in", isInside, "c", c);
                    }
                }
                else {
                    if (isInside && !isEdge) {
                        // console.log("INSIDE, c", c);
                        insideCount += 1;
                    }
                }
            }

        });
        console.log("inside count", insideCount);
    }
}

// Neighbor deltas in [row, col] coords
// Hmm the puzzle calls them north south etc but whatever
const d_up = [-1, 0];
const d_down = [1, 0];
const d_left = [0, -1];
const d_right = [0, 1];

class Cell {
    // char ch: L J F 7 - | . S
    constructor(ch, r, c) {
        this.ch = ch;
        this.r = r;
        this.c = c;
    }

    // return a pair of neighbor deltas
    neighborDeltas() {
        if (this.ch === "L") {
            return [d_up, d_right];
        }
        else if(this.ch === "J") {
            return [d_up, d_left];
        }
        else if(this.ch === "7") {
            return [d_down, d_left];
        }
        else if(this.ch === "F") {
            return [d_down, d_right];
        }
        else if(this.ch === "|") {
            return [d_down, d_up];
        }
        else if(this.ch === "-") {
            return [d_left, d_right];
        }
        else if(this.ch === ".") {
            return [];
        }
        // others could return [] but our algorithm will not need it
        return undefined;
    }
}

const lines = inputLines();
const maze = new PipeMaze(lines);
// console.log(maze);
maze.solve();
maze.show();
maze.solve2();

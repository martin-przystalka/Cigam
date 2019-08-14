#!/usr/bin/env node

const { exec } = require('child_process');

const version = process.argv[2];
const path = require('path').dirname(require.main.filename)
let script = `ruby ${path}/version.rb`
if (version != undefined) {
    script += ` ${version}`;
}

exec(script, (err, stdout, stderr) => {
    if(stdout.length > 0) {
        console.log(`${stdout.trim()}`);
    }
    if(stderr.length > 0) {
        console.log(`${stderr.trim()}`);
    }
});

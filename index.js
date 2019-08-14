#!/usr/bin/env node

const { exec } = require('child_process');

const version = process.argv[2];
let script = 'ruby version.rb '
if (version != undefined) {
    script += version;
}

exec(script, (err, stdout, stderr) => {
    if(stdout.length > 0) {
        console.log(`${stdout.trim()}`);
    }
});

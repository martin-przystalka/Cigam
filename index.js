#!/usr/bin/env node

const { exec } = require('child_process');

const version = process.argv[2];

exec('ruby version.rb ' + version, (err, stdout, stderr) => {
  console.log(`${stdout}`);
});

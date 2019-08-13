#!/usr/bin/env node

const { exec } = require('child_process');

exec('ruby version.rb', (err, stdout, stderr) => {
  console.log(`${stdout}`);
});

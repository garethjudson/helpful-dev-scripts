#!/usr/bin/env node
var myArgs = process.argv.slice(2);

const date = new Date(myArgs[0]);
console.log(date.toUTCString());

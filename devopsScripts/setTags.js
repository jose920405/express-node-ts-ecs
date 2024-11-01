#!/usr/bin/env node
//Setting tags

// Function will extract the tags from previous task definition information
function getTags(taskDefinitionJson) {
  return JSON.stringify([
    ...taskDefinitionJson.tags
  ]);
}

let index = process.argv.length;
let task_definition = JSON.parse(process.argv[index-1]);

task_definition ? console.log(getTags(task_definition)) : "[]"
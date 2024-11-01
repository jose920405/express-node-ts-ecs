#!/usr/bin/env node
//Setting task definition

// Function will extract the previous task definition information
// and it will overwrite the env vars on itself for creating a new revision
function createTaskDefinitionInput(taskDefinitionJson) {
  delete taskDefinitionJson.taskDefinition.containerDefinitions[0].environment;
  delete taskDefinitionJson.taskDefinition.containerDefinitions[0].image;
  delete taskDefinitionJson.taskDefinition.containerDefinitions[0].systemControls;
  delete taskDefinitionJson.taskDefinition.taskDefinitionArn;
  delete taskDefinitionJson.taskDefinition.revision;
  delete taskDefinitionJson.taskDefinition.status;
  delete taskDefinitionJson.taskDefinition.compatibilities;
  delete taskDefinitionJson.taskDefinition.registeredAt;
  delete taskDefinitionJson.taskDefinition.registeredBy;
  delete taskDefinitionJson.taskDefinition.requiresAttributes;

  return JSON.stringify({
    ...taskDefinitionJson?.taskDefinition,
    containerDefinitions: [{
      ...taskDefinitionJson?.taskDefinition?.containerDefinitions[0],
      environment: [
        { name: 'NODE_ENV', value: 'prod' },
      ],
      image: `${process.env.AWS_ACCOUNT_ID}.dkr.ecr.${process.env.INTERNAL_AWS_REGION}.amazonaws.com/${process.env.IMAGE_NAME}:latest`,
    }],
  })
}

let index = process.argv.length;
let task_definition = JSON.parse(process.argv[index - 1]);

task_definition ? console.log(createTaskDefinitionInput(task_definition)) : "{}"
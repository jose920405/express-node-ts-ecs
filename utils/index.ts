import AWS from 'aws-sdk';

// Constants
import { EIP_ALLOCATION_ID, ENDPOINT_INSTANCE_ID } from './constants';
import to from 'await-to-js';

const getCurrentInstance = async (): Promise<string> => {
  return new Promise((resolve, reject) => {
    const meta = new AWS.MetadataService();
    meta.request(ENDPOINT_INSTANCE_ID, (err, data) => {
      if (err) {
        return reject(err);
      }

      const instanceId = data;
      return resolve(instanceId);
    });
  });
};

export const associateEIPWithInstanceId = async (): Promise<string> => {
  return new Promise(async (resolve, reject) => {
    const [errInstanceId, instanceId] = await to<string>(getCurrentInstance());
    if (errInstanceId) {
      console.log('32 Error getting the instanceID >>> ', errInstanceId);
      return;
    }

    const params = {
      AllocationId: EIP_ALLOCATION_ID,
      InstanceId: instanceId,
    };

    const ec2 = new AWS.EC2({ region: 'us-east-1' });
    const [errAsso, successAssociation] = await to(ec2.associateAddress(params).promise());
    if (errAsso) {
      console.log('37 errAsso >>> ', errAsso);
      return;
    }
    console.log('40 successAssociation >>> ', successAssociation);
    return true;
  });
};
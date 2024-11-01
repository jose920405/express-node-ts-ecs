import to from 'await-to-js';
import express, { Request, Response } from 'express';

// Utils
import { associateEIPWithInstanceId } from '../utils';

console.log('7 process.env.NODE_ENV >>> ', process.env.NODE_ENV);

const app = express();

const PORT = process.env.PORT || 80; // Default
const ENV = process.env.NODE_ENV || 'dev'; // Defined only in the task definition

app.get('/main', (req: Request, res: Response) => {
  res.json({ mensaje: `Hi Main, port ${PORT}` });
});

// app.get('/sign', (req: Request, res: Response) => {
//   res.json({ mensaje: `Hi Sign, port ${PORT}` });
// });

app.listen(PORT, async () => {
  console.log(`Server running on por ${PORT}`);

  if (ENV !== 'prod') {
    console.log('26 Environment is not prod >>>>>>>>> ');
    return;
  }

  // Associate the EIP to the instance
  const [err] = await to(associateEIPWithInstanceId());
  if (err) {
    console.log('32 Error getting the instanceID >>> ', err);
    return;
  }
});

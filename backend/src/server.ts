import { createApp } from './app';
import { env } from './config/env';

const app = createApp();

app.listen(env.port, () => {
  console.log(`Luminous backend listening on http://127.0.0.1:${env.port}`);
});


import { IJWTPayload } from 'jetti-middle';
import PostAfterEchangeServer from '../Forms/Form.PostAfterEchange.server';

export async function startSheduledTasks() {

  const user: IJWTPayload = {
    timezoneOffset: 0,
    description: 'user for task sheduler',
    email: '',
    isAdmin: true,
    env: {},
    roles: ['Admin']
  };

  const PostAfterEchangeServerForm = new PostAfterEchangeServer(user);
  // await PostAfterEchangeServerForm.Execute();
}

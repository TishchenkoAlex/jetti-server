const LOG_GLOBAL: any[] = [];
const MAX_LOG_SIZE = 100;

export const logEvent = (message: string, ...args: any[]) => {
  console.debug(message, ...args);
  LOG_GLOBAL.push({ message, args, timestamp: new Date() });
  if (LOG_GLOBAL.length > MAX_LOG_SIZE) {
    LOG_GLOBAL.splice(0, LOG_GLOBAL.length - MAX_LOG_SIZE);
  }
}

export const getLog = () => [...LOG_GLOBAL];
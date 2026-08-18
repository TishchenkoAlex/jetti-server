import { IJWTPayload } from 'jetti-middle';
import { Server as SocketIO } from 'socket.io';

let socketServer: SocketIO | null = null;

export function registerSocketServer(server: SocketIO): void {
  socketServer = server;
}

export function userSocketsEmit(user: IJWTPayload | null, event: string, payload: any) {
  try {
    if (!socketServer) return;
    socketServer.emit(event, payload);
    /*     if (!(user && user.email)) {
          // IO.emit(event, payload);
        } else {
          Object.keys(IO.sockets.connected).forEach(k => {
            const socket = IO.sockets.connected[k];
            if (socket.connected && socket.handshake.query.user === user.email) socket.emit(event, payload);
          });
        }*/
  } catch (err) { console.error('socket err', err); }
}

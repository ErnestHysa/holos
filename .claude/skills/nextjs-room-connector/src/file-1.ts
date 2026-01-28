// pages/api/socket.ts
import { Server as SocketIOServer } from 'socket.io';
import { Server as HTTPServer } from 'http';
import { NextApiRequest, NextApiResponse } from 'next';

export const config = {
  api: {
    bodyParser: false,
  },
};

export default function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  if (!res.socket.server.io) {
    const httpServer: HTTPServer = res.socket.server as any;
    const io = new SocketIOServer(httpServer, {
      path: '/api/socket',
      addTrailingSlash: false,
      cors: {
        origin: process.env.NEXT_PUBLIC_APP_URL || '*',
        methods: ['GET', 'POST'],
      },
    });

    // Room event handlers
    io.on('connection', (socket) => {
      socket.on('join-room', async ({ roomId, userId, userData }) => {
        socket.join(roomId);
        
        // Notify existing participants
        socket.to(roomId).emit('user-joined', {
          userId,
          userData,
          socketId: socket.id
        });

        // Send current room state to new user
        const roomState = await getRoomState(roomId);
        socket.emit('room-state', roomState);
      });

      socket.on('room-action', async ({ roomId, action, payload }) => {
        // Broadcast action to all room participants
        io.to(roomId).emit('room-action', {
          action,
          payload,
          senderId: socket.id,
          timestamp: Date.now()
        });

        // Persist action if needed
        await persistRoomAction(roomId, action, payload);
      });

      socket.on('leave-room', ({ roomId, userId }) => {
        socket.leave(roomId);
        socket.to(roomId).emit('user-left', { userId, socketId: socket.id });
      });

      socket.on('disconnect', () => {
        // Handle cleanup
      });
    });

    res.socket.server.io = io;
  }
  res.end();
}

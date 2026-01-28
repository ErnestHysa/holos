// hooks/useRoom.ts
import { useEffect, useState, useCallback } from 'react';
import { io, Socket } from 'socket.io-client';

interface UseRoomOptions {
  roomId?: string;
  userId: string;
  userData?: Record<string, any>;
}

export function useRoom({ roomId, userId, userData }: UseRoomOptions) {
  const [socket, setSocket] = useState<Socket | null>(null);
  const [isConnected, setIsConnected] = useState(false);
  const [roomState, setRoomState] = useState<any>(null);
  const [participants, setParticipants] = useState<any[]>([]);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!roomId) return;

    const socketInstance = io({
      path: '/api/socket',
      transports: ['websocket', 'polling']
    });

    socketInstance.on('connect', () => {
      setIsConnected(true);
      socketInstance.emit('join-room', { roomId, userId, userData });
    });

    socketInstance.on('disconnect', () => {
      setIsConnected(false);
    });

    socketInstance.on('room-state', (state) => {
      setRoomState(state);
    });

    socketInstance.on('user-joined', (data) => {
      setParticipants(prev => [...prev, data]);
    });

    socketInstance.on('user-left', (data) => {
      setParticipants(prev => prev.filter(p => p.userId !== data.userId));
    });

    socketInstance.on('room-action', (data) => {
      // Handle incoming actions from other participants
      handleRoomAction(data);
    });

    socketInstance.on('error', (err) => {
      setError(err.message);
    });

    setSocket(socketInstance);

    return () => {
      socketInstance.disconnect();
    };
  }, [roomId, userId, userData]);

  const sendAction = useCallback((action: string, payload: any) => {
    if (socket && isConnected && roomId) {
      socket.emit('room-action', { roomId, action, payload });
    }
  }, [socket, isConnected, roomId]);

  const leaveRoom = useCallback(() => {
    if (socket && roomId) {
      socket.emit('leave-room', { roomId, userId });
    }
  }, [socket, roomId, userId]);

  return {
    isConnected,
    roomState,
    participants,
    error,
    sendAction,
    leaveRoom
  };
}

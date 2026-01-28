// components/RoomLobby.tsx
'use client';

import { useEffect } from 'react';
import { useRoom } from '@/hooks/useRoom';

interface RoomLobbyProps {
  roomId: string;
  userId: string;
  userData?: Record<string, any>;
  onStart: () => void;
}

export function RoomLobby({ roomId, userId, userData, onStart }: RoomLobbyProps) {
  const { isConnected, participants, sendAction, error } = useRoom({
    roomId,
    userId,
    userData
  });

  const handleStart = () => {
    sendAction('start-session', { timestamp: Date.now() });
    onStart();
  };

  if (error) {
    return <div className="error">{error}</div>;
  }

  return (
    <div className="room-lobby">
      <div className="connection-status">
        {isConnected ? '🟢 Connected' : '🔴 Connecting...'}
      </div>

      <div className="room-info">
        <h2>Room Code: <span className="code">{roomId}</span></h2>
        <p>Participants: {participants.length}</p>
      </div>

      <div className="participants-list">
        {participants.map((participant, index) => (
          <div key={index} className="participant">
            {participant.userData?.name || `User ${index + 1}`}
            {participant.role === 'creator' && ' 👑'}
          </div>
        ))}
      </div>

      <button 
        onClick={handleStart} 
        disabled={!isConnected || participants.length < 2}
      >
        Start Session
      </button>
    </div>
  );
}

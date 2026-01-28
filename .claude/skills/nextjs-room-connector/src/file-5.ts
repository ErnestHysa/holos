// components/RoomJoiner.tsx
'use client';

import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';

interface RoomJoinerProps {
  userId: string;
  onRoomJoined: (room: { id: string; code: string }) => void;
}

export function RoomJoiner({ userId, onRoomJoined }: RoomJoinerProps) {
  const [roomCode, setRoomCode] = useState('');
  const [isValidating, setIsValidating] = useState(false);

  const { data: roomData, isLoading } = useQuery({
    queryKey: ['room', roomCode],
    queryFn: async () => {
      if (!roomCode) return null;
      const response = await fetch(`/api/rooms?code=${roomCode}`);
      if (!response.ok) throw new Error('Room not found');
      return response.json();
    },
    enabled: isValidating && roomCode.length === 6,
    retry: false
  });

  const handleJoinRoom = () => {
    if (roomCode.length === 6) {
      setIsValidating(true);
    }
  };

  useEffect(() => {
    if (roomData?.success && roomData?.room) {
      // Add user to room participants
      fetch(`/api/rooms/${roomData.room.id}/join`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ userId })
      }).then(() => {
        onRoomJoined(roomData.room);
      });
    }
  }, [roomData, userId, onRoomJoined]);

  return (
    <div className="room-joiner">
      <h2>Join a Room</h2>
      
      <label>
        Room Code:
        <input
          type="text"
          value={roomCode}
          onChange={(e) => setRoomCode(e.target.value.toUpperCase())}
          maxLength={6}
          placeholder="Enter 6-digit code"
        />
      </label>

      <button
        onClick={handleJoinRoom}
        disabled={roomCode.length !== 6 || isLoading}
      >
        {isLoading ? 'Finding room...' : 'Join Room'}
      </button>
    </div>
  );
}

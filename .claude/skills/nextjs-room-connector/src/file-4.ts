// components/RoomCreator.tsx
'use client';

import { useState } from 'react';
import { useMutation } from '@tanstack/react-query';

interface RoomCreatorProps {
  userId: string;
  onRoomCreated: (room: { id: string; code: string }) => void;
}

export function RoomCreator({ userId, onRoomCreated }: RoomCreatorProps) {
  const [maxParticipants, setMaxParticipants] = useState(8);
  const [isCreating, setIsCreating] = useState(false);

  const createRoomMutation = useMutation({
    mutationFn: async (params: { maxParticipants: number }) => {
      const response = await fetch('/api/rooms', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          creatorId: userId,
          maxParticipants: params.maxParticipants
        })
      });
      
      if (!response.ok) throw new Error('Failed to create room');
      return response.json();
    },
    onSuccess: (data) => {
      onRoomCreated(data.room);
      setIsCreating(false);
    },
    onError: (error) => {
      console.error('Room creation failed:', error);
      // Show error to user
    }
  });

  const handleCreateRoom = () => {
    setIsCreating(true);
    createRoomMutation.mutate({ maxParticipants });
  };

  return (
    <div className="room-creator">
      <h2>Create a New Room</h2>
      
      <label>
        Maximum Participants:
        <input
          type="number"
          min="2"
          max="100"
          value={maxParticipants}
          onChange={(e) => setMaxParticipants(parseInt(e.target.value))}
        />
      </label>

      <button
        onClick={handleCreateRoom}
        disabled={createRoomMutation.isPending || isCreating}
      >
        {isCreating ? 'Creating...' : 'Create Room'}
      </button>
    </div>
  );
}

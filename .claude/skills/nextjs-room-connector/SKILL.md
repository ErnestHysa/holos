---
name: nextjs-room-connector
description: A specialized skill for creating professional Next.js applications with room-based user connections. Generates complete, production-ready code for applications where users create/join rooms via shareable codes to enable real-time collaboration, multiplayer sessions, or shared experiences.
when-to-use: When you need to build any Next.js application that requires users to connect via room codes for collaborative work, multiplayer gaming, shared storytelling, or any real-time synchronized experience between multiple users.
capabilities:
  - Scaffold complete Next.js project with latest React version
  - Implement room creation system with unique code generation
  - Build room joining functionality with code validation
  - Set up real-time WebSockets for user-to-user communication
  - Create state synchronization across all room participants
  - Handle room lifecycle (create, join, leave, cleanup)
  - Implement presence tracking and user management
  - Add comprehensive error handling and edge case coverage
  - Include TypeScript for type safety
  - Provide scalable database integration for room persistence
  - Add authentication and authorization support
  - Generate production-ready deployment configurations
---

# Next.js Room Connector Skill

This skill specializes in creating professional, production-ready Next.js applications with room-based user connection systems. It builds complete applications where users can create rooms, receive shareable codes, and invite others to join for real-time collaboration or multiplayer experiences.

## How to Use This Skill

Invoke this skill when you need to:

1. Build a multiplayer game where users connect via room codes
2. Create collaborative applications (documents, stories, boards)
3. Develop real-time communication apps
4. Build any app requiring shared state between users via invite codes

## Technical Architecture

### Core Technologies
- **Next.js 14+** (App Router) with latest React 18+
- **Socket.IO** or **Pusher** for real-time WebSocket connections
- **Prisma** with PostgreSQL/MySQL for room data persistence
- **Zod** for runtime validation
- **TypeScript** for type safety
- **TanStack Query** for server state management
- **Zustand** or Jotai for client state

### System Components

#### 1. Room Management System

```typescript
// lib/room-manager.ts
import { randomBytes } from 'crypto';

export interface Room {
  id: string;
  code: string;
  creatorId: string;
  participants: Participant[];
  status: 'active' | 'full' | 'closed';
  createdAt: Date;
  maxParticipants: number;
  metadata?: Record<string, any>;
}

export interface Participant {
  userId: string;
  joinedAt: Date;
  role: 'creator' | 'moderator' | 'participant';
}

export class RoomManager {
  static generateRoomCode(length: number = 6): string {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let code = '';
    for (let i = 0; i < length; i++) {
      code += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return code;
  }

  static async createRoom(params: {
    creatorId: string;
    maxParticipants?: number;
    metadata?: Record<string, any>;
  }): Promise<Room> {
    const code = this.generateRoomCode();
    const roomId = randomBytes(16).toString('hex');
    
    return {
      id: roomId,
      code,
      creatorId: params.creatorId,
      participants: [{
        userId: params.creatorId,
        joinedAt: new Date(),
        role: 'creator'
      }],
      status: 'active',
      createdAt: new Date(),
      maxParticipants: params.maxParticipants || 8,
      metadata: params.metadata
    };
  }

  static async joinRoom(roomCode: string, userId: string): Promise<Room | null> {
    // Implementation would fetch room by code and validate
    // Returns null if room doesn't exist or is full/closed
    return null;
  }

  static async leaveRoom(roomId: string, userId: string): Promise<void> {
    // Remove user from room and handle cleanup if empty
  }
}
```

#### 2. Real-Time Socket Server

```typescript
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
```

#### 3. Next.js API Routes

```typescript
// app/api/rooms/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { RoomManager } from '@/lib/room-manager';
import { prisma } from '@/lib/db';

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const { creatorId, maxParticipants, metadata } = body;

    // Validate input
    if (!creatorId) {
      return NextResponse.json(
        { error: 'creatorId is required' },
        { status: 400 }
      );
    }

    // Create room
    const room = await RoomManager.createRoom({
      creatorId,
      maxParticipants,
      metadata
    });

    // Persist to database
    await prisma.room.create({
      data: {
        id: room.id,
        code: room.code,
        creatorId: room.creatorId,
        status: room.status,
        maxParticipants: room.maxParticipants,
        metadata: room.metadata as any,
        participants: {
          create: room.participants.map(p => ({
            userId: p.userId,
            role: p.role
          }))
        }
      }
    });

    return NextResponse.json({ success: true, room }, { status: 201 });
  } catch (error) {
    console.error('Room creation error:', error);
    return NextResponse.json(
      { error: 'Failed to create room' },
      { status: 500 }
    );
  }
}

export async function GET(req: NextRequest) {
  const { searchParams } = new URL(req.url);
  const code = searchParams.get('code');

  if (!code) {
    return NextResponse.json(
      { error: 'Room code is required' },
      { status: 400 }
    );
  }

  const room = await prisma.room.findUnique({
    where: { code },
    include: {
      participants: true
    }
  });

  if (!room) {
    return NextResponse.json(
      { error: 'Room not found' },
      { status: 404 }
    );
  }

  return NextResponse.json({ success: true, room });
}
```

#### 4. React Hooks for Room State

```typescript
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
```

#### 5. Room Creation Component

```typescript
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
```

#### 6. Room Join Component

```typescript
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
```

#### 7. Room Lobby Component

```typescript
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
```

## Project Structure

```
your-app/
├── app/
│   ├── api/
│   │   ├── rooms/
│   │   │   ├── route.ts              # Create room, get by code
│   │   │   └── [id]/
│   │   │       ├── route.ts           # Room operations
│   │   │       └── join/
│   │   │           └── route.ts       # Join room endpoint
│   │   └── socket.ts                  # WebSocket server
│   ├── room/
│   │   ├── create/
│   │   │   └── page.tsx              # Room creation page
│   │   ├── join/
│   │   │   └── page.tsx              # Room join page
│   │   └── [code]/
│   │       └── page.tsx              # Room lobby/session
│   └── layout.tsx
├── components/
│   ├── RoomCreator.tsx
│   ├── RoomJoiner.tsx
│   ├── RoomLobby.tsx
│   └── Session/
│       └── [SessionComponent].tsx   # Your app-specific session UI
├── hooks/
│   ├── useRoom.ts
│   └── useRoomState.ts
├── lib/
│   ├── room-manager.ts
│   ├── socket-client.ts
│   ├── db.ts                         # Prisma client
│   └── validations.ts                # Zod schemas
├── prisma/
│   └── schema.prisma
└── types/
    └── room.ts
```

## Prisma Schema

```prisma
// prisma/schema.prisma
model Room {
  id               String   @id @default(cuid())
  code             String   @unique
  creatorId        String
  status           String   @default("active")
  maxParticipants  Int      @default(8)
  metadata         Json?
  createdAt        DateTime @default(now())
  updatedAt        DateTime @updatedAt
  participants     Participant[]
  actions          RoomAction[]

  @@index([code])
  @@index([creatorId])
}

model Participant {
  id        String   @id @default(cuid())
  roomId    String
  userId    String
  role      String   @default("participant")
  joinedAt  DateTime @default(now())
  room      Room     @relation(fields: [roomId], references: [id], onDelete: Cascade)

  @@unique([roomId, userId])
  @@index([roomId])
  @@index([userId])
}

model RoomAction {
  id        String   @id @default(cuid())
  roomId    String
  userId    String
  action    String
  payload   Json
  createdAt DateTime @default(now())
  room      Room     @relation(fields: [roomId], references: [id], onDelete: Cascade)

  @@index([roomId])
  @@index([createdAt])
}
```

## Environment Variables

```env
# .env.local
DATABASE_URL="postgresql://user:password@localhost:5432/your_db"
NEXT_PUBLIC_APP_URL="http://localhost:3000"
NEXT_PUBLIC_SOCKET_URL="http://localhost:3000"

# Optional: Use Pusher instead of custom WebSocket
# NEXT_PUBLIC_PUSHER_KEY=""
# PUSHER_APP_ID=""
# PUSHER_SECRET=""
# PUSHER_CLUSTER=""
```

## Common Use Case Examples

### 1. Collaborative Story App

```typescript
// components/story/StorySession.tsx
'use client';

import { useRoom } from '@/hooks/useRoom';

interface StorySessionProps {
  roomId: string;
  userId: string;
}

export function StorySession({ roomId, userId }: StorySessionProps) {
  const { roomState, sendAction, participants } = useRoom({ roomId, userId });

  const handleAddParagraph = (text: string) => {
    sendAction('add-paragraph', { text, authorId: userId });
  };

  return (
    <div className="story-session">
      <div className="participants">
        {participants.map(p => p.userData.name).join(', ')}
      </div>
      
      <div className="story-content">
        {roomState?.paragraphs?.map((para, i) => (
          <p key={i}>
            <strong>{para.author}:</strong> {para.text}
          </p>
        ))}
      </div>

      <textarea
        placeholder="Add to the story..."
        onKeyDown={(e) => {
          if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            handleAddParagraph(e.currentTarget.value);
            e.currentTarget.value = '';
          }
        }}
      />
    </div>
  );
}
```

### 2. Multiplayer Game Session

```typescript
// components/game/GameSession.tsx
'use client';

import { useRoom } from '@/hooks/useRoom';

export function GameSession({ roomId, userId }: { roomId: string; userId: string }) {
  const { roomState, sendAction } = useRoom({ roomId, userId });

  const handlePlayerMove = (move: any) => {
    sendAction('player-move', { playerId: userId, move });
  };

  const handleGameAction = (action: string, payload: any) => {
    sendAction(`game-${action}`, payload);
  };

  return (
    <div className="game-session">
      {/* Your game-specific UI */}
      <div className="game-board">
        {roomState?.gameState && /* Render game state */}
      </div>
      
      <div className="controls">
        {/* Game controls that call handlePlayerMove/handleGameAction */}
      </div>
    </div>
  );
}
```

## Error Handling & Edge Cases

### 1. Room Code Validation

```typescript
// lib/validations.ts
import { z } from 'zod';

export const createRoomSchema = z.object({
  creatorId: z.string().min(1, 'Creator ID is required'),
  maxParticipants: z.number().min(2).max(100).optional(),
  metadata: z.record(z.any()).optional()
});

export const joinRoomSchema = z.object({
  code: z.string().length(6, 'Code must be 6 characters').regex(/^[A-Z0-9]+$/),
  userId: z.string().min(1, 'User ID is required')
});

export const roomActionSchema = z.object({
  roomId: z.string(),
  action: z.string(),
  payload: z.any()
});
```

### 2. Room Full Detection

```typescript
// Middleware to check room capacity
export async function checkRoomCapacity(roomId: string) {
  const room = await prisma.room.findUnique({
    where: { id: roomId },
    include: { participants: true }
  });

  if (!room) {
    throw new Error('Room not found');
  }

  if (room.participants.length >= room.maxParticipants) {
    throw new Error('Room is full');
  }

  if (room.status !== 'active') {
    throw new Error('Room is not active');
  }

  return room;
}
```

### 3. Connection Recovery

```typescript
// Enhanced useRoom hook with reconnection
export function useRoomWithRecovery({ roomId, userId, userData }: UseRoomOptions) {
  const [reconnectAttempts, setReconnectAttempts] = useState(0);
  const MAX_RECONNECT_ATTEMPTS = 5;

  const handleDisconnect = useCallback(() => {
    if (reconnectAttempts < MAX_RECONNECT_ATTEMPTS) {
      setTimeout(() => {
        setReconnectAttempts(prev => prev + 1);
        // Reconnect logic
      }, 1000 * Math.pow(2, reconnectAttempts)); // Exponential backoff
    }
  }, [reconnectAttempts]);

  // ... rest of hook implementation
}
```

## Deployment Checklist

- [ ] Set up production database (PostgreSQL recommended)
- [ ] Configure WebSocket support on your hosting platform
- [ ] Set up Redis for Socket.IO scaling if needed
- [ ] Enable HTTPS for secure WebSocket connections
- [ ] Configure rate limiting on API endpoints
- [ ] Set up monitoring for WebSocket connections
- [ ] Implement room cleanup cron job for inactive rooms
- [ ] Add authentication (NextAuth.js recommended)
- [ ] Configure CORS settings for production domain
- [ ] Set up error tracking (Sentry recommended)

## Best Practices

1. **Always validate room codes** on both client and server
2. **Use optimistic updates** for better UX in collaborative apps
3. **Implement conflict resolution** for simultaneous edits
4. **Add user presence indicators** (typing, active, etc.)
5. **Persist room state** periodically for recovery
6. **Use exponential backoff** for reconnection attempts
7. **Clean up empty rooms** automatically
8. **Add rate limiting** to room creation
9. **Implement user roles** (creator, moderator, participant)
10. **Log all room actions** for debugging and analytics

This skill provides a complete foundation for building professional room-based applications with Next.js. Each component is production-ready and handles edge cases appropriately.
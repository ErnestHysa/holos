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

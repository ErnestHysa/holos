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

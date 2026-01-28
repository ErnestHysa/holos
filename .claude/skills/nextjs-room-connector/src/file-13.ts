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

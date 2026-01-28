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

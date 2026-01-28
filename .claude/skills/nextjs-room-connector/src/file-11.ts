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

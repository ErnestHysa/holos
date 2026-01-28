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

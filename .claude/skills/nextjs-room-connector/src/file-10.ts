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

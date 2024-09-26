import React from 'react';
import BaseballEvent from './BaseballEvent';
import { Event } from '@/types/Event';

interface UserInterfaceProps {
  events: Event[] | null;
}

const UserInterface: React.FC<UserInterfaceProps> = ({ events }) => {
  if (!events || !Array.isArray(events)) {
    return <div>No events data available.</div>;
  }

  return (
    <div className="p-4">
      <h1 className="text-2xl font-bold mb-4">Baseball Events</h1>
      {events.length === 0 ? (
        <p>No events found.</p>
      ) : (
        <div className="space-y-4">
          {events.map((event) => (
            <BaseballEvent
              key={event.id}
              id={event.id}
              gameId={event.game_id}
              inning={event.inning}
              date={event.date}
              halfInning={event.half_inning}
              batterId={event.batter_id}
              pitcherId={event.pitcher_id}
              event={event.event}
            />
          ))}
        </div>
      )}
    </div>
  );
};

export default UserInterface;
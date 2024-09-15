import React from 'react';
import { Event } from '@/types/Event';
import SimpleEventTable from './SimpleEventTable';

interface UserInterfaceProps {
  events: Event[];
}

const UserInterface: React.FC<UserInterfaceProps> = ({ events }) => {
  return (
    <div>
      <h1>Baseball Events</h1>
      {events.length > 0 ? (
        <SimpleEventTable events={events} />
      ) : (
        <p>No events found.</p>
      )}
    </div>
  );
};

export default UserInterface;
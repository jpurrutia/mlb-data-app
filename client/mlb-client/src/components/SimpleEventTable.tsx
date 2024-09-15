import React from 'react';
import { Event } from '@/types/Event';
import EventTable from './EventTable';

interface UserInterfaceProps {
  events: Event[];
}

const UserInterface: React.FC<UserInterfaceProps> = ({ events }) => {
  return (
    <div className="p-4">
      <h1 className="text-2xl font-bold mb-4">Baseball Events</h1>
      {events.length > 0 ? (
        <EventTable events={events} />
      ) : (
        <p>No events found.</p>
      )}
    </div>
  );
};

export default UserInterface;
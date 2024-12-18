import React from 'react';
import { format } from 'date-fns';

interface EventProps {
    id: string;
    gameId: number;
    inning: number;
    date: string;
    halfInning: string;
    batterId: number;
    pitcherId: number;
    event: string;
}

const BaseballEvent: React.FC<EventProps> = ({
    id,
    gameId,
    inning,
    date,
    halfInning,
    batterId,
    pitcherId,
    event,
}) => {
    return (
        <div className="border rounded-lg p-4 mb-4 bg-white shadow">
            <h2 className="text-xl font-bold mb-2">Baseball Event</h2>
            <div className="grid grid-cols-2 gap-2 text-sm">
                <div className="font-semibold">Event ID:</div>
                <div>{id}</div>
                <div className="font-semibold">Game ID:</div>
                <div>{gameId}</div>
                <div className="font-semibold">Inning:</div>
                <div>{inning}</div>
                <div className="font-semibold">Date:</div>
                <div>{format(new Date(date), 'PPp')}</div>
                <div className="font-semibold">Half Inning:</div>
                <div>{halfInning}</div>
                <div className="font-semibold">Batter ID:</div>
                <div>{batterId}</div>
                <div className="font-semibold">Pitcher ID:</div>
                <div>{pitcherId}</div>
                <div className="font-semibold">Event:</div>
                <div>{event}</div>
            </div>
        </div>
    );
};

export default BaseballEvent;
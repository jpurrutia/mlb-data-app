import { GetServerSideProps } from 'next';
import { Event } from '@/types/Event';

interface HomeProps {
  events: Event[];
  error?: string;
}

export default function Home({ events, error }: HomeProps) {
  if (error) {
    return <div style={{ color: 'red' }}>Error: {error}</div>;
  }

  return (
    <div style={{ padding: '20px' }}>
      <h1 style={{ textAlign: 'center' }}>Baseball Events Tracker</h1>
      <table style={{ width: '100%', borderCollapse: 'collapse', marginTop: '20px' }}>
        <thead>
          <tr style={{ backgroundColor: '#f2f2f2' }}>
            <th style={{ border: '1px solid #ddd', padding: '8px' }}>Inning</th>
            <th style={{ border: '1px solid #ddd', padding: '8px' }}>Half</th>
            <th style={{ border: '1px solid #ddd', padding: '8px' }}>Batter ID</th>
            <th style={{ border: '1px solid #ddd', padding: '8px' }}>Pitcher ID</th>
            <th style={{ border: '1px solid #ddd', padding: '8px' }}>Event</th>
          </tr>
        </thead>
        <tbody>
          {events.map((event, index) => (
            <tr key={index} style={{ backgroundColor: index % 2 === 0 ? '#f8f8f8' : 'white' }}>
              <td style={{ border: '1px solid #ddd', padding: '8px' }}>{event.inning}</td>
              <td style={{ border: '1px solid #ddd', padding: '8px' }}>{event.half_inning}</td>
              <td style={{ border: '1px solid #ddd', padding: '8px' }}>{event.batterId}</td>
              <td style={{ border: '1px solid #ddd', padding: '8px' }}>{event.pitcherId}</td>
              <td style={{ border: '1px solid #ddd', padding: '8px' }}>{event.event}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

export const getServerSideProps: GetServerSideProps = async () => {
  try {
    const res = await fetch('http://localhost:8080/events');
    if (!res.ok) {
      throw new Error(`API responded with status ${res.status}`);
    }
    const data = await res.json();

    if (!data || !data.data || !Array.isArray(data.data)) {
      throw new Error('Invalid data format received from API');
    }

    return { props: { events: data.data } };
  } catch (error) {
    console.error('Error fetching events:', error);
    return { props: { events: [], error: error.message } };
  }
};
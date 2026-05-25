import React, { useState } from 'react';
import { ConnectionState } from '../App';

interface ConnectionPanelProps {
  state: ConnectionState;
  onManualConnect: (host: string, port: number) => void;
}

export function ConnectionPanel({ state, onManualConnect }: ConnectionPanelProps) {
  const [host, setHost] = useState('');
  const [port, setPort] = useState('5288');
  const [showManual, setShowManual] = useState(false);

  const handleConnect = (e: React.FormEvent) => {
    e.preventDefault();
    const portNum = parseInt(port, 10);
    if (host && !isNaN(portNum)) {
      onManualConnect(host, portNum);
    }
  };

  return (
    <div className="connection-panel">
      <div className="connection-status">
        <div className={`status-indicator ${state}`} />
        <span className="status-text">
          {state === 'disconnected' && 'Disconnected'}
          {state === 'connecting' && 'Connecting...'}
          {state === 'connected' && 'Connected'}
        </span>
      </div>

      {state === 'disconnected' && (
        <div className="connection-actions">
          <p className="connection-hint">
            Select a discovered device below, or enter an IP address manually.
          </p>

          <button
            className="btn btn-link"
            onClick={() => setShowManual(!showManual)}
          >
            {showManual ? 'Hide Manual Entry' : 'Manual Connection'}
          </button>

          {showManual && (
            <form className="manual-connect-form" onSubmit={handleConnect}>
              <div className="form-row">
                <input
                  type="text"
                  className="input"
                  placeholder="IP Address (e.g. 192.168.1.5)"
                  value={host}
                  onChange={(e) => setHost(e.target.value)}
                />
                <input
                  type="number"
                  className="input input-port"
                  placeholder="Port"
                  value={port}
                  onChange={(e) => setPort(e.target.value)}
                  min={1024}
                  max={65535}
                />
              </div>
              <button type="submit" className="btn btn-primary btn-full">
                Connect
              </button>
            </form>
          )}
        </div>
      )}

      {state === 'connecting' && (
        <div className="connecting-spinner">
          <div className="spinner" />
          <p>Establishing connection...</p>
        </div>
      )}
    </div>
  );
}

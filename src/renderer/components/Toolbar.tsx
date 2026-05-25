import React from 'react';
import { ConnectionState } from '../App';

interface ToolbarProps {
  connectionState: ConnectionState;
  deviceInfo: { name: string; width: number; height: number } | null;
  quality: number;
  fps: number;
  onQualityChange: (q: number) => void;
  onFpsChange: (fps: number) => void;
  onDisconnect: () => void;
}

const qualityLabels = ['Low', 'Medium', 'High', 'Ultra'];

export function Toolbar({
  connectionState,
  deviceInfo,
  quality,
  fps,
  onQualityChange,
  onFpsChange,
  onDisconnect,
}: ToolbarProps) {
  return (
    <div className="toolbar">
      <div className="toolbar-left">
        <span className="toolbar-brand">Remote Control</span>
        {deviceInfo && (
          <span className="toolbar-device">{deviceInfo.name}</span>
        )}
      </div>

      <div className="toolbar-center">
        <div className={`toolbar-status ${connectionState}`}>
          <span className="status-dot" />
          <span>
            {connectionState === 'disconnected' && 'Disconnected'}
            {connectionState === 'connecting' && 'Connecting...'}
            {connectionState === 'connected' && 'Connected'}
          </span>
        </div>
      </div>

      <div className="toolbar-right">
        {connectionState === 'connected' && (
          <>
            <div className="toolbar-control">
              <label>Quality:</label>
              <select
                value={quality}
                onChange={(e) => onQualityChange(parseInt(e.target.value))}
              >
                {qualityLabels.map((label, idx) => (
                  <option key={idx} value={idx}>{label}</option>
                ))}
              </select>
            </div>
            <div className="toolbar-control">
              <label>FPS:</label>
              <select
                value={fps}
                onChange={(e) => onFpsChange(parseInt(e.target.value))}
              >
                {[15, 20, 30, 60].map((v) => (
                  <option key={v} value={v}>{v}</option>
                ))}
              </select>
            </div>
            <button className="btn btn-danger btn-sm" onClick={onDisconnect}>
              Disconnect
            </button>
          </>
        )}
      </div>
    </div>
  );
}

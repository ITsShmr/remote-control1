import React from 'react';

interface DeviceListProps {
  devices: Array<{ name: string; address: string; port: number }>;
  onConnect: (device: any) => void;
  onManualConnect: (host: string, port: number) => void;
}

export function DeviceList({ devices, onConnect, onManualConnect }: DeviceListProps) {
  if (devices.length === 0) {
    return (
      <div className="device-list-empty">
        <div className="empty-icon">📱</div>
        <p className="empty-title">No devices found</p>
        <p className="empty-detail">
          Make sure the Remote Control app is running on your iPhone
        </p>
      </div>
    );
  }

  return (
    <div className="device-list">
      <h3 className="device-list-title">Discovered Devices</h3>
      {devices.map((device, idx) => (
        <div key={`${device.address}-${idx}`} className="device-item">
          <div className="device-icon">
            <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <rect x="5" y="2" width="14" height="20" rx="2" ry="2" />
              <line x1="12" y1="18" x2="12.01" y2="18" />
            </svg>
          </div>
          <div className="device-info">
            <span className="device-name">{device.name}</span>
            <span className="device-address">{device.address}:{device.port}</span>
          </div>
          <button
            className="btn btn-primary btn-sm"
            onClick={() => onConnect(device)}
          >
            Connect
          </button>
        </div>
      ))}
    </div>
  );
}

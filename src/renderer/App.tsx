import React, { useState, useEffect, useCallback, useRef } from 'react';
import { StreamViewer } from './components/StreamViewer';
import { ConnectionPanel } from './components/ConnectionPanel';
import { DeviceList } from './components/DeviceList';
import { Toolbar } from './components/Toolbar';
import './styles/app.css';

declare global {
  interface Window {
    remoteControlAPI: {
      connect: (device: any) => Promise<void>;
      connectToHost: (host: string, port: number) => Promise<void>;
      disconnect: () => Promise<void>;
      startDiscovery: () => Promise<void>;
      stopDiscovery: () => Promise<void>;
      sendMouseMove: (x: number, y: number) => void;
      sendMouseDown: (x: number, y: number, button: number) => void;
      sendMouseUp: () => void;
      sendScroll: (dx: number, dy: number) => void;
      sendKeyDown: (keyCode: number) => void;
      sendKeyUp: (keyCode: number) => void;
      setDisplaySize: (w: number, h: number) => void;
      sendConfig: (quality: number, fps: number) => Promise<void>;
      onConnectionState: (cb: (state: string) => void) => void;
      onFrame: (cb: (data: string) => void) => void;
      onDeviceInfo: (cb: (info: any) => void) => void;
      onDeviceFound: (cb: (device: any) => void) => void;
      onDeviceLost: (cb: (device: any) => void) => void;
      onError: (cb: (msg: string) => void) => void;
    };
  }
}

export type ConnectionState = 'disconnected' | 'connecting' | 'connected';

export function App() {
  const [connectionState, setConnectionState] = useState<ConnectionState>('disconnected');
  const [devices, setDevices] = useState<any[]>([]);
  const [deviceInfo, setDeviceInfo] = useState<{ name: string; width: number; height: number } | null>(null);
  const [streamQuality, setStreamQuality] = useState(2);
  const [streamFps, setStreamFps] = useState(30);
  const viewerRef = useRef<{ handleFrame: (data: string) => void }>(null);

  useEffect(() => {
    window.remoteControlAPI.onConnectionState((state) => {
      setConnectionState(state as ConnectionState);
    });

    window.remoteControlAPI.onFrame((data) => {
      viewerRef.current?.handleFrame(data);
    });

    window.remoteControlAPI.onDeviceInfo((info) => {
      setDeviceInfo(info);
    });

    window.remoteControlAPI.onDeviceFound((device) => {
      setDevices((prev) => {
        if (prev.find((d) => d.address === device.address)) return prev;
        return [...prev, device];
      });
    });

    window.remoteControlAPI.onDeviceLost((device) => {
      setDevices((prev) => prev.filter((d) => d.address !== device.address));
    });

    window.remoteControlAPI.onError((msg) => {
      console.error('Connection error:', msg);
    });

    window.remoteControlAPI.startDiscovery();

    const handleKeyDown = (e: KeyboardEvent) => {
      if (connectionState === 'connected') {
        window.remoteControlAPI.sendKeyDown(e.keyCode);
      }
    };
    const handleKeyUp = (e: KeyboardEvent) => {
      if (connectionState === 'connected') {
        window.remoteControlAPI.sendKeyUp(e.keyCode);
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    window.addEventListener('keyup', handleKeyUp);

    return () => {
      window.remoteControlAPI.stopDiscovery();
      window.removeEventListener('keydown', handleKeyDown);
      window.removeEventListener('keyup', handleKeyUp);
    };
  }, [connectionState]);

  const handleConnect = useCallback((device: any) => {
    window.remoteControlAPI.connect(device);
  }, []);

  const handleManualConnect = useCallback((host: string, port: number) => {
    window.remoteControlAPI.connectToHost(host, port);
  }, []);

  const handleDisconnect = useCallback(() => {
    window.remoteControlAPI.disconnect();
  }, []);

  const handleQualityChange = useCallback((quality: number) => {
    setStreamQuality(quality);
    window.remoteControlAPI.sendConfig(quality, streamFps);
  }, [streamFps]);

  const handleFpsChange = useCallback((fps: number) => {
    setStreamFps(fps);
    window.remoteControlAPI.sendConfig(streamQuality, fps);
  }, [streamQuality]);

  return (
    <div className="app-container">
      <Toolbar
        connectionState={connectionState}
        deviceInfo={deviceInfo}
        quality={streamQuality}
        fps={streamFps}
        onQualityChange={handleQualityChange}
        onFpsChange={handleFpsChange}
        onDisconnect={handleDisconnect}
      />
      <div className="main-content">
        {connectionState === 'connected' && deviceInfo ? (
          <StreamViewer ref={viewerRef} deviceInfo={deviceInfo} />
        ) : (
          <div className="connect-panel-wrapper">
            <ConnectionPanel
              state={connectionState}
              onManualConnect={handleManualConnect}
            />
            {connectionState === 'disconnected' && (
              <DeviceList
                devices={devices}
                onConnect={handleConnect}
                onManualConnect={handleManualConnect}
              />
            )}
          </div>
        )}
      </div>
    </div>
  );
}

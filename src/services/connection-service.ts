import * as net from 'net';
import {
  PacketType,
  serializePacket,
  parsePacket,
  DeviceInfo,
} from '../types/protocol';

export type ConnectionState = 'disconnected' | 'connecting' | 'connected';

export interface ConnectionCallbacks {
  onStateChange: (state: ConnectionState) => void;
  onFrame: (jpegData: Buffer) => void;
  onDeviceInfo: (info: { name: string; width: number; height: number }) => void;
  onError: (error: Error) => void;
}

export class ConnectionService {
  private socket: net.Socket | null = null;
  private state: ConnectionState = 'disconnected';
  private readBuffer = Buffer.alloc(0);
  private callbacks: ConnectionCallbacks;
  private reconnectTimer: NodeJS.Timeout | null = null;
  private host: string = '';
  private port: number = 5288;

  constructor(callbacks: ConnectionCallbacks) {
    this.callbacks = callbacks;
  }

  connect(device: DeviceInfo): void {
    this.host = device.address;
    this.port = device.port;
    this.initiateConnection();
  }

  connectToHost(host: string, port: number = 5288): void {
    this.host = host;
    this.port = port;
    this.initiateConnection();
  }

  private initiateConnection(): void {
    this.setState('connecting');
    this.socket = new net.Socket();

    this.socket.connect(this.port, this.host, () => {
      this.setState('connected');
      this.sendHeartbeat();
    });

    this.socket.on('data', (data: Buffer) => {
      this.readBuffer = Buffer.concat([this.readBuffer, data]);
      this.processPackets();
    });

    this.socket.on('close', () => {
      this.setState('disconnected');
      this.socket = null;
    });

    this.socket.on('error', (err) => {
      this.callbacks.onError(err);
      this.setState('disconnected');
    });
  }

  disconnect(): void {
    if (this.reconnectTimer) {
      clearTimeout(this.reconnectTimer);
      this.reconnectTimer = null;
    }
    if (this.socket) {
      const packet = serializePacket(PacketType.DISCONNECT, Buffer.alloc(0));
      this.socket.write(packet);
      this.socket.destroy();
      this.socket = null;
    }
    this.setState('disconnected');
  }

  sendMouseMove(x: number, y: number): void {
    const payload = Buffer.alloc(8);
    payload.writeFloatBE(x, 0);
    payload.writeFloatBE(y, 4);
    this.sendRaw(PacketType.MOUSE_MOVE, payload);
  }

  sendMouseDown(x: number, y: number, button: number = 0): void {
    const payload = Buffer.alloc(9);
    payload.writeFloatBE(x, 0);
    payload.writeFloatBE(y, 4);
    payload.writeUInt8(button, 8);
    this.sendRaw(PacketType.MOUSE_DOWN, payload);
  }

  sendMouseUp(): void {
    this.sendRaw(PacketType.MOUSE_UP, Buffer.alloc(0));
  }

  sendScroll(deltaX: number, deltaY: number): void {
    const payload = Buffer.alloc(8);
    payload.writeFloatBE(deltaX, 0);
    payload.writeFloatBE(deltaY, 4);
    this.sendRaw(PacketType.MOUSE_SCROLL, payload);
  }

  sendKeyboard(keyCode: number, keyDown: boolean): void {
    const payload = Buffer.alloc(3);
    payload.writeUInt16BE(keyCode, 0);
    payload.writeUInt8(keyDown ? 1 : 0, 2);
    this.sendRaw(PacketType.KEYBOARD_EVENT, payload);
  }

  sendFrameConfig(quality: number, maxFps: number): void {
    const payload = Buffer.alloc(2);
    payload.writeUInt8(quality, 0);
    payload.writeUInt8(maxFps, 1);
    this.sendRaw(PacketType.FRAME_CONFIG, payload);
  }

  private sendRaw(type: PacketType, payload: Buffer): void {
    if (!this.socket || this.state !== 'connected') return;
    const packet = serializePacket(type, payload);
    this.socket.write(packet);
  }

  private sendHeartbeat(): void {
    const packet = serializePacket(PacketType.HEARTBEAT, Buffer.alloc(0));
    this.socket?.write(packet);
  }

  private processPackets(): void {
    let result: ReturnType<typeof parsePacket>;
    while ((result = parsePacket(this.readBuffer)) !== null) {
      const { packet, remaining } = result;
      this.readBuffer = Buffer.from(remaining);
      this.handlePacket(packet.type, packet.payload);
    }
  }

  private handlePacket(type: PacketType, payload: Buffer): void {
    switch (type) {
      case PacketType.FRAME_DATA:
        this.callbacks.onFrame(payload);
        break;
      case PacketType.DEVICE_INFO:
        this.handleDeviceInfo(payload);
        break;
      case PacketType.HEARTBEAT:
        this.sendRaw(PacketType.HEARTBEAT_ACK, Buffer.alloc(0));
        break;
      case PacketType.HEARTBEAT_ACK:
        break;
      case PacketType.DISCONNECT:
        this.disconnect();
        break;
    }
  }

  private handleDeviceInfo(payload: Buffer): void {
    try {
      const info = JSON.parse(payload.toString('utf-8'));
      this.callbacks.onDeviceInfo({
        name: info.deviceName,
        width: info.screenWidth,
        height: info.screenHeight,
      });
    } catch {
      console.error('Failed to parse device info');
    }
  }

  private setState(state: ConnectionState): void {
    this.state = state;
    this.callbacks.onStateChange(state);
  }

  getState(): ConnectionState {
    return this.state;
  }
}

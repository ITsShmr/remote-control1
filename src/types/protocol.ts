export const PROTOCOL_MAGIC = 0x524D544C;

export enum PacketType {
  HANDSHAKE_REQUEST = 0x0001,
  HANDSHAKE_RESPONSE = 0x0002,
  HEARTBEAT = 0x0003,
  HEARTBEAT_ACK = 0x0004,
  FRAME_DATA = 0x0101,
  FRAME_CONFIG = 0x0102,
  MOUSE_MOVE = 0x0201,
  MOUSE_DOWN = 0x0202,
  MOUSE_UP = 0x0203,
  MOUSE_SCROLL = 0x0204,
  KEYBOARD_EVENT = 0x0205,
  CONNECTION_QUALITY = 0x0301,
  DEVICE_INFO = 0x0302,
  DISCONNECT = 0xFFFF,
}

export enum ConnectionQuality {
  LOW = 0,
  MEDIUM = 1,
  HIGH = 2,
  ULTRA = 3,
}

export interface HandshakePayload {
  protocolVersion: number;
  deviceName: string;
  screenWidth: number;
  screenHeight: number;
  capabilities: string[];
}

export interface FrameConfig {
  quality: ConnectionQuality;
  maxFps: number;
  scaleFactor: number;
}

export interface MouseMovePayload {
  x: number;
  y: number;
}

export interface MouseClickPayload {
  x: number;
  y: number;
  button: number;
}

export interface MouseScrollPayload {
  deltaX: number;
  deltaY: number;
}

export interface KeyboardPayload {
  keyCode: number;
  keyDown: boolean;
  characters: string | null;
}

export interface PacketHeader {
  magic: number;
  length: number;
  type: PacketType;
}

const HEADER_SIZE = 12;

export function serializePacket(type: PacketType, payload: Buffer): Buffer {
  const header = Buffer.alloc(HEADER_SIZE);
  header.writeUInt32BE(PROTOCOL_MAGIC, 0);
  header.writeUInt32BE(payload.length, 4);
  header.writeUInt32BE(type, 8);
  return Buffer.concat([header, payload]);
}

export function parsePacket(buffer: Buffer): { packet: { type: PacketType; payload: Buffer }; remaining: Buffer } | null {
  if (buffer.length < HEADER_SIZE) return null;
  const magic = buffer.readUInt32BE(0);
  if (magic !== PROTOCOL_MAGIC) return null;
  const length = buffer.readUInt32BE(4);
  const typeRaw = buffer.readUInt32BE(8);
  const type = typeRaw as PacketType;
  const totalSize = HEADER_SIZE + length;
  if (buffer.length < totalSize) return null;
  const payload = buffer.subarray(HEADER_SIZE, totalSize);
  const remaining = buffer.subarray(totalSize);
  return { packet: { type, payload }, remaining };
}

export interface DeviceInfo {
  name: string;
  address: string;
  port: number;
  model?: string;
}

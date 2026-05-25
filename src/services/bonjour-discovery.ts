import * as dns from 'dns';
import * as net from 'net';
import { DeviceInfo } from '../types/protocol';

export interface DiscoveryCallbacks {
  onDeviceFound: (device: DeviceInfo) => void;
  onDeviceLost: (device: DeviceInfo) => void;
  onError: (error: Error) => void;
}

export class BonjourDiscovery {
  private callbacks: DiscoveryCallbacks;
  private discovered = new Map<string, DeviceInfo>();
  private interval: NodeJS.Timeout | null = null;
  private running = false;

  constructor(callbacks: DiscoveryCallbacks) {
    this.callbacks = callbacks;
  }

  start(): void {
    if (this.running) return;
    this.running = true;
    this.discover();
    this.interval = setInterval(() => this.discover(), 5000);
  }

  stop(): void {
    this.running = false;
    if (this.interval) {
      clearInterval(this.interval);
      this.interval = null;
    }
  }

  private async discover(): Promise<void> {
    try {
      const services = await this.browseService();
      const currentKeys = new Set<string>();

      for (const service of services) {
        const key = `${service.address}:${service.port}`;
        currentKeys.add(key);
        if (!this.discovered.has(key)) {
          const device: DeviceInfo = {
            name: service.name,
            address: service.address,
            port: service.port,
          };
          this.discovered.set(key, device);
          this.callbacks.onDeviceFound(device);
        }
      }

      for (const [key, device] of this.discovered) {
        if (!currentKeys.has(key)) {
          this.discovered.delete(key);
          this.callbacks.onDeviceLost(device);
        }
      }
    } catch {
      // Bonjour not available, fall back to manual connection
    }
  }

  private browseService(): Promise<Array<{ name: string; address: string; port: number }>> {
    return new Promise((resolve, reject) => {
      dns.resolveSrv('_remoteios._tcp.local', (err, addresses) => {
        if (err) {
          reject(err);
          return;
        }
        const results = addresses.map((addr) => ({
          name: addr.name,
          address: addr.name.replace('.local', ''),
          port: addr.port,
        }));
        resolve(results);
      });
    });
  }

  async resolveHostname(hostname: string): Promise<string> {
    return new Promise((resolve, reject) => {
      dns.lookup(hostname, { family: 4 }, (err, address) => {
        if (err) reject(err);
        else resolve(address);
      });
    });
  }
}

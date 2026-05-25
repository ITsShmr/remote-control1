import { contextBridge, ipcRenderer } from 'electron';

contextBridge.exposeInMainWorld('remoteControlAPI', {
  connect: (device: any) => ipcRenderer.invoke('connection:connect', device),
  connectToHost: (host: string, port: number) =>
    ipcRenderer.invoke('connection:connect-host', host, port),
  disconnect: () => ipcRenderer.invoke('connection:disconnect'),
  startDiscovery: () => ipcRenderer.invoke('discovery:start'),
  stopDiscovery: () => ipcRenderer.invoke('discovery:stop'),

  sendMouseMove: (x: number, y: number) =>
    ipcRenderer.send('input:mouse-move', x, y),
  sendMouseDown: (x: number, y: number, button: number) =>
    ipcRenderer.send('input:mouse-down', x, y, button),
  sendMouseUp: () => ipcRenderer.send('input:mouse-up'),
  sendScroll: (dx: number, dy: number) =>
    ipcRenderer.send('input:scroll', dx, dy),
  sendKeyDown: (keyCode: number) => ipcRenderer.send('input:key-down', keyCode),
  sendKeyUp: (keyCode: number) => ipcRenderer.send('input:key-up', keyCode),

  setDisplaySize: (w: number, h: number) =>
    ipcRenderer.send('stream:set-display-size', w, h),
  sendConfig: (quality: number, fps: number) =>
    ipcRenderer.invoke('connection:send-config', quality, fps),

  onConnectionState: (cb: (state: string) => void) =>
    ipcRenderer.on('connection:state', (_, state) => cb(state)),
  onFrame: (cb: (base64: string) => void) =>
    ipcRenderer.on('stream:frame', (_, data) => cb(data)),
  onDeviceInfo: (cb: (info: any) => void) =>
    ipcRenderer.on('connection:device-info', (info) => cb(info)),
  onDeviceFound: (cb: (device: any) => void) =>
    ipcRenderer.on('discovery:found', (_, device) => cb(device)),
  onDeviceLost: (cb: (device: any) => void) =>
    ipcRenderer.on('discovery:lost', (_, device) => cb(device)),
  onError: (cb: (msg: string) => void) =>
    ipcRenderer.on('connection:error', (_, msg) => cb(msg)),
});

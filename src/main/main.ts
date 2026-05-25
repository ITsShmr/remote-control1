import { app, BrowserWindow, ipcMain } from 'electron';
import * as path from 'path';
import { ConnectionService } from '../services/connection-service';
import { InputService } from '../services/input-service';
import { BonjourDiscovery } from '../services/bonjour-discovery';

let mainWindow: BrowserWindow | null = null;
let connection: ConnectionService | null = null;
let inputService: InputService | null = null;
let discovery: BonjourDiscovery | null = null;

function createWindow(): void {
  mainWindow = new BrowserWindow({
    width: 1024,
    height: 768,
    minWidth: 600,
    minHeight: 400,
    title: 'Remote Control Desktop',
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
    },
    backgroundColor: '#1a1a2e',
    show: false,
  });

  mainWindow.loadFile(path.join(__dirname, '../renderer/index.html'));

  mainWindow.once('ready-to-show', () => {
    mainWindow?.show();
  });

  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}

function initServices(): void {
  connection = new ConnectionService({
    onStateChange: (state) => {
      mainWindow?.webContents.send('connection:state', state);
    },
    onFrame: (jpegData) => {
      mainWindow?.webContents.send('stream:frame', jpegData.toString('base64'));
    },
    onDeviceInfo: (info) => {
      inputService?.setScreenSize(info.width, info.height);
      mainWindow?.webContents.send('connection:device-info', info);
    },
    onError: (error) => {
      mainWindow?.webContents.send('connection:error', error.message);
    },
  });

  inputService = new InputService(connection);

  discovery = new BonjourDiscovery({
    onDeviceFound: (device) => {
      mainWindow?.webContents.send('discovery:found', device);
    },
    onDeviceLost: (device) => {
      mainWindow?.webContents.send('discovery:lost', device);
    },
    onError: (error) => {
      console.error('Discovery error:', error.message);
    },
  });
}

function registerIPC(): void {
  ipcMain.handle('connection:connect', (_, device) => {
    connection?.connect(device);
  });

  ipcMain.handle('connection:connect-host', (_, host: string, port: number) => {
    connection?.connectToHost(host, port);
  });

  ipcMain.handle('connection:disconnect', () => {
    connection?.disconnect();
  });

  ipcMain.handle('discovery:start', () => {
    discovery?.start();
  });

  ipcMain.handle('discovery:stop', () => {
    discovery?.stop();
  });

  ipcMain.on('input:mouse-move', (_, x: number, y: number) => {
    inputService?.handleMouseMove(x, y);
  });

  ipcMain.on('input:mouse-down', (_, x: number, y: number, button: number) => {
    inputService?.handleMouseDown(x, y, button);
  });

  ipcMain.on('input:mouse-up', () => {
    inputService?.handleMouseUp();
  });

  ipcMain.on('input:scroll', (_, dx: number, dy: number) => {
    inputService?.handleWheel(dx, dy);
  });

  ipcMain.on('input:key-down', (_, keyCode: number) => {
    inputService?.handleKeyDown(keyCode);
  });

  ipcMain.on('input:key-up', (_, keyCode: number) => {
    inputService?.handleKeyUp(keyCode);
  });

  ipcMain.on('stream:set-display-size', (_, w: number, h: number) => {
    inputService?.setDisplaySize(w, h);
  });

  ipcMain.handle('connection:send-config', (_, quality: number, fps: number) => {
    connection?.sendFrameConfig(quality, fps);
  });
}

app.whenReady().then(() => {
  createWindow();
  initServices();
  registerIPC();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

app.on('window-all-closed', () => {
  connection?.disconnect();
  discovery?.stop();
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

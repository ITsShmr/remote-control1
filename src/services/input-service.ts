import { ConnectionService } from './connection-service';

export class InputService {
  private conn: ConnectionService;
  private screenWidth = 0;
  private screenHeight = 0;
  private displayWidth = 0;
  private displayHeight = 0;
  private isMouseDown = false;

  constructor(connection: ConnectionService) {
    this.conn = connection;
  }

  setScreenSize(width: number, height: number): void {
    this.screenWidth = width;
    this.screenHeight = height;
  }

  setDisplaySize(width: number, height: number): void {
    this.displayWidth = width;
    this.displayHeight = height;
  }

  handleMouseMove(clientX: number, clientY: number): void {
    const { x, y } = this.scaleCoordinates(clientX, clientY);
    this.conn.sendMouseMove(x, y);
  }

  handleMouseDown(clientX: number, clientY: number, button: number = 0): void {
    this.isMouseDown = true;
    const { x, y } = this.scaleCoordinates(clientX, clientY);
    this.conn.sendMouseDown(x, y, button);
  }

  handleMouseUp(): void {
    this.isMouseDown = false;
    this.conn.sendMouseUp();
  }

  handleWheel(deltaX: number, deltaY: number): void {
    this.conn.sendScroll(deltaX, deltaY);
  }

  handleKeyDown(keyCode: number): void {
    this.conn.sendKeyboard(keyCode, true);
  }

  handleKeyUp(keyCode: number): void {
    this.conn.sendKeyboard(keyCode, false);
  }

  private scaleCoordinates(clientX: number, clientY: number): { x: number; y: number } {
    if (this.screenWidth === 0 || this.screenHeight === 0 ||
        this.displayWidth === 0 || this.displayHeight === 0) {
      return { x: clientX, y: clientY };
    }
    const scaleX = this.screenWidth / this.displayWidth;
    const scaleY = this.screenHeight / this.displayHeight;
    return {
      x: Math.round(clientX * scaleX),
      y: Math.round(clientY * scaleY),
    };
  }
}

import React, { useRef, useEffect, useImperativeHandle, forwardRef, useState } from 'react';

interface StreamViewerProps {
  deviceInfo: { name: string; width: number; height: number };
}

export const StreamViewer = forwardRef<{ handleFrame: (data: string) => void }, StreamViewerProps>(
  ({ deviceInfo }, ref) => {
    const canvasRef = useRef<HTMLCanvasElement>(null);
    const imageRef = useRef<HTMLImageElement | null>(null);
    const containerRef = useRef<HTMLDivElement>(null);
    const [isDragging, setIsDragging] = useState(false);
    const fpsRef = useRef({ frames: 0, lastTime: Date.now(), fps: 0 });
    const [fps, setFps] = useState(0);

    useImperativeHandle(ref, () => ({
      handleFrame: (base64: string) => {
        const img = new Image();
        img.onload = () => {
          const canvas = canvasRef.current;
          if (!canvas) return;
          const ctx = canvas.getContext('2d');
          if (!ctx) return;

          const container = containerRef.current;
          if (container) {
            const containerW = container.clientWidth;
            const containerH = container.clientHeight;
            const scale = Math.min(containerW / img.width, containerH / img.height, 1);
            canvas.width = img.width * scale;
            canvas.height = img.height * scale;
            ctx.imageSmoothingEnabled = true;
            ctx.imageSmoothingQuality = 'high';
            ctx.drawImage(img, 0, 0, canvas.width, canvas.height);

            window.remoteControlAPI.setDisplaySize(canvas.width, canvas.height);
          }

          const now = Date.now();
          fpsRef.current.frames++;
          if (now - fpsRef.current.lastTime >= 1000) {
            fpsRef.current.fps = fpsRef.current.frames;
            fpsRef.current.frames = 0;
            fpsRef.current.lastTime = now;
            setFps(fpsRef.current.fps);
          }
        };
        img.src = `data:image/jpeg;base64,${base64}`;
      },
    }));

    const getMousePos = (e: React.MouseEvent<HTMLCanvasElement>) => {
      const canvas = canvasRef.current;
      if (!canvas) return { x: 0, y: 0 };
      const rect = canvas.getBoundingClientRect();
      return {
        x: e.clientX - rect.left,
        y: e.clientY - rect.top,
      };
    };

    const handleMouseMove = (e: React.MouseEvent<HTMLCanvasElement>) => {
      const pos = getMousePos(e);
      window.remoteControlAPI.sendMouseMove(pos.x, pos.y);
    };

    const handleMouseDown = (e: React.MouseEvent<HTMLCanvasElement>) => {
      setIsDragging(true);
      const pos = getMousePos(e);
      window.remoteControlAPI.sendMouseDown(pos.x, pos.y, e.button);
    };

    const handleMouseUp = () => {
      setIsDragging(false);
      window.remoteControlAPI.sendMouseUp();
    };

    const handleWheel = (e: React.WheelEvent<HTMLCanvasElement>) => {
      window.remoteControlAPI.sendScroll(e.deltaX, e.deltaY);
    };

    useEffect(() => {
      const canvas = canvasRef.current;
      if (!canvas) return;
      const preventCtxMenu = (e: MouseEvent) => e.preventDefault();
      canvas.addEventListener('contextmenu', preventCtxMenu);
      return () => canvas.removeEventListener('contextmenu', preventCtxMenu);
    }, []);

    return (
      <div className="stream-container" ref={containerRef}>
        <div className="stream-info-bar">
          <span className="stream-device-name">{deviceInfo.name}</span>
          <span className="stream-resolution">{deviceInfo.width}×{deviceInfo.height}</span>
          <span className="stream-fps">{fps} fps</span>
        </div>
        <canvas
          ref={canvasRef}
          className="stream-canvas"
          onMouseMove={handleMouseMove}
          onMouseDown={handleMouseDown}
          onMouseUp={handleMouseUp}
          onMouseLeave={() => isDragging && window.remoteControlAPI.sendMouseUp()}
          onWheel={handleWheel}
        />
      </div>
    );
  }
);

StreamViewer.displayName = 'StreamViewer';

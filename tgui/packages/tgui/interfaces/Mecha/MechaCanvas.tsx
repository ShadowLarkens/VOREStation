import { round } from 'common/math';
import { useEffect, useRef } from 'react';
import { useBackend } from 'tgui/backend';

import { Data } from '.';

const loadImage = async (src: string): Promise<HTMLImageElement> => {
  return new Promise((resolve, reject) => {
    let image = new Image(32, 32);
    image.onload = () => {
      resolve(image);
    };
    image.onerror = () => {
      reject();
    };
    image.src = src;
  });
};

const HIGHLIGHT_COLOR = '#223d22';

const drawBox = (
  ctx: CanvasRenderingContext2D,
  title: string,
  content: string,
  content_color: string,
) => {
  ctx.fillStyle = HIGHLIGHT_COLOR;
  ctx.fillRect(0, 0, 100, 40);
  ctx.fillStyle = '#fff';
  ctx.font = '16px monospace';
  ctx.fillText(title, 10, 15);
  ctx.fillStyle = content_color;
  ctx.font = '20px monospace';
  ctx.fillText(content, 10, 35);
};

export const MechaCanvas = (props) => {
  const { data } = useBackend<Data>();
  const {
    health,
    health_max,
    armor,
    armor_max,
    hull,
    hull_max,
    cell_charge,
    cell_charge_max,
  } = data;
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    if (!canvasRef.current) {
      return;
    }

    const canvas: HTMLCanvasElement = canvasRef.current;
    const ctx = canvas.getContext('2d');
    if (!ctx) {
      return;
    }

    const draw = async () => {
      try {
        ctx.reset();
        // Draw health
        ctx.translate(20, 10);
        drawBox(ctx, 'Chassis', health + '/' + health_max, '#fff');
        // Health line
        ctx.strokeStyle = HIGHLIGHT_COLOR;
        ctx.lineWidth = 10;
        ctx.beginPath();
        ctx.moveTo(90, 20);
        ctx.lineTo(110, 20);
        ctx.lineTo(140, 60);
        ctx.stroke();
        ctx.resetTransform();

        // Draw armor
        ctx.translate(270, 10);
        drawBox(
          ctx,
          'Armor',
          armor ? armor + '/' + armor_max : 'ERROR',
          armor ? '#fff' : '#f00',
        );
        // Armor line
        ctx.strokeStyle = HIGHLIGHT_COLOR;
        ctx.lineWidth = 10;
        ctx.beginPath();
        ctx.moveTo(0, 10);
        ctx.lineTo(-40, 10);
        ctx.lineTo(-50, 40);
        ctx.stroke();
        ctx.resetTransform();

        // Draw hull
        ctx.translate(270, 100);
        drawBox(
          ctx,
          'Hull',
          hull ? hull + '/' + hull_max : 'ERROR',
          hull ? '#fff' : '#f00',
        );
        // Hull line
        ctx.strokeStyle = HIGHLIGHT_COLOR;
        ctx.lineWidth = 10;
        ctx.beginPath();
        ctx.moveTo(0, 10);
        ctx.lineTo(-50, 10);
        ctx.stroke();
        ctx.resetTransform();

        // Draw cell
        ctx.translate(10, 70);
        drawBox(
          ctx,
          'Battery',
          cell_charge
            ? round((cell_charge / cell_charge_max!) * 100, 2) + '%'
            : 'ERROR',
          cell_charge ? '#fff' : '#f00',
        );

        // Cell line
        ctx.strokeStyle = HIGHLIGHT_COLOR;
        ctx.lineWidth = 10;
        ctx.beginPath();
        ctx.moveTo(90, 20);
        ctx.lineTo(160, 20);
        ctx.stroke();

        ctx.resetTransform();

        // Draw the mech
        let image = await loadImage(data.appearance);
        ctx.imageSmoothingEnabled = false;
        ctx.drawImage(image, 256 / 2, 40, 128, 128);
      } catch (err) {}
    };

    draw();
  }, [
    canvasRef,
    health,
    health_max,
    armor,
    armor_max,
    hull,
    hull_max,
    cell_charge,
    cell_charge_max,
  ]);

  return <canvas width={512} height={180} ref={canvasRef} />;
};

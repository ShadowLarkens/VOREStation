import {
  PropsWithChildren,
  ReactNode,
  useCallback,
  useEffect,
  useState,
} from 'react';
import {
  Button,
  ColorBox,
  Image as ImageComp,
  ImageButton,
  Stack,
} from 'tgui-core/components';

export const getImage = async (url: string): Promise<HTMLImageElement> => {
  return new Promise((resolve, reject) => {
    const image = new Image();
    image.onload = () => {
      resolve(image);
    };
    image.onerror = (error) => {
      reject(error);
    };
    image.src = url;
  });
};

// This component
export const CanvasBackedImage = (props: {
  render: (
    canvas: OffscreenCanvas,
    ctx: OffscreenCanvasRenderingContext2D,
  ) => Promise<void>;
}) => {
  const [bitmap, setBitmap] = useState<string>('');

  useEffect(() => {
    let offscreenCanvas: OffscreenCanvas = new OffscreenCanvas(64, 64);

    let ctx = offscreenCanvas.getContext('2d');
    if (!ctx) {
      return;
    }

    const drawImage = async () => {
      // Render
      await props.render(offscreenCanvas, ctx);

      // Convert to a blob and put in our <img> tag
      let bitmap = await offscreenCanvas.convertToBlob();
      setBitmap(URL.createObjectURL(bitmap));
    };

    drawImage();

    return () => {
      if (bitmap !== '') {
        URL.revokeObjectURL(bitmap);
      }
    };
  }, [props.render]);

  return <img src={bitmap} width={64} height={64} />;
};

export const ColorizedImage = (props: {
  iconRef: string;
  iconState: string;
  color?: string | null;
}) => {
  const { iconRef, iconState, color } = props;

  // TODO: Remove when we drop support for 515/IE - fallback
  if (Byond.TRIDENT) {
    return (
      <ImageComp
        src={`${iconRef}?state=${iconState}&dir=2&frame=1`}
        width="64px"
        height="64px"
      />
    );
  }

  const render = useCallback(
    async (canvas: OffscreenCanvas, ctx: OffscreenCanvasRenderingContext2D) => {
      // Pixel art please
      ctx.imageSmoothingEnabled = false;

      // Load the image from the server
      let image = await getImage(`${iconRef}?state=${iconState}&dir=2&frame=1`);

      // Draw the image to the canvas
      ctx.drawImage(image, 0, 0, 64, 64);

      // Draw a square over the image with the color
      ctx.globalCompositeOperation = 'multiply';
      ctx.fillStyle = color || '#ffffff';
      ctx.fillRect(0, 0, 64, 64);

      // Use the image as a mask
      ctx.globalCompositeOperation = 'destination-in';
      ctx.drawImage(image, 0, 0, 64, 64);
    },
    [iconRef, iconState, color],
  );

  return <CanvasBackedImage render={render} />;
};

export const CustomImageButton = (
  props: PropsWithChildren<{
    image: ReactNode;
    tooltip?: string;
    selected?: boolean;
    onClick: () => void;
  }>,
) => {
  return (
    <ImageButton
      dmIcon="not_a_real_icon.dmi"
      dmIconState="equally_fake_icon_state"
      dmFallback={props.image}
      onClick={props.onClick}
      tooltip={props.tooltip}
      selected={props.selected}
    >
      {props.children}
    </ImageButton>
  );
};

export const ColorizedImageButton = (
  props: PropsWithChildren<{
    iconRef: string;
    iconState: string;
    color?: string | null;
    onClick: () => void;
    selected?: boolean;
    tooltip?: string;
  }>,
) => {
  const { iconRef, iconState, color, onClick, selected } = props;

  return (
    <CustomImageButton
      image={
        <ColorizedImage iconRef={iconRef} iconState={iconState} color={color} />
      }
      onClick={onClick}
      selected={selected}
      tooltip={props.tooltip}
    >
      {props.children}
    </CustomImageButton>
  );
};

export enum ColorType {
  First,
  Second,
  Third,
}

export const ColorPicker = (props: {
  onClick: (type: ColorType) => void;
  color_one?: string | null;
  color_two?: string | null;
  color_three?: string | null;
}) => {
  const { onClick, color_one, color_two, color_three } = props;

  return (
    <Stack>
      <Stack.Item>
        <Button onClick={() => onClick(ColorType.First)}>
          First Color: <ColorBox color={color_one} />
        </Button>
      </Stack.Item>
      {!!color_two && (
        <Stack.Item>
          <Button onClick={() => onClick(ColorType.Second)}>
            Second Color: <ColorBox color={color_two} />
          </Button>
        </Stack.Item>
      )}
      {!!color_three && (
        <Stack.Item>
          <Button onClick={() => onClick(ColorType.Third)}>
            Third Color: <ColorBox color={color_three} />
          </Button>
        </Stack.Item>
      )}
    </Stack>
  );
};

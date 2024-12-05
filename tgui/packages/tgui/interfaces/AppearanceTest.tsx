import { createContext, useContext, useEffect, useRef, useState } from 'react';
import { resolveAsset } from 'tgui/assets';
import { fetchRetry } from 'tgui/http';
import { Window } from 'tgui/layouts';
import { Box } from 'tgui-core/components';
import { add } from 'rustgui';

export const AppearanceTest = (props) => {
  let x = Number(add(BigInt(1), BigInt(2)));

  return (
    <Window width={400} height={400}>
      <Window.Content scrollable>abab {x}</Window.Content>
    </Window>
  );
};

const AppearanceTestInner = (props) => {
  const [red, setRed] = useState(0);
  const [green, setGreen] = useState(0);
  const [blue, setBlue] = useState(0);

  const json = useContext(JsonContext);

  if (!json) {
    return <Box>Loading...</Box>;
  }

  return <WasmInner json={json} />;
};

const WasmInner = (props: { json: Data }) => {
  const { json } = props;

  return <Box>meow</Box>;
};

const Hair = (props: {
  data: HairIconData;
  color: { red: number; green: number; blue: number };
}) => {
  const { data, color } = props;
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const [image, setImage] = useState<HTMLImageElement | null>(null);

  useEffect(() => {
    if (!Byond.iconRefMap[data.icon]) {
      return;
    }

    let icon = Byond.iconRefMap[data.icon];
    let icon_state = data.icon_state;

    let img = new Image();
    img.src = `${icon}?state=${icon_state}`;
    img.onload = () => {
      setImage(img);
    };
  }, []);

  useEffect(() => {
    let canvas = canvasRef.current;
    if (!canvas || !image) {
      return;
    }

    let ctx = canvas.getContext('2d');
    if (!ctx) {
      return;
    }

    // lol what are standards
    ctx['imageSmoothingEnabled'] = false;
    ctx.globalCompositeOperation = 'multiply';

    ctx.clearRect(0, 0, 128, 128);
    ctx.drawImage(image, 0, 0, 128, 128);
    ctx.fillStyle = `rgb(${color.red}, ${color.green}, ${color.blue})`;
    ctx.fillRect(0, 0, 128, 128);

    ctx.globalCompositeOperation = 'destination-in';
    ctx.drawImage(image, 0, 0, 128, 128);
  }, [image, color]);

  return <canvas ref={canvasRef} width="128px" height="128px" />;
};

type HairIconData = {
  icon: string;
  icon_add: string;
  icon_state: string;
};

type Data = {
  hair: Record<string, HairIconData>;
};

let fetchJson: Promise<Data> | undefined;

const populateJson = async () => {
  if (!fetchJson) {
    fetchJson = fetchRetry(resolveAsset('human_icons.json')).then((res) =>
      res.json(),
    );
  }

  return await fetchJson;
};

const JsonContext = createContext<Data | null>(null);

const JsonLoader = ({ children }) => {
  const [json, setJson] = useState<Data | null>(null);

  populateJson().then((val) => {
    setJson(val);
  });

  if (!json) {
    return <Box>Loading...</Box>;
  }

  return <JsonContext.Provider value={json}>{children}</JsonContext.Provider>;
};

import { PropsWithChildren, useEffect, useState } from 'react';
import {
  Button,
  ColorBox,
  Dimmer,
  ImageButton,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../../backend';
import { LegacyServerData, ServerData } from '../data';
import { ServerPreferencesFetcher } from '../ServerPreferencesFetcher';
import { GeneralData, GeneralDataStatic } from './data';

const ColorizedImage = (props: {
  iconRef: string;
  iconState: string;
  color: string;
}) => {
  const { iconRef, iconState, color } = props;

  const [bitmap, setBitmap] = useState<string>('');

  useEffect(() => {
    let offscreenCanvas: OffscreenCanvas = new OffscreenCanvas(64, 64);

    let ctx = offscreenCanvas.getContext('2d');
    if (!ctx) {
      return;
    }

    ctx.imageSmoothingEnabled = false;

    let image = new Image();
    image.addEventListener('load', async () => {
      ctx.drawImage(image, 0, 0, 64, 64);
      ctx.globalCompositeOperation = 'multiply';
      ctx.fillStyle = color;
      ctx.fillRect(0, 0, 64, 64);
      ctx.globalCompositeOperation = 'destination-in';
      ctx.drawImage(image, 0, 0, 64, 64);
      let bitmap = await offscreenCanvas.convertToBlob();
      setBitmap(URL.createObjectURL(bitmap));
      ctx.clearRect(0, 0, 64, 64);
    });
    image.src = `${iconRef}?state=${iconState}&dir=2&frame=1`;

    return () => {
      if (bitmap !== '') {
        URL.revokeObjectURL(bitmap);
      }
    };
  }, [iconRef, iconState, color]);

  return <img src={bitmap} width={64} height={64} />;
};

const ColorizedImageButton = (
  props: PropsWithChildren<{
    iconRef: string;
    iconState: string;
    color: string;
    onClick: () => void;
    selected?: boolean;
    tooltip?: string;
  }>,
) => {
  const { iconRef, iconState, color, onClick, selected } = props;

  return (
    <ImageButton
      dmIcon="not_a_real_icon.dmi"
      dmIconState="equally_fake_icon_state"
      dmFallback={
        <ColorizedImage iconRef={iconRef} iconState={iconState} color={color} />
      }
      onClick={onClick}
      selected={selected}
      tooltip={props.tooltip}
    >
      {props.children}
    </ImageButton>
  );
};

enum ColorType {
  First,
  Second,
  Third,
}

const ColorPicker = (props: {
  onClick: (type: ColorType) => void;
  color_one: string;
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

// ///////////////
// Main Components
// ///////////////

export const General = (props: {
  data: GeneralData;
  staticData: GeneralDataStatic;
}) => {
  return (
    <ServerPreferencesFetcher
      render={(serverData: ServerData | undefined) => {
        if (!serverData) {
          return <Section title="Loading..." />;
        }

        return (
          <GeneralContent
            data={props.data}
            staticData={props.staticData}
            serverData={serverData}
          />
        );
      }}
    />
  );
};

export const GeneralContent = (props: {
  data: GeneralData;
  staticData: GeneralDataStatic;
  serverData: ServerData;
}) => {
  const { data, staticData, serverData } = props;
  const { real_name } = staticData;
  const [showHairPopup, setShowHairPopup] = useState(false);

  const hair_color = `rgb(${data.r_hair}, ${data.g_hair}, ${data.b_hair})`;

  return (
    <Section title={real_name} fill scrollable mt={1} position="relative">
      <HairImageButton
        hairColor={hair_color}
        hairStyle={data.h_style}
        serverData={serverData.legacy}
        onClick={() => setShowHairPopup(true)}
        tooltip={data.h_style}
      >
        Hair
      </HairImageButton>
      {/* <ImageButton
        dmIcon="icons/mob/hair_gradients.dmi"
        dmIconState="fadeup"
        onClick={() => setShowHairPopup(!showHairPopup)}
      >
        Gradient
      </ImageButton>
      <ImageButton
        dmIcon="icons/mob/human_face.dmi"
        dmIconState="facial_fullbeard_s"
        onClick={() => setShowHairPopup(!showHairPopup)}
      >
        Facial
      </ImageButton>
      <ImageButton
        dmIcon="icons/mob/vore/ears_vr.dmi"
        dmIconState="kitty"
        onClick={() => setShowHairPopup(!showHairPopup)}
      >
        Ears
      </ImageButton>
      <ImageButton
        dmIcon="icons/mob/vore/ears_vr.dmi"
        dmIconState="ram_horns_s"
        onClick={() => setShowHairPopup(!showHairPopup)}
      >
        Horns
      </ImageButton>
      <ImageButton
        dmIcon="icons/mob/human_races/sprite_accessories/taurs.dmi"
        dmIconState="naga_s"
        onClick={() => setShowHairPopup(!showHairPopup)}
      >
        Tail
      </ImageButton>
      <ImageButton
        dmIcon="icons/mob/human_races/sprite_accessories/wings.dmi"
        dmIconState="succubus-red"
        onClick={() => setShowHairPopup(!showHairPopup)}
      >
        Wing
      </ImageButton> */}
      {showHairPopup && (
        <HairDimmer
          data={data}
          staticData={staticData}
          serverData={serverData.legacy}
          setShowHairPopup={setShowHairPopup}
          hairColor={hair_color}
        />
      )}
    </Section>
  );
};

const HairImageButton = (
  props: PropsWithChildren<{
    serverData: LegacyServerData;
    hairStyle: string;
    hairColor: string;
    onClick: () => void;
    tooltip?: string;
    selected?: boolean;
  }>,
) => {
  const { serverData, hairStyle, hairColor, onClick } = props;

  if (!(hairStyle in serverData.hair_styles)) {
    return (
      <ImageButton verticalAlign="top" onClick={onClick}>
        {props.children}
      </ImageButton>
    );
  }

  const data = serverData.hair_styles[hairStyle];
  return (
    <ColorizedImageButton
      iconRef={data.icon}
      iconState={data.icon_state + '_s'}
      color={hairColor}
      onClick={onClick}
      tooltip={props.tooltip}
      selected={props.selected}
    >
      {props.children}
    </ColorizedImageButton>
  );
};

const HairDimmer = (props: {
  setShowHairPopup: React.Dispatch<React.SetStateAction<boolean>>;
  data: GeneralData;
  serverData: LegacyServerData;
  staticData: GeneralDataStatic;
  hairColor: string;
}) => {
  const { act } = useBackend();
  const { setShowHairPopup, data, serverData, staticData, hairColor } = props;

  const hair_styles = staticData.available_hair_styles;
  hair_styles.sort();

  return (
    <Dimmer
      style={{
        display: 'block',
        overflowY: 'auto',
        textIndent: 0,
        textAlign: 'center',
        zIndex: 100,
      }}
      height="100%"
      p={1}
    >
      <Stack fill justify="space-between">
        <Stack.Item>
          <ColorPicker onClick={() => {}} color_one={hairColor} />
        </Stack.Item>
        <Stack.Item>
          <Button onClick={() => setShowHairPopup(false)} color="bad">
            Close
          </Button>
        </Stack.Item>
      </Stack>

      {hair_styles.map((hairStyle) => (
        <HairImageButton
          key={hairStyle}
          hairStyle={hairStyle}
          serverData={serverData}
          hairColor={hairColor}
          tooltip={hairStyle}
          onClick={() => {
            act('set_hair_style', { hair_style: hairStyle });
          }}
          selected={hairStyle === data.h_style}
        >
          {hairStyle}
        </HairImageButton>
      ))}
    </Dimmer>
  );
};

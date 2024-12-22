import { PropsWithChildren } from 'react';
import { useBackend } from 'tgui/backend';
import { Button, Dimmer, ImageButton, Stack } from 'tgui-core/components';

import { GeneralData, GeneralDataConstant, GeneralDataStatic } from '../data';
import {
  ColorizedImageButton,
  ColorPicker,
  ColorType,
} from '../helper_components';

export const EarsImageButton = (
  props: PropsWithChildren<{
    serverData: GeneralDataConstant;
    style: string;
    color?: string | null;
    onClick: () => void;
    tooltip?: string;
    selected?: boolean;
  }>,
) => {
  const { serverData, style, color, onClick } = props;

  if (!(style in serverData.ear_styles)) {
    return (
      <ImageButton
        verticalAlign="top"
        onClick={onClick}
        tooltip={props.tooltip}
        selected={props.selected}
      >
        {props.children}
      </ImageButton>
    );
  }

  const data = serverData.ear_styles[style];
  return (
    <ColorizedImageButton
      iconRef={data.icon}
      iconState={data.icon_state}
      color={color}
      onClick={onClick}
      tooltip={props.tooltip}
      selected={props.selected}
    >
      {props.children}
    </ColorizedImageButton>
  );
};

export const EarsDimmer = (props: {
  setShow: React.Dispatch<React.SetStateAction<boolean>>;
  data: GeneralData;
  serverData: GeneralDataConstant;
  staticData: GeneralDataStatic;
  color: string;
  color2: string;
  color3: string;
}) => {
  const { act } = useBackend();
  const { setShow, data, serverData, staticData, color, color2, color3 } =
    props;

  let styles = staticData.available_ear_styles;
  styles.sort();

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
          <ColorPicker
            onClick={(type: ColorType) => {
              switch (type) {
                case ColorType.First:
                  act('set_ear_color');
                  break;
                case ColorType.Second:
                  act('set_ear_color2');
                  break;
                case ColorType.Third:
                  act('set_ear_color3');
                  break;
              }
            }}
            color_one={color || '#FFFFFF'}
            color_two={color2 || '#FFFFFF'}
            color_three={color3 || '#FFFFFF'}
          />
        </Stack.Item>
        <Stack.Item>
          <Button onClick={() => setShow(false)} color="bad">
            Close
          </Button>
        </Stack.Item>
      </Stack>

      {styles.map((style) => (
        <EarsImageButton
          key={style}
          style={style}
          color={color}
          serverData={serverData}
          tooltip={style}
          selected={
            style === data.ear_style ||
            (data.ear_style === null && style === 'None')
          }
          onClick={() => act('set_ear_style', { ear_style: style })}
        >
          {style}
        </EarsImageButton>
      ))}
    </Dimmer>
  );
};

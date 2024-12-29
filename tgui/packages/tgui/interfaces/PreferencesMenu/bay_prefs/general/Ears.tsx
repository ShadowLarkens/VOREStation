import { PropsWithChildren } from 'react';
import { useBackend } from 'tgui/backend';
import { Box, Button, ImageButton, Section } from 'tgui-core/components';

import { GeneralData, GeneralDataConstant, GeneralDataStatic } from '../data';
import { VisiblePopup } from '../General';
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
        dmIcon="not_a_real_icon"
        dmIconState="not_a_real_icon"
        dmFallback={<Box width="64px" height="64px" />}
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
  setShow: React.Dispatch<React.SetStateAction<VisiblePopup>>;
  data: GeneralData;
  serverData: GeneralDataConstant;
  staticData: GeneralDataStatic;
}) => {
  const { act } = useBackend();
  const { setShow, data, serverData, staticData } = props;
  const color = `rgb(${data.r_ears}, ${data.g_ears}, ${data.b_ears})`;
  const color2 = `rgb(${data.r_ears2}, ${data.g_ears2}, ${data.b_ears2})`;
  const color3 = `rgb(${data.r_ears3}, ${data.g_ears3}, ${data.b_ears3})`;

  let styles = staticData.available_ear_styles;
  styles.sort();

  return (
    <Section
      title="Ears"
      fill
      scrollable
      mt={1}
      buttons={
        <Button onClick={() => setShow(VisiblePopup.None)} color="bad">
          Close
        </Button>
      }
    >
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
    </Section>
  );
};

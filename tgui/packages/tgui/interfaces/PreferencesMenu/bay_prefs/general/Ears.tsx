import { PropsWithChildren } from 'react';
import { useBackend } from 'tgui/backend';
import { Button, ImageButton, Section } from 'tgui-core/components';

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

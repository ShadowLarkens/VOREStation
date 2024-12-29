import { PropsWithChildren } from 'react';
import { useBackend } from 'tgui/backend';
import { Button, ImageButton, Section } from 'tgui-core/components';

import { GeneralData, GeneralDataConstant, GeneralDataStatic } from '../data';
import { VisiblePopup } from '../General';
import { ColorizedImageButton, ColorPicker } from '../helper_components';

export const HairImageButton = (
  props: PropsWithChildren<{
    serverData: GeneralDataConstant;
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

export const HairDimmer = (props: {
  setShow: React.Dispatch<React.SetStateAction<VisiblePopup>>;
  data: GeneralData;
  serverData: GeneralDataConstant;
  staticData: GeneralDataStatic;
}) => {
  const { act } = useBackend();
  const { setShow, data, serverData, staticData } = props;
  const hairColor = `rgb(${data.r_hair}, ${data.g_hair}, ${data.b_hair})`;

  const hair_styles = staticData.available_hair_styles;
  hair_styles.sort();

  return (
    <Section
      title="Hair"
      fill
      scrollable
      mt={1}
      buttons={
        <Button onClick={() => setShow(VisiblePopup.None)} color="bad">
          Close
        </Button>
      }
    >
      {!!data.has_hair_color && (
        <ColorPicker
          onClick={() => {
            act('set_hair_color');
          }}
          color_one={hairColor}
        />
      )}

      {hair_styles.map((hairStyle) => (
        <HairImageButton
          key={hairStyle}
          hairStyle={hairStyle}
          hairColor={hairColor}
          serverData={serverData}
          tooltip={hairStyle}
          onClick={() => {
            act('set_hair_style', { hair_style: hairStyle });
          }}
          selected={hairStyle === data.h_style}
        >
          {hairStyle}
        </HairImageButton>
      ))}
    </Section>
  );
};

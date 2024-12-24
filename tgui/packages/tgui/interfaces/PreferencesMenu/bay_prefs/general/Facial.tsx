import { PropsWithChildren } from 'react';
import { useBackend } from 'tgui/backend';
import { Button, ImageButton, Section } from 'tgui-core/components';

import { GeneralData, GeneralDataConstant, GeneralDataStatic } from '../data';
import { VisiblePopup } from '../General';
import { ColorizedImageButton, ColorPicker } from '../helper_components';

export const FacialImageButton = (
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

  if (!(hairStyle in serverData.facial_styles)) {
    return (
      <ImageButton verticalAlign="top" onClick={onClick}>
        {props.children}
      </ImageButton>
    );
  }

  const data = serverData.facial_styles[hairStyle];
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

export const FacialDimmer = (props: {
  setShow: React.Dispatch<React.SetStateAction<VisiblePopup>>;
  data: GeneralData;
  serverData: GeneralDataConstant;
  staticData: GeneralDataStatic;
  hairColor: string;
}) => {
  const { act } = useBackend();
  const { setShow, data, serverData, staticData, hairColor } = props;

  const hair_styles = staticData.available_facial_styles;
  hair_styles.sort();

  return (
    <Section
      title="Facial"
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
            act('set_facial_hair_color');
          }}
          color_one={hairColor}
        />
      )}

      {hair_styles.map((hairStyle) => (
        <FacialImageButton
          key={hairStyle}
          hairStyle={hairStyle}
          serverData={serverData}
          hairColor={hairColor}
          tooltip={hairStyle}
          onClick={() => {
            act('set_facial_hair_style', { facial_hair_style: hairStyle });
          }}
          selected={hairStyle === data.f_style}
        >
          {hairStyle}
        </FacialImageButton>
      ))}
    </Section>
  );
};

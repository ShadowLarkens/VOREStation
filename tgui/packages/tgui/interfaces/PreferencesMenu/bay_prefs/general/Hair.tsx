import { PropsWithChildren } from 'react';
import { useBackend } from 'tgui/backend';
import { Button, Dimmer, ImageButton, Stack } from 'tgui-core/components';

import { GeneralData, GeneralDataConstant, GeneralDataStatic } from '../data';
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
  setShow: React.Dispatch<React.SetStateAction<boolean>>;
  data: GeneralData;
  serverData: GeneralDataConstant;
  staticData: GeneralDataStatic;
  hairColor: string;
}) => {
  const { act } = useBackend();
  const { setShow, data, serverData, staticData, hairColor } = props;

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
      {!!data.has_hair_color && (
        <Stack fill justify="space-between">
          <Stack.Item>
            <ColorPicker
              onClick={() => {
                act('set_hair_color');
              }}
              color_one={hairColor}
            />
          </Stack.Item>
          <Stack.Item>
            <Button onClick={() => setShow(false)} color="bad">
              Close
            </Button>
          </Stack.Item>
        </Stack>
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
    </Dimmer>
  );
};

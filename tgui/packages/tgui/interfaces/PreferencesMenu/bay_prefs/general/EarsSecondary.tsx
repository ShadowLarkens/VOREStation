import { useBackend } from 'tgui/backend';
import { Button, Dimmer, Stack } from 'tgui-core/components';

import { GeneralData, GeneralDataConstant, GeneralDataStatic } from '../data';
import { ColorPicker, ColorType } from '../helper_components';
import { EarsImageButton } from './Ears';

// Flavored as "Horns"
export const EarsSecondaryDimmer = (props: {
  setShow: React.Dispatch<React.SetStateAction<boolean>>;
  data: GeneralData;
  serverData: GeneralDataConstant;
  staticData: GeneralDataStatic;
  colors: string[];
}) => {
  const { act } = useBackend();
  const { setShow, data, serverData, staticData, colors } = props;

  const color1 = colors[0] || null;
  const color2 = colors[1] || null;
  const color3 = colors[2] || null;

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
                  act('set_ear_secondary_color', { type: 1 });
                  break;
                case ColorType.Second:
                  act('set_ear_secondary_color', { type: 2 });
                  break;
                case ColorType.Third:
                  act('set_ear_secondary_color', { type: 3 });
                  break;
              }
            }}
            color_one={color1 || '#FFFFFF'}
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
          color={color1}
          serverData={serverData}
          tooltip={style}
          selected={
            style === data.ear_secondary_style ||
            (data.ear_secondary_style === null && style === 'None')
          }
          onClick={() => act('set_ear_secondary_style', { ear_style: style })}
        >
          {style}
        </EarsImageButton>
      ))}
    </Dimmer>
  );
};

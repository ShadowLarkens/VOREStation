import { useBackend } from 'tgui/backend';
import { Button, Section } from 'tgui-core/components';

import { GeneralData, GeneralDataConstant, GeneralDataStatic } from '../data';
import { VisiblePopup } from '../General';
import { ColorPicker, ColorType } from '../helper_components';
import { EarsImageButton } from './Ears';

// Flavored as "Horns"
export const EarsSecondaryDimmer = (props: {
  setShow: React.Dispatch<React.SetStateAction<VisiblePopup>>;
  data: GeneralData;
  serverData: GeneralDataConstant;
  staticData: GeneralDataStatic;
}) => {
  const { act } = useBackend();
  const { setShow, data, serverData, staticData } = props;

  const colors = data.ear_secondary_colors;

  const color1 = colors[0] || null;
  const color2 = colors[1] || null;
  const color3 = colors[2] || null;

  let styles = staticData.available_ear_styles;
  styles.sort();

  return (
    <Section
      title="Horns"
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
    </Section>
  );
};

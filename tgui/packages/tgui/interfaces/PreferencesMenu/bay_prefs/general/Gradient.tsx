import { PropsWithChildren } from 'react';
import { useBackend } from 'tgui/backend';
import { Button, ImageButton, Section } from 'tgui-core/components';

import { GeneralData, GeneralDataConstant, GeneralDataStatic } from '../data';
import { VisiblePopup } from '../General';
import { ColorizedImageButton, ColorPicker } from '../helper_components';

export const GradientImageButton = (
  props: PropsWithChildren<{
    serverData: GeneralDataConstant;
    style: string;
    color: string;
    onClick: () => void;
    tooltip?: string;
    selected?: boolean;
  }>,
) => {
  const { serverData, style, color, onClick } = props;

  if (!(style in serverData.grad_styles)) {
    return (
      <ImageButton verticalAlign="top" onClick={onClick}>
        {props.children}
      </ImageButton>
    );
  }

  const data = serverData.grad_styles[style];
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

export const GradientDimmer = (props: {
  setShow: React.Dispatch<React.SetStateAction<VisiblePopup>>;
  data: GeneralData;
  serverData: GeneralDataConstant;
  staticData: GeneralDataStatic;
}) => {
  const { act } = useBackend();
  const { setShow, data, serverData, staticData } = props;
  const color = `rgb(${data.r_grad}, ${data.g_grad}, ${data.b_grad})`;

  const grad_styles = Object.keys(serverData.grad_styles);
  grad_styles.sort();

  return (
    <Section
      title="Gradient"
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
        onClick={() => {
          act('set_grad_color');
        }}
        color_one={color}
      />

      {grad_styles.map((style) => (
        <GradientImageButton
          key={style}
          style={style}
          color={color}
          serverData={serverData}
          tooltip={style}
          selected={style === data.grad_style}
          onClick={() => act('set_grad_style', { grad_style: style })}
        />
      ))}
    </Section>
  );
};

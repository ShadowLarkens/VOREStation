import { PropsWithChildren } from 'react';
import { useBackend } from 'tgui/backend';
import { Button, Dimmer, ImageButton, Stack } from 'tgui-core/components';

import { GeneralData, GeneralDataConstant, GeneralDataStatic } from '../data';
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
  setShow: React.Dispatch<React.SetStateAction<boolean>>;
  data: GeneralData;
  serverData: GeneralDataConstant;
  staticData: GeneralDataStatic;
  color: string;
}) => {
  const { act } = useBackend();
  const { setShow, data, serverData, staticData, color } = props;

  const grad_styles = Object.keys(serverData.grad_styles);
  grad_styles.sort();

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
            onClick={() => {
              act('set_grad_color');
            }}
            color_one={color}
          />
        </Stack.Item>
        <Stack.Item>
          <Button onClick={() => setShow(false)} color="bad">
            Close
          </Button>
        </Stack.Item>
      </Stack>

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
    </Dimmer>
  );
};

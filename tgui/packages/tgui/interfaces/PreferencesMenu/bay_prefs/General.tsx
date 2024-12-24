import { useState } from 'react';
import { Box, Button, Icon, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../../backend';
import { ServerData } from '../data';
import { ServerPreferencesFetcher } from '../ServerPreferencesFetcher';
import { GeneralData, GeneralDataConstant, GeneralDataStatic } from './data';
import { EarsDimmer, EarsImageButton } from './general/Ears';
import { EarsSecondaryDimmer } from './general/EarsSecondary';
import { FacialDimmer, FacialImageButton } from './general/Facial';
import { GradientDimmer, GradientImageButton } from './general/Gradient';
import { HairDimmer, HairImageButton } from './general/Hair';
import { MarkingsPopup } from './general/Markings';
import { CustomImageButton } from './helper_components';

// ///////////////
// Main Components
// ///////////////

export const General = (props: {
  data: GeneralData;
  staticData: GeneralDataStatic;
}) => {
  return (
    <ServerPreferencesFetcher
      render={(serverData: ServerData | undefined) => {
        if (!serverData) {
          return <Section title="Loading..." />;
        }

        return (
          <GeneralContent
            data={props.data}
            staticData={props.staticData}
            serverData={serverData.legacy as GeneralDataConstant}
          />
        );
      }}
    />
  );
};

const NameSelection = (props: { data: GeneralData }) => {
  const { act } = useBackend();
  const { real_name, nickname, be_random_name } = props.data;

  return (
    <>
      <Button onClick={() => act('rename')} tooltip="Real Name">
        {real_name}
      </Button>
      <Box inline ml={1} mr={1}>
        -
      </Box>
      <Button onClick={() => act('nickname')} tooltip="Nickname">
        {nickname || 'No Nickname'}
      </Button>
      {!!nickname && (
        <Button
          icon="times"
          onClick={() => act('reset_nickname')}
          tooltip="Reset Nickname"
        />
      )}
      <Button
        ml={2}
        onClick={() => act('random_name')}
        icon="dice"
        tooltip="Random Name"
      />
      <Button.Checkbox
        checked={be_random_name}
        selected={be_random_name}
        onClick={() => act('always_random_name')}
        tooltip="Always Randomize"
      />
    </>
  );
};

export enum VisiblePopup {
  None,
  Hair,
  Facial,
  Gradient,
  Ears,
  Ears2,
  Markings,
}

export const GeneralContent = (props: {
  data: GeneralData;
  staticData: GeneralDataStatic;
  serverData: GeneralDataConstant;
}) => {
  const { data, staticData, serverData } = props;

  const hair_color = `rgb(${data.r_hair}, ${data.g_hair}, ${data.b_hair})`;
  const facial_color = `rgb(${data.r_facial}, ${data.g_facial}, ${data.b_facial})`;
  const grad_color = `rgb(${data.r_grad}, ${data.g_grad}, ${data.b_grad})`;

  const ears_color1 = `rgb(${data.r_ears}, ${data.g_ears}, ${data.b_ears})`;
  const ears_color2 = `rgb(${data.r_ears2}, ${data.g_ears2}, ${data.b_ears2})`;
  const ears_color3 = `rgb(${data.r_ears3}, ${data.g_ears3}, ${data.b_ears3})`;
  const ear_secondary_colors = data.ear_secondary_colors;

  const [visiblePopup, setVisiblePopup] = useState<VisiblePopup>(
    VisiblePopup.None,
  );

  switch (visiblePopup) {
    case VisiblePopup.Hair: {
      return (
        <HairDimmer
          data={data}
          staticData={staticData}
          serverData={serverData}
          setShow={setVisiblePopup}
          hairColor={hair_color}
        />
      );
    }
    case VisiblePopup.Facial: {
      return (
        <FacialDimmer
          data={data}
          staticData={staticData}
          serverData={serverData}
          setShow={setVisiblePopup}
          hairColor={facial_color}
        />
      );
    }
    case VisiblePopup.Gradient: {
      return (
        <GradientDimmer
          data={data}
          staticData={staticData}
          serverData={serverData}
          setShow={setVisiblePopup}
          color={grad_color}
        />
      );
    }
    case VisiblePopup.Ears: {
      return (
        <EarsDimmer
          data={data}
          staticData={staticData}
          serverData={serverData}
          setShow={setVisiblePopup}
          color={ears_color1}
          color2={ears_color2}
          color3={ears_color3}
        />
      );
    }
    case VisiblePopup.Ears2: {
      return (
        <EarsSecondaryDimmer
          data={data}
          staticData={staticData}
          serverData={serverData}
          setShow={setVisiblePopup}
          colors={ear_secondary_colors}
        />
      );
    }
    case VisiblePopup.Markings: {
      return (
        <MarkingsPopup
          data={data}
          staticData={staticData}
          serverData={serverData}
          setShow={setVisiblePopup}
        />
      );
    }
    default: {
      return (
        <Section
          title={<NameSelection data={data} />}
          fill
          scrollable
          mt={1}
          position="relative"
        >
          <Stack vertical fill>
            <Stack.Item>
              <HairImageButton
                hairColor={hair_color}
                hairStyle={data.h_style}
                serverData={serverData}
                onClick={() => setVisiblePopup(VisiblePopup.Hair)}
                tooltip={data.h_style}
              >
                Hair
              </HairImageButton>
              <GradientImageButton
                color={grad_color}
                style={data.grad_style}
                serverData={serverData}
                onClick={() => setVisiblePopup(VisiblePopup.Gradient)}
                tooltip={data.grad_style}
              >
                Gradient
              </GradientImageButton>
              <Box inline ml={2}>
                <FacialImageButton
                  hairColor={facial_color}
                  hairStyle={data.f_style}
                  serverData={serverData}
                  onClick={() => setVisiblePopup(VisiblePopup.Facial)}
                  tooltip={data.f_style}
                >
                  Facial
                </FacialImageButton>
              </Box>
            </Stack.Item>
            <Stack.Item>
              <EarsImageButton
                color={ears_color1}
                style={data.ear_style || 'None'}
                serverData={serverData}
                onClick={() => setVisiblePopup(VisiblePopup.Ears)}
                tooltip={data.ear_style || 'None'}
              >
                Ears
              </EarsImageButton>
              <EarsImageButton
                color={ear_secondary_colors[0]}
                style={data.ear_secondary_style || 'None'}
                serverData={serverData}
                onClick={() => setVisiblePopup(VisiblePopup.Ears2)}
                tooltip={data.ear_secondary_style || 'None'}
              >
                Horns
              </EarsImageButton>
              <Box inline ml={2}>
                <CustomImageButton
                  image={<Icon name="marker" size={4} m={1.3} />}
                  tooltip="Body Markings"
                  onClick={() => setVisiblePopup(VisiblePopup.Markings)}
                >
                  Markings
                </CustomImageButton>
              </Box>
            </Stack.Item>
          </Stack>
        </Section>
      );
    }
  }
};

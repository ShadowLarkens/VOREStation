import { useState } from 'react';
import { Box, Button, ImageButton, Section, Stack } from 'tgui-core/components';

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

export const GeneralContent = (props: {
  data: GeneralData;
  staticData: GeneralDataStatic;
  serverData: GeneralDataConstant;
}) => {
  const { data, staticData, serverData } = props;
  const { real_name, nickname, be_random_name } = data;
  const { act } = useBackend();

  const [showHairPopup, setShowHairPopup] = useState(false);
  const [showFacialPopup, setShowFacialPopup] = useState(false);
  const [showGradientPopup, setShowGradientPopup] = useState(false);
  const [showEarsPopup, setShowEarsPopup] = useState(false);
  const [showEars2Popup, setShowEars2Popup] = useState(false);
  const [showMarkingsPopup, setShowMarkingsPopup] = useState(false);

  const hair_color = `rgb(${data.r_hair}, ${data.g_hair}, ${data.b_hair})`;
  const facial_color = `rgb(${data.r_facial}, ${data.g_facial}, ${data.b_facial})`;
  const grad_color = `rgb(${data.r_grad}, ${data.g_grad}, ${data.b_grad})`;

  const ears_color1 = `rgb(${data.r_ears}, ${data.g_ears}, ${data.b_ears})`;
  const ears_color2 = `rgb(${data.r_ears2}, ${data.g_ears2}, ${data.b_ears2})`;
  const ears_color3 = `rgb(${data.r_ears3}, ${data.g_ears3}, ${data.b_ears3})`;
  const ear_secondary_colors = data.ear_secondary_colors;

  return (
    <Section
      title={
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
      }
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
            onClick={() => setShowHairPopup(true)}
            tooltip={data.h_style}
          >
            Hair
          </HairImageButton>
          <GradientImageButton
            color={grad_color}
            style={data.grad_style}
            serverData={serverData}
            onClick={() => setShowGradientPopup(true)}
            tooltip={data.grad_style}
          >
            Gradient
          </GradientImageButton>
          <Box inline ml={2}>
            <FacialImageButton
              hairColor={facial_color}
              hairStyle={data.f_style}
              serverData={serverData}
              onClick={() => setShowFacialPopup(true)}
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
            onClick={() => setShowEarsPopup(true)}
            tooltip={data.ear_style || 'None'}
          >
            Ears
          </EarsImageButton>
          <EarsImageButton
            color={ear_secondary_colors[0]}
            style={data.ear_secondary_style || 'None'}
            serverData={serverData}
            onClick={() => setShowEars2Popup(true)}
            tooltip={data.ear_secondary_style || 'None'}
          >
            Horns
          </EarsImageButton>
        </Stack.Item>
        <Stack.Item>
          <ImageButton
            verticalAlign="top"
            tooltip="Body Markings"
            onClick={() => setShowMarkingsPopup(true)}
          >
            Markings
          </ImageButton>
        </Stack.Item>
      </Stack>
      {/*
      <ImageButton
        dmIcon="icons/mob/human_races/sprite_accessories/taurs.dmi"
        dmIconState="naga_s"
        onClick={() => setShowHairPopup(!showHairPopup)}
      >
        Tail
      </ImageButton>
      <ImageButton
        dmIcon="icons/mob/human_races/sprite_accessories/wings.dmi"
        dmIconState="succubus-red"
        onClick={() => setShowHairPopup(!showHairPopup)}
      >
        Wing
      </ImageButton> */}
      {showHairPopup && (
        <HairDimmer
          data={data}
          staticData={staticData}
          serverData={serverData}
          setShow={setShowHairPopup}
          hairColor={hair_color}
        />
      )}
      {showFacialPopup && (
        <FacialDimmer
          data={data}
          staticData={staticData}
          serverData={serverData}
          setShow={setShowFacialPopup}
          hairColor={facial_color}
        />
      )}
      {showGradientPopup && (
        <GradientDimmer
          data={data}
          staticData={staticData}
          serverData={serverData}
          setShow={setShowGradientPopup}
          color={grad_color}
        />
      )}
      {showEarsPopup && (
        <EarsDimmer
          data={data}
          staticData={staticData}
          serverData={serverData}
          setShow={setShowEarsPopup}
          color={ears_color1}
          color2={ears_color2}
          color3={ears_color3}
        />
      )}
      {showEars2Popup && (
        <EarsSecondaryDimmer
          data={data}
          staticData={staticData}
          serverData={serverData}
          setShow={setShowEars2Popup}
          colors={ear_secondary_colors}
        />
      )}
      {showMarkingsPopup && (
        <MarkingsPopup
          data={data}
          staticData={staticData}
          serverData={serverData}
          setShow={setShowMarkingsPopup}
        />
      )}
    </Section>
  );
};

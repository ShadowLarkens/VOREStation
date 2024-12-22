import { useState } from 'react';
import { Section } from 'tgui-core/components';

import { ServerData } from '../data';
import { ServerPreferencesFetcher } from '../ServerPreferencesFetcher';
import { GeneralData, GeneralDataConstant, GeneralDataStatic } from './data';
import { EarsDimmer, EarsImageButton } from './general/Ears';
import { FacialDimmer, FacialImageButton } from './general/Facial';
import { GradientDimmer, GradientImageButton } from './general/Gradient';
import { HairDimmer, HairImageButton } from './general/Hair';

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
  const { real_name } = staticData;
  const [showHairPopup, setShowHairPopup] = useState(false);
  const [showFacialPopup, setShowFacialPopup] = useState(false);
  const [showGradientPopup, setShowGradientPopup] = useState(false);
  const [showEarsPopup, setShowEarsPopup] = useState(false);

  const hair_color = `rgb(${data.r_hair}, ${data.g_hair}, ${data.b_hair})`;
  const facial_color = `rgb(${data.r_facial}, ${data.g_facial}, ${data.b_facial})`;
  const grad_color = `rgb(${data.r_grad}, ${data.g_grad}, ${data.b_grad})`;

  const ears_color1 = `rgb(${data.r_ears}, ${data.g_ears}, ${data.b_ears})`;
  const ears_color2 = `rgb(${data.r_ears2}, ${data.g_ears2}, ${data.b_ears2})`;
  const ears_color3 = `rgb(${data.r_ears3}, ${data.g_ears3}, ${data.b_ears3})`;

  return (
    <Section title={real_name} fill scrollable mt={1} position="relative">
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
      <FacialImageButton
        hairColor={facial_color}
        hairStyle={data.f_style}
        serverData={serverData}
        onClick={() => setShowFacialPopup(true)}
        tooltip={data.f_style}
      >
        Facial
      </FacialImageButton>
      <EarsImageButton
        color={hair_color}
        style={data.ear_style}
        serverData={serverData}
        onClick={() => setShowEarsPopup(true)}
        tooltip={data.ear_style}
      >
        Ears
      </EarsImageButton>
      {/* <ImageButton
        dmIcon="icons/mob/hair_gradients.dmi"
        dmIconState="fadeup"
        onClick={() => setShowHairPopup(!showHairPopup)}
      >
        Gradient
      </ImageButton>
      <ImageButton
        dmIcon="icons/mob/human_face.dmi"
        dmIconState="facial_fullbeard_s"
        onClick={() => setShowHairPopup(!showHairPopup)}
      >
        Facial
      </ImageButton>
      <ImageButton
        dmIcon="icons/mob/vore/ears_vr.dmi"
        dmIconState="kitty"
        onClick={() => setShowHairPopup(!showHairPopup)}
      >
        Ears
      </ImageButton>
      <ImageButton
        dmIcon="icons/mob/vore/ears_vr.dmi"
        dmIconState="ram_horns_s"
        onClick={() => setShowHairPopup(!showHairPopup)}
      >
        Horns
      </ImageButton>
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
    </Section>
  );
};

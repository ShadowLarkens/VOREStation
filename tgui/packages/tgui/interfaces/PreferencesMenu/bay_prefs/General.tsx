import { useEffect, useRef, useState } from 'react';
import {
  Button,
  ColorBox,
  Dimmer,
  ImageButton,
  Section,
  Stack,
} from 'tgui-core/components';

import { GeneralDataStatic } from './data';

const ColorizedImage = (props: {
  dmIcon: string;
  dmIconState: string;
  color: string;
}) => {
  const { dmIcon, dmIconState, color } = props;

  let ref = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    if (!ref.current) {
      return;
    }

    let ctx = ref.current.getContext('2d');
    if (!ctx) {
      return;
    }

    ctx.imageSmoothingEnabled = false;

    let image = new Image();
    image.addEventListener('load', () => {
      ctx.drawImage(image, 0, 0, 64, 64);
      ctx.globalCompositeOperation = 'multiply';
      ctx.fillStyle = color;
      ctx.fillRect(0, 0, 64, 64);
      ctx.globalCompositeOperation = 'destination-in';
      ctx.drawImage(image, 0, 0, 64, 64);
    });
    image.src = `${Byond.iconRefMap[dmIcon]}?state=${dmIconState}`;

    return () => {
      image.remove();
    };
  }, [dmIcon, dmIconState, ref]);

  return (
    <Stack.Item>
      <canvas width={64} height={64} ref={ref} />
    </Stack.Item>
  );
};

export const General = (props: { static_data: GeneralDataStatic }) => {
  const { static_data } = props;

  const { real_name } = static_data;

  const [showHairPopup, setShowHairPopup] = useState(false);

  return (
    <Section title={real_name} fill scrollable mt={1} position="relative">
      <ImageButton
        dmIcon="icons/mob/Human_face_m.dmi"
        dmIconState="hair_emo_s"
        onClick={() => setShowHairPopup(!showHairPopup)}
      >
        Hair
      </ImageButton>
      <ImageButton
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
      </ImageButton>
      {showHairPopup && (
        <Dimmer style={{ zIndex: 100, overflow: 'auto' }} height="100%" pt={8}>
          <Stack fill vertical>
            <Stack.Item>
              <Stack align="center" verticalAlign="middle">
                <Stack.Item>
                  <Button>
                    First Color: <ColorBox color="#afaf00" />
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <Button>
                    Second Color: <ColorBox color="#00afaf" />
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <Button>
                    Third Color: <ColorBox color="#af00af" />
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="times"
                    color="bad"
                    onClick={() => setShowHairPopup(false)}
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item grow>
              <ImageButton
                dmIcon="not_a_real_icon.dmi"
                dmIconState="equally_fake_icon_state"
                dmFallback={
                  <ColorizedImage
                    dmIcon="icons/mob/Human_face_m.dmi"
                    dmIconState="hair_emo_s"
                    color="rgb(0, 100, 100)"
                  />
                }
                onClick={() => setShowHairPopup(!showHairPopup)}
              >
                Emo
              </ImageButton>
              <ImageButton
                dmIcon="not_a_real_icon.dmi"
                dmIconState="equally_fake_icon_state"
                dmFallback={
                  <ColorizedImage
                    dmIcon="icons/mob/Human_face_m.dmi"
                    dmIconState="hair_emo_s"
                    color="rgb(0, 100, 100)"
                  />
                }
                onClick={() => setShowHairPopup(!showHairPopup)}
              >
                Emo
              </ImageButton>
              <ImageButton
                dmIcon="not_a_real_icon.dmi"
                dmIconState="equally_fake_icon_state"
                dmFallback={
                  <ColorizedImage
                    dmIcon="icons/mob/Human_face_m.dmi"
                    dmIconState="hair_emo_s"
                    color="rgb(0, 100, 100)"
                  />
                }
                onClick={() => setShowHairPopup(!showHairPopup)}
              >
                Emo
              </ImageButton>
              <ImageButton
                dmIcon="not_a_real_icon.dmi"
                dmIconState="equally_fake_icon_state"
                dmFallback={
                  <ColorizedImage
                    dmIcon="icons/mob/Human_face_m.dmi"
                    dmIconState="hair_emo_s"
                    color="rgb(0, 100, 100)"
                  />
                }
                onClick={() => setShowHairPopup(!showHairPopup)}
              >
                Emo
              </ImageButton>
              <ImageButton
                dmIcon="not_a_real_icon.dmi"
                dmIconState="equally_fake_icon_state"
                dmFallback={
                  <ColorizedImage
                    dmIcon="icons/mob/Human_face_m.dmi"
                    dmIconState="hair_emo_s"
                    color="rgb(0, 100, 100)"
                  />
                }
                onClick={() => setShowHairPopup(!showHairPopup)}
              >
                Emo
              </ImageButton>
              <ImageButton
                dmIcon="not_a_real_icon.dmi"
                dmIconState="equally_fake_icon_state"
                dmFallback={
                  <ColorizedImage
                    dmIcon="icons/mob/Human_face_m.dmi"
                    dmIconState="hair_emo_s"
                    color="rgb(0, 100, 100)"
                  />
                }
                onClick={() => setShowHairPopup(!showHairPopup)}
              >
                Emo
              </ImageButton>
              <ImageButton
                dmIcon="not_a_real_icon.dmi"
                dmIconState="equally_fake_icon_state"
                dmFallback={
                  <ColorizedImage
                    dmIcon="icons/mob/Human_face_m.dmi"
                    dmIconState="hair_emo_s"
                    color="rgb(0, 100, 100)"
                  />
                }
                onClick={() => setShowHairPopup(!showHairPopup)}
              >
                Emo
              </ImageButton>
              <ImageButton
                dmIcon="not_a_real_icon.dmi"
                dmIconState="equally_fake_icon_state"
                dmFallback={
                  <ColorizedImage
                    dmIcon="icons/mob/Human_face_m.dmi"
                    dmIconState="hair_emo_s"
                    color="rgb(0, 100, 100)"
                  />
                }
                onClick={() => setShowHairPopup(!showHairPopup)}
              >
                Emo
              </ImageButton>
              <ImageButton
                dmIcon="not_a_real_icon.dmi"
                dmIconState="equally_fake_icon_state"
                dmFallback={
                  <ColorizedImage
                    dmIcon="icons/mob/Human_face_m.dmi"
                    dmIconState="hair_emo_s"
                    color="rgb(0, 100, 100)"
                  />
                }
                onClick={() => setShowHairPopup(!showHairPopup)}
              >
                Emo
              </ImageButton>
              <ImageButton
                dmIcon="not_a_real_icon.dmi"
                dmIconState="equally_fake_icon_state"
                dmFallback={
                  <ColorizedImage
                    dmIcon="icons/mob/Human_face_m.dmi"
                    dmIconState="hair_emo_s"
                    color="rgb(0, 100, 100)"
                  />
                }
                onClick={() => setShowHairPopup(!showHairPopup)}
              >
                Emo
              </ImageButton>
              <ImageButton
                dmIcon="not_a_real_icon.dmi"
                dmIconState="equally_fake_icon_state"
                dmFallback={
                  <ColorizedImage
                    dmIcon="icons/mob/Human_face_m.dmi"
                    dmIconState="hair_emo_s"
                    color="rgb(0, 100, 100)"
                  />
                }
                onClick={() => setShowHairPopup(!showHairPopup)}
              >
                Emo
              </ImageButton>
              <ImageButton
                dmIcon="not_a_real_icon.dmi"
                dmIconState="equally_fake_icon_state"
                dmFallback={
                  <ColorizedImage
                    dmIcon="icons/mob/Human_face_m.dmi"
                    dmIconState="hair_emo_s"
                    color="rgb(0, 100, 100)"
                  />
                }
                onClick={() => setShowHairPopup(!showHairPopup)}
              >
                Emo
              </ImageButton>
              <ImageButton
                dmIcon="not_a_real_icon.dmi"
                dmIconState="equally_fake_icon_state"
                dmFallback={
                  <ColorizedImage
                    dmIcon="icons/mob/Human_face_m.dmi"
                    dmIconState="hair_emo_s"
                    color="rgb(0, 100, 100)"
                  />
                }
                onClick={() => setShowHairPopup(!showHairPopup)}
              >
                Emo
              </ImageButton>
              <ImageButton
                dmIcon="not_a_real_icon.dmi"
                dmIconState="equally_fake_icon_state"
                dmFallback={
                  <ColorizedImage
                    dmIcon="icons/mob/Human_face_m.dmi"
                    dmIconState="hair_emo_s"
                    color="rgb(0, 100, 100)"
                  />
                }
                onClick={() => setShowHairPopup(!showHairPopup)}
              >
                Emo
              </ImageButton>
              <ImageButton
                dmIcon="not_a_real_icon.dmi"
                dmIconState="equally_fake_icon_state"
                dmFallback={
                  <ColorizedImage
                    dmIcon="icons/mob/Human_face_m.dmi"
                    dmIconState="hair_emo_s"
                    color="rgb(0, 100, 100)"
                  />
                }
                onClick={() => setShowHairPopup(!showHairPopup)}
              >
                Emo
              </ImageButton>
              <ImageButton
                dmIcon="not_a_real_icon.dmi"
                dmIconState="equally_fake_icon_state"
                dmFallback={
                  <ColorizedImage
                    dmIcon="icons/mob/Human_face_m.dmi"
                    dmIconState="hair_emo_s"
                    color="rgb(0, 100, 100)"
                  />
                }
                onClick={() => setShowHairPopup(!showHairPopup)}
              >
                Emo
              </ImageButton>
              <ImageButton
                dmIcon="not_a_real_icon.dmi"
                dmIconState="equally_fake_icon_state"
                dmFallback={
                  <ColorizedImage
                    dmIcon="icons/mob/Human_face_m.dmi"
                    dmIconState="hair_emo_s"
                    color="rgb(0, 100, 100)"
                  />
                }
                onClick={() => setShowHairPopup(!showHairPopup)}
              >
                Emo
              </ImageButton>
              <ImageButton
                dmIcon="not_a_real_icon.dmi"
                dmIconState="equally_fake_icon_state"
                dmFallback={
                  <ColorizedImage
                    dmIcon="icons/mob/Human_face_m.dmi"
                    dmIconState="hair_emo_s"
                    color="rgb(0, 100, 100)"
                  />
                }
                onClick={() => setShowHairPopup(!showHairPopup)}
              >
                Emo
              </ImageButton>
              <ImageButton
                dmIcon="not_a_real_icon.dmi"
                dmIconState="equally_fake_icon_state"
                dmFallback={
                  <ColorizedImage
                    dmIcon="icons/mob/Human_face_m.dmi"
                    dmIconState="hair_emo_s"
                    color="rgb(0, 100, 100)"
                  />
                }
                onClick={() => setShowHairPopup(!showHairPopup)}
              >
                Emo
              </ImageButton>
              <ImageButton
                dmIcon="not_a_real_icon.dmi"
                dmIconState="equally_fake_icon_state"
                dmFallback={
                  <ColorizedImage
                    dmIcon="icons/mob/Human_face_m.dmi"
                    dmIconState="hair_emo_s"
                    color="rgb(0, 100, 100)"
                  />
                }
                onClick={() => setShowHairPopup(!showHairPopup)}
              >
                Emo
              </ImageButton>
              <ImageButton
                dmIcon="not_a_real_icon.dmi"
                dmIconState="equally_fake_icon_state"
                dmFallback={
                  <ColorizedImage
                    dmIcon="icons/mob/Human_face_m.dmi"
                    dmIconState="hair_emo_s"
                    color="rgb(0, 100, 100)"
                  />
                }
                onClick={() => setShowHairPopup(!showHairPopup)}
              >
                Emo
              </ImageButton>
              <ImageButton
                dmIcon="not_a_real_icon.dmi"
                dmIconState="equally_fake_icon_state"
                dmFallback={
                  <ColorizedImage
                    dmIcon="icons/mob/Human_face_m.dmi"
                    dmIconState="hair_emo_s"
                    color="rgb(0, 100, 100)"
                  />
                }
                onClick={() => setShowHairPopup(!showHairPopup)}
              >
                Emo
              </ImageButton>
              <ImageButton
                dmIcon="not_a_real_icon.dmi"
                dmIconState="equally_fake_icon_state"
                dmFallback={
                  <ColorizedImage
                    dmIcon="icons/mob/Human_face_m.dmi"
                    dmIconState="hair_emo_s"
                    color="rgb(0, 100, 100)"
                  />
                }
                onClick={() => setShowHairPopup(!showHairPopup)}
              >
                Emo
              </ImageButton>
              <ImageButton
                dmIcon="not_a_real_icon.dmi"
                dmIconState="equally_fake_icon_state"
                dmFallback={
                  <ColorizedImage
                    dmIcon="icons/mob/Human_face_m.dmi"
                    dmIconState="hair_emo_s"
                    color="rgb(0, 100, 100)"
                  />
                }
                onClick={() => setShowHairPopup(!showHairPopup)}
              >
                Emo
              </ImageButton>
              <ImageButton
                dmIcon="not_a_real_icon.dmi"
                dmIconState="equally_fake_icon_state"
                dmFallback={
                  <ColorizedImage
                    dmIcon="icons/mob/Human_face_m.dmi"
                    dmIconState="hair_emo_s"
                    color="rgb(0, 100, 100)"
                  />
                }
                onClick={() => setShowHairPopup(!showHairPopup)}
              >
                Emo
              </ImageButton>
              <ImageButton
                dmIcon="not_a_real_icon.dmi"
                dmIconState="equally_fake_icon_state"
                dmFallback={
                  <ColorizedImage
                    dmIcon="icons/mob/Human_face_m.dmi"
                    dmIconState="hair_emo_s"
                    color="rgb(0, 100, 100)"
                  />
                }
                onClick={() => setShowHairPopup(!showHairPopup)}
              >
                Emo
              </ImageButton>
            </Stack.Item>
          </Stack>
        </Dimmer>
      )}
    </Section>
  );
};

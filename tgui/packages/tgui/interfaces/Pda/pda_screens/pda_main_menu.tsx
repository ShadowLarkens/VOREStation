import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  Icon,
  ImageButton,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';
import { classes, type BooleanLike } from 'tgui-core/react';
import { CustomImageButton } from 'tgui/interfaces/PreferencesMenu/bay_prefs/helper_components';

type Data = {
  owner: string;
  ownjob: string;
  idInserted: boolean;
  categories: string[];
  apps: Record<string, App>[];
  pai: BooleanLike;
  notifying: Record<string | number, BooleanLike>;
};

type App = {
  name: string;
  icon: string;
  notify_icon: string;
  ref: string;
};

const specialIconColors = {
  'Enable Flashlight': 'green',
  'Disable Flashlight': 'red',
};

export const pda_main_menu = (props) => {
  const { act, data } = useBackend<Data>();

  const [showTransition, setShowTransition] = useState('');
  const [showPopup, setShowPopup] = useState<string | null>(null);
  const [fadingOut, setFadingOut] = useState(false);

  const startProgram = (program: App) => {
    if (
      program.name.startsWith('Enable') ||
      program.name.startsWith('Disable')
    ) {
      // Special case, instant
      act('StartProgram', { program: program.ref });
      return;
    }

    setShowTransition(program.icon);

    setTimeout(() => {
      setShowTransition('');
      act('StartProgram', { program: program.ref });
    }, 200);
  };

  const closePopup = () => {
    setFadingOut(true);

    setTimeout(() => {
      setFadingOut(false);
      setShowPopup(null);
    }, 200);
  };

  const { owner, ownjob, idInserted, categories, pai, notifying, apps } = data;

  return (
    <>
      {showTransition ? (
        <Box className="Pda__Transition">
          <Icon name={showTransition} size={4} />
        </Box>
      ) : null}
      {showPopup ? (
        <Box
          className={classes([
            'Pda__Folder',
            fadingOut ? 'Pda__FadeOut' : null,
          ])}
          onClick={() => closePopup()}
        >
          <Apps
            apps={apps[showPopup]}
            name={showPopup}
            startProgram={startProgram}
          />
        </Box>
      ) : null}
      <Box>
        <LabeledList>
          <LabeledList.Item label="Owner" color="average">
            {owner}, {ownjob}
          </LabeledList.Item>
          <LabeledList.Item label="ID">
            <Button
              icon="sync"
              disabled={!idInserted}
              onClick={() => act('UpdateInfo')}
            >
              Update PDA Info
            </Button>
          </LabeledList.Item>
        </LabeledList>
      </Box>
      {!!pai && (
        <Section title="pAI">
          <Button fluid icon="cog" onClick={() => act('pai', { option: 1 })}>
            Configuration
          </Button>
          <Button fluid icon="eject" onClick={() => act('pai', { option: 2 })}>
            Eject pAI
          </Button>
        </Section>
      )}
      <Box className="Pda__AppList" mt={4}>
        {categories.map((name) => (
          <Stack align="center" justify="center">
            <Stack.Item>
              <CustomImageButton
                image={
                  <Box height="64px">
                    <Box width="80px" className="Pda__AppList">
                      {apps[name].map((app) => (
                        <Icon
                          name={
                            app.ref in notifying ? app.notify_icon : app.icon
                          }
                          size={1.2}
                          color={
                            specialIconColors[app.name] ||
                            (app.ref in notifying ? 'red' : 'transparent')
                          }
                        />
                      ))}
                    </Box>
                  </Box>
                }
                imageSize={80}
                onClick={() => setShowPopup(name)}
              >
                {name}
              </CustomImageButton>
            </Stack.Item>
          </Stack>
        ))}
      </Box>
    </>
  );
};

const Apps = (props: {
  apps: App[];
  name: string;
  startProgram: (app: App) => void;
}) => {
  const { data } = useBackend<Data>();
  const { notifying } = data;
  const { apps, name, startProgram } = props;

  return (
    <Section fill>
      <Stack fill vertical width="80vw" align="center" justify="center">
        <Stack.Item grow />
        <Stack.Item textAlign="center" fontSize={2}>
          {name}
        </Stack.Item>
        <Stack.Item grow />
        <Stack.Item
          className="Pda__Folder__Inner"
          onClick={(event) => {
            // disable the outer click-off
            event.stopPropagation();
          }}
        >
          <Box pt={1} pb={1}>
            {(apps || []).map((app: App) => (
              <Stack align="center" justify="center">
                <Stack.Item>
                  <ImageButton
                    key={app.ref}
                    fallbackIcon={
                      app.ref in notifying ? app.notify_icon : app.icon
                    }
                    color={
                      specialIconColors[app.name] ||
                      (app.ref in notifying ? 'red' : 'transparent')
                    }
                    onClick={() => startProgram(app)}
                    imageSize={70}
                  >
                    <Box preserveWhitespace>
                      {app.name.replaceAll(' ', '\n')}
                    </Box>
                  </ImageButton>
                </Stack.Item>
              </Stack>
            ))}
          </Box>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

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
import { PDAData } from '..';

type Data = {
  categories: string[];
  apps: Record<string, App[]>;
  pai: BooleanLike;
} & PDAData;

type App = {
  name: string;
  icon: string;
  notify_icon: string;
  notifying: BooleanLike;
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

  const { owner, ownjob, idInserted, idLink, pai, apps } = data;

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
          <AppsPopup
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
              icon="eject"
              color="transparent"
              onClick={() => act('Authenticate')}
              disabled={!idInserted}
            >
              {idInserted ? idLink : 'No ID Inserted'}
            </Button>
            <Button
              icon="sync"
              disabled={!idInserted}
              onClick={() => act('UpdateInfo')}
            >
              Sync ID
            </Button>
          </LabeledList.Item>
        </LabeledList>
      </Box>
      {pai ? (
        <Section title="pAI">
          <Button fluid icon="cog" onClick={() => act('pai', { option: 1 })}>
            Configuration
          </Button>
          <Button fluid icon="eject" onClick={() => act('pai', { option: 2 })}>
            Eject pAI
          </Button>
        </Section>
      ) : null}
      <AppList startProgram={startProgram} setShowPopup={setShowPopup} />
    </>
  );
};

const AppList = (props: {
  startProgram: (program: App) => void;
  setShowPopup: React.Dispatch<React.SetStateAction<string | null>>;
}) => {
  const { data } = useBackend<Data>();
  const { categories, apps } = data;
  const { startProgram, setShowPopup } = props;

  return (
    <Box className="Pda__AppList" mt={4}>
      {categories.map((name) => (
        <Category
          apps={apps[name]}
          name={name}
          key={name}
          startProgram={startProgram}
          setShowPopup={setShowPopup}
        />
      ))}
    </Box>
  );
};

const Category = (props: {
  apps: App[];
  name: string;
  startProgram: (app: App) => void;
  setShowPopup: React.Dispatch<React.SetStateAction<string | null>>;
}) => {
  const { apps, name, setShowPopup, startProgram } = props;
  if (apps.length === 1) {
    const app = apps[0];
    return (
      <AppLaunchButton app={app} startProgram={startProgram} key={app.ref} />
    );
  } else if (name === 'General') {
    return (
      <>
        {apps.map((app) => (
          <AppLaunchButton
            app={app}
            startProgram={startProgram}
            key={app.ref}
          />
        ))}
      </>
    );
  } else {
    return (
      <Stack align="center" justify="center">
        <Stack.Item>
          <CustomImageButton
            image={
              <Box height="64px">
                <Box width="80px" className="Pda__AppList">
                  {apps.map((app) => (
                    <Icon
                      name={app.notifying ? app.notify_icon : app.icon}
                      key={app.ref}
                      size={1.2}
                      color={
                        specialIconColors[app.name] ||
                        (app.notifying ? 'red' : 'transparent')
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
    );
  }
};

const AppsPopup = (props: {
  apps: App[];
  name: string;
  startProgram: (app: App) => void;
}) => {
  const { apps, name, startProgram } = props;

  return (
    <Section fill>
      <Stack fill vertical width="80vw" align="center" justify="center">
        <Stack.Item grow />
        <Stack.Item
          textAlign="center"
          fontSize={2}
          style={{ userSelect: 'none' }}
        >
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
              <AppLaunchButton
                app={app}
                startProgram={startProgram}
                key={app.ref}
              />
            ))}
          </Box>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const AppLaunchButton = (props: {
  app: App;
  startProgram: (program: App) => void;
}) => {
  const { app, startProgram } = props;
  return (
    <Stack align="center" justify="center">
      <Stack.Item>
        <ImageButton
          key={app.ref}
          fallbackIcon={app.notifying ? app.notify_icon : app.icon}
          color={
            specialIconColors[app.name] ||
            (app.notifying ? 'red' : 'transparent')
          }
          onClick={() => startProgram(app)}
          imageSize={70}
        >
          <Box preserveWhitespace>{app.name.replaceAll(' ', '\n')}</Box>
        </ImageButton>
      </Stack.Item>
    </Stack>
  );
};

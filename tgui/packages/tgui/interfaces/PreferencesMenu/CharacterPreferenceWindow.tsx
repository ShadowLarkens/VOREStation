import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import { Window } from 'tgui/layouts';
import {
  Button,
  ByondUi,
  Input,
  LabeledList,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

enum Menu {
  Character = 1,
}

type Data = {
  character_preview_view: string;
  character_preferences: {
    misc: Record<string, any>;
  };
};

export const CharacterPreferenceWindow = (props) => {
  const { act, data } = useBackend();

  const [menu, setMenu] = useState(Menu.Character);

  return (
    <Window title="Character Preferences" width={920} height={770}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                selected={menu === Menu.Character}
                onClick={() => setMenu(Menu.Character)}
              >
                Character
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {menu === Menu.Character && <Character />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const Character = (props) => {
  const { act, data } = useBackend<Data>();

  return (
    <Section fill>
      <Stack fill align="center" justify="center">
        <Stack.Item grow p={1}>
          <Section title="Basics">
            <Stack>
              <Stack.Item grow>
                <Input
                  value={data.character_preferences.misc['real_name']}
                  fluid
                />
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon="dice"
                  tooltip="Randomize"
                  tooltipPosition="top-end"
                />
              </Stack.Item>
            </Stack>
            <LabeledList>
              <LabeledList.Item label="Always Random Name">
                <Button.Checkbox
                  checked={
                    data.character_preferences.misc['name_is_always_random']
                  }
                  selected={
                    data.character_preferences.misc['name_is_always_random']
                  }
                >
                  {data.character_preferences.misc['name_is_always_random']
                    ? 'Yes'
                    : 'No'}
                </Button.Checkbox>
              </LabeledList.Item>
              <LabeledList.Item label="Nickname">
                <Input
                  fluid
                  value={data.character_preferences.misc['nickname']}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Biological Sex">
                {data.character_preferences.misc['gender']}
              </LabeledList.Item>
              <LabeledList.Item label="Pronouns">
                {data.character_preferences.misc['id_gender']}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Stack.Item>
        <Stack.Item>
          <ByondUi
            width="192px"
            height="512px"
            params={{
              id: data.character_preview_view,
              type: 'map',
            }}
          />
        </Stack.Item>
        <Stack.Item grow p={1}>
          Right
        </Stack.Item>
      </Stack>
    </Section>
  );
};

import { useBackend } from 'tgui/backend';
import { Window } from 'tgui/layouts';
import { Box, Button, ByondUi, Section, Stack } from 'tgui-core/components';

import { BayPrefsEntryPoint } from './bay_prefs';
import { LegacyStatic } from './bay_prefs/data';

type Data = {
  header: string;
  content: string;
  categories: string[];
  selected_category: string;
  legacy_static: LegacyStatic;
};

export const CharacterPreferenceWindow = (props) => {
  const { act, data } = useBackend<Data>();

  const { header, content, categories, selected_category } = data;

  return (
    <Window width={1000} height={800}>
      <Window.Content>
        <Stack height="100%">
          <Stack.Item
            basis="80%"
            className="PreferencesMenu__OldStyle"
            position="relative"
          >
            <center>
              <Box>
                <Button onClick={() => act('load')}>Load slot</Button>
                <Button onClick={() => act('save')}>Save slot</Button>
                <Button onClick={() => act('reload')}>Reload slot</Button>
                <Button onClick={() => act('resetslot')}>Reset slot</Button>
                <Button onClick={() => act('copy')}>Copy slot</Button>
              </Box>
              <Box>
                {categories.map((category) => (
                  <Button
                    key={category}
                    selected={category === selected_category}
                    onClick={() => act('switch_category', { category })}
                  >
                    {category}
                  </Button>
                ))}
                <Button onClick={() => act('game_prefs')}>Game Options</Button>
              </Box>
              <Box position="absolute" top={0} right={0}>
                <Button
                  icon="refresh"
                  onClick={() => act('refresh_character_preview')}
                  tooltip="Refresh Preview"
                  tooltipPosition="bottom-end"
                />
              </Box>
            </center>
            <Stack vertical fill height="92%">
              <Stack.Item grow>
                <Section fill scrollable mt={1}>
                  {/* eslint-disable-next-line react/no-danger */}
                  <div dangerouslySetInnerHTML={{ __html: content }} />
                </Section>
              </Stack.Item>
              <Stack.Item grow>
                <BayPrefsEntryPoint
                  type={selected_category}
                  static_data={data.legacy_static}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item grow>
            <ByondUi
              params={{ id: 'character_preview_map', type: 'map' }}
              height="100%"
            />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

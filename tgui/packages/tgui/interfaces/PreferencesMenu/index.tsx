import { useBackend } from '../../backend';
import { Box, Button, Section, Stack } from '../../components';
import { Window } from '../../layouts';
import { General } from './categories/General';
import { AllCategoryNames, UIData } from './types';

export const PreferencesMenu = (props) => {
  const { act, data } = useBackend<UIData>();

  return (
    <Window height={800} width={1000}>
      <Window.Content>
        <Stack fill>
          <Stack.Item grow>
            <Stack vertical fill>
              <Stack.Item>
                <Section textAlign="center">
                  <Box>
                    Slot - <Button>Load Slot</Button> -{' '}
                    <Button>Save Slot</Button> - <Button>Reload slot</Button> -{' '}
                    <Button>Reset Slot</Button> - <Button>Copy Slot</Button>
                  </Box>
                  <Box>
                    {data.player_setup.categories.map((category) => (
                      <Button
                        key={category.ref}
                        selected={
                          category.name ===
                          data.player_setup.selected_category?.name
                        }
                        onClick={() =>
                          act('set_category', { category: category.ref })
                        }
                      >
                        {category.name}
                      </Button>
                    ))}
                  </Box>
                </Section>
              </Stack.Item>
              <Stack.Item grow>
                <PreferenceContent />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item width="200px">
            <Section fill>Preview Goes Here</Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const PreferenceContent = (props) => {
  const { act, data } = useBackend<UIData>();
  const { player_setup } = data;

  switch (player_setup.selected_category?.name) {
    case AllCategoryNames.General: {
      return <General data={player_setup.selected_category} />;
    }
    default: {
      return (
        <Section fill title="Error">
          No category selected.
        </Section>
      );
    }
  }
};

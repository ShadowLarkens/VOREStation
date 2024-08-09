import { Box, Section, Stack } from 'tgui/components';

import { ServerData } from '../../pref_json_types';
import { ServerPreferencesFetcher } from '../../ServerPreferencesFetcher';
import { PlayerSetupGroup, PlayerSetupItem } from '../../types';
import { BasicCategory, BasicItem } from './01_basic';
import { LanguageCategory, LanguageItem } from './02_language';

enum ItemNames {
  Basic = 'Basic',
  Language = 'Language',
  Body = 'Body',
  Clothing = 'Clothing',
  Background = 'Background',
  Flavor = 'Flavor',
}

const GeneralItem = (props: {
  item: PlayerSetupItem;
  serverData: ServerData;
}) => {
  const { item, serverData } = props;
  let itemData = serverData.categories['General'].items[item.name];
  switch (item.name) {
    case ItemNames.Basic: {
      return <BasicItem data={item as BasicCategory} serverData={itemData} />;
    }
    case ItemNames.Language: {
      return <LanguageItem data={item as LanguageCategory} />;
    }
    default: {
      return <Box mb={2}>Unrecognized Item: {item.name}</Box>;
    }
  }
};

export const General = (props: { data: PlayerSetupGroup }) => {
  const { data } = props;

  const half = Math.ceil(data.items.length / 2);
  const firstHalf = data.items.slice(0, half);
  const secondHalf = data.items.slice(half);

  return (
    <Section title="General" fill scrollable>
      <ServerPreferencesFetcher
        render={(serverData) => {
          if (!serverData) {
            return <Box>Loading...</Box>;
          }

          return (
            <Stack>
              <Stack.Item grow>
                {firstHalf.map((item) => (
                  <GeneralItem
                    key={item.ref}
                    item={item}
                    serverData={serverData}
                  />
                ))}
              </Stack.Item>
              <Stack.Item grow>
                {secondHalf.map((item) => (
                  <GeneralItem
                    key={item.ref}
                    item={item}
                    serverData={serverData}
                  />
                ))}
              </Stack.Item>
            </Stack>
          );
        }}
      />
    </Section>
  );
};

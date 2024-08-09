import { capitalize } from 'common/string';

import { useBackend } from '../../../backend';
import {
  Box,
  Button,
  Dropdown,
  Input,
  LabeledList,
  NumberInput,
  Section,
  Stack,
} from '../../../components';
import { ServerData } from '../pref_json_types';
import { ServerPreferencesFetcher } from '../ServerPreferencesFetcher';
import { PlayerSetupGroup, PlayerSetupItem } from '../types';

enum ItemNames {
  Basic = 'Basic',
}

type BasicCategory = PlayerSetupItem & {
  real_name: string;
  be_random_name: boolean;
  nickname: string;
  biological_gender: string;
  identifying_gender: string;
  age: number;
  bday_month: number;
  bday_day: number;
  bday_announce: boolean;
  spawnpoint: string;
  available_biological_genders: string[];
  min_age: number;
  max_age: number;
};

type BasicCategoryServer = {
  available_identifying_genders: string[];
  allow_metadata: boolean;
  spawntypes: Record<string, string>;
  max_name_len: number;
};

const BasicItem = (props: {
  data: BasicCategory;
  serverData: BasicCategoryServer;
}) => {
  const { act } = useBackend();
  const { data, serverData } = props;
  return (
    <Box mb={2}>
      <LabeledList>
        <LabeledList.Item label="Name">
          <Input
            fluid
            onChange={(e, name) => act('set_real_name', { name })}
            value={data.real_name}
            maxLength={serverData.max_name_len}
          />
        </LabeledList.Item>
        <LabeledList.Item>
          <Button>Randomize Name</Button>
        </LabeledList.Item>
        <LabeledList.Item>
          <Button.Checkbox
            color=""
            checked={data.be_random_name}
            selected={data.be_random_name}
          >
            Always Random Name
          </Button.Checkbox>
        </LabeledList.Item>
        <LabeledList.Item label="Nickname" buttons={<Button icon="trash" />}>
          <Input
            fluid
            onChange={(e, name) => act('set_nickname', { name })}
            value={data.nickname}
            maxLength={serverData.max_name_len}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Biological Sex">
          <Dropdown
            options={data.available_biological_genders.map((value) => ({
              value,
              displayText: capitalize(value),
            }))}
            displayText={capitalize(data.biological_gender)}
            selected={data.biological_gender}
            onSelected={(gender) => act('set_bio_gender', { gender })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Pronouns">
          <Dropdown
            options={serverData.available_identifying_genders.map((value) => ({
              value,
              displayText: capitalize(value),
            }))}
            displayText={capitalize(data.identifying_gender)}
            selected={data.identifying_gender}
            onSelected={(gender) => act('set_ident_gender', { gender })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Age">
          <NumberInput
            value={data.age}
            minValue={data.min_age}
            maxValue={data.max_age}
            step={1}
          />
          <Box inline ml={1} mr={1} color="label">
            Birthday:
          </Box>
          <NumberInput
            value={data.bday_month}
            minValue={1}
            maxValue={12}
            step={1}
          />{' '}
          /{' '}
          <NumberInput
            value={data.bday_day}
            minValue={1}
            maxValue={31}
            step={1}
          />
          <Button.Checkbox
            ml={6}
            checked={data.bday_announce}
            selected={data.bday_announce}
          >
            Announce?
          </Button.Checkbox>
        </LabeledList.Item>
        <LabeledList.Item label="Spawn Point">
          <Dropdown
            options={Object.keys(serverData.spawntypes)}
            selected={data.spawnpoint}
            onSelected={(spawnpoint) => act('set_spawnpoint', { spawnpoint })}
          />
        </LabeledList.Item>
        {!!serverData.allow_metadata && (
          <LabeledList.Item label="OOC Notes">
            <Button>Edit</Button>
            <Button>Likes</Button>
            <Button>Dislikes</Button>
          </LabeledList.Item>
        )}
      </LabeledList>
    </Box>
  );
};

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

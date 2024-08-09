import { capitalize } from 'common/string';
import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  Dropdown,
  Input,
  LabeledList,
  NumberInput,
} from 'tgui/components';

import { PlayerSetupItem } from '../../types';

export type BasicCategory = PlayerSetupItem & {
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

export type BasicCategoryServer = {
  available_identifying_genders: string[];
  allow_metadata: boolean;
  spawntypes: Record<string, string>;
  max_name_len: number;
};

function maxDaysForMonth(month: number): number {
  switch (month) {
    case 1:
      return 31;
    case 2:
      return 29;
    case 3:
      return 31;
    case 4:
      return 30;
    case 5:
      return 31;
    case 6:
      return 30;
    case 7:
      return 31;
    case 8:
      return 31;
    case 9:
      return 30;
    case 10:
      return 31;
    case 11:
      return 30;
    case 12:
      return 31;
    default:
      return 0;
  }
}

export const BasicItem = (props: {
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
            autoUpdate
            fluid
            onChange={(e, name) => act('set_real_name', { name })}
            value={data.real_name}
            maxLength={serverData.max_name_len}
          />
        </LabeledList.Item>
        <LabeledList.Item>
          <Button onClick={() => act('randomize_name')}>Randomize Name</Button>
        </LabeledList.Item>
        <LabeledList.Item>
          <Button.Checkbox
            color=""
            checked={data.be_random_name}
            selected={data.be_random_name}
            onClick={() => act('set_be_random_name')}
          >
            Always Random Name
          </Button.Checkbox>
        </LabeledList.Item>
        <LabeledList.Item
          label="Nickname"
          buttons={
            <Button onClick={() => act('clear_nickname')} icon="trash" />
          }
        >
          <Input
            autoUpdate
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
            onChange={(age) => act('set_age', { age })}
          />
          <Box inline ml={1} mr={1} color="label">
            Birthday:
          </Box>
          <NumberInput
            value={data.bday_month}
            minValue={0}
            maxValue={12}
            step={1}
            onChange={(month) => act('set_bday_month', { month })}
          />{' '}
          /{' '}
          <NumberInput
            value={data.bday_day}
            minValue={0}
            maxValue={maxDaysForMonth(data.bday_month)}
            step={1}
            onChange={(day) => act('set_bday_day', { day })}
          />
          <Button.Checkbox
            ml={6}
            checked={data.bday_announce}
            selected={data.bday_announce}
            onClick={() => act('set_bday_announce')}
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
            <Button onClick={() => act('ooc_notes_edit')}>Edit</Button>
            <Button onClick={() => act('ooc_notes_likes')}>Likes</Button>
            <Button onClick={() => act('ooc_notes_dislikes')}>Dislikes</Button>
          </LabeledList.Item>
        )}
      </LabeledList>
    </Box>
  );
};

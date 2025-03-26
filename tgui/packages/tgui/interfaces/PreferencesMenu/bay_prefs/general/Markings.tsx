import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  ColorBox,
  Dimmer,
  Input,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';
import { capitalize } from 'tgui-core/string';

import { GeneralData, GeneralDataConstant, GeneralDataStatic } from '../data';
import { VisiblePopup } from '../General';

const BP_TO_NAME = {
  r_hand: 'right hand',
  l_hand: 'left hand',
  l_arm: 'left arm',
  r_arm: 'right arm',
  l_leg: 'left leg',
  r_leg: 'right leg',
  l_foot: 'left foot',
  r_foot: 'right foot',
};

export const MarkingsPopup = (props: {
  data: GeneralData;
  staticData: GeneralDataStatic;
  serverData: GeneralDataConstant;
  setShow: React.Dispatch<React.SetStateAction<VisiblePopup>>;
}) => {
  const { act } = useBackend();
  const { data, staticData, serverData, setShow } = props;

  const { body_markings } = data;
  const { body_markings: available_body_markings } = serverData;

  const markings = Object.keys(body_markings);

  const [showAddMenu, setShowAddMenu] = useState(false);
  const [showExtra, setShowExtra] = useState('');

  return (
    <Section
      title="Markings"
      fill
      scrollable
      mt={1}
      buttons={
        <>
          <Button icon="plus" color="good" onClick={() => setShowAddMenu(true)}>
            Add Marking
          </Button>
          <Button onClick={() => setShow(VisiblePopup.None)} color="bad">
            Close
          </Button>
        </>
      }
    >
      {markings.length === 0 && <Box>No Markings Selected.</Box>}
      {markings.map((name) => (
        <Stack key={name}>
          <Stack.Item>
            <Button
              color="transparent"
              icon="arrow-up"
              onClick={() => act('marking_up', { marking: name })}
            />
            <Button
              color="transparent"
              icon="arrow-down"
              onClick={() => act('marking_down', { marking: name })}
            />
          </Stack.Item>
          <Stack.Item grow>
            <Button
              fluid
              onClick={() => {
                setShowExtra(name);
              }}
            >
              {name}
            </Button>
          </Stack.Item>
        </Stack>
      ))}
      {!!showExtra && (
        <ExtraWindow
          data={data}
          staticData={staticData}
          serverData={serverData}
          name={showExtra}
          setShow={setShowExtra}
        />
      )}
      {showAddMenu && (
        <AddMarkingWindow
          data={data}
          staticData={staticData}
          serverData={serverData}
          setShow={setShowAddMenu}
        />
      )}
    </Section>
  );
};

export const ExtraWindow = (props: {
  data: GeneralData;
  staticData: GeneralDataStatic;
  serverData: GeneralDataConstant;
  name: string;
  setShow: React.Dispatch<React.SetStateAction<string>>;
}) => {
  const { act } = useBackend();
  const { data, staticData, serverData, name, setShow } = props;
  const { body_markings } = data;
  const { body_markings: available_body_markings } = serverData;

  const our_marking = body_markings[name];
  const our_marking_server = available_body_markings[name];

  if (!our_marking) {
    setShow('');
    return <Dimmer>Error: Invalid marking {name}</Dimmer>;
  }

  return (
    <Dimmer
      style={{
        display: 'block',
        overflowY: 'auto',
        textIndent: 0,
        textAlign: 'center',
        zIndex: 100,
      }}
      height="100%"
      p={1}
    >
      <Section
        fill
        title={name + ' Options'}
        buttons={
          <Button icon="times" color="bad" onClick={() => setShow('')}>
            Close
          </Button>
        }
      >
        <Button
          onClick={() =>
            act('toggle_all_marking_selection', { marking: name, toggle: 1 })
          }
        >
          Enable All
        </Button>
        <Button
          onClick={() =>
            act('toggle_all_marking_selection', { marking: name, toggle: 0 })
          }
        >
          Disable All
        </Button>
        <Button
          onClick={() => act('color_all_marking_selection', { marking: name })}
        >
          Change Color Of All
        </Button>
        <Button
          onClick={() => {
            act('marking_remove', { marking: name });
            setShow('');
          }}
          color="bad"
          icon="trash"
        >
          Delete Marking
        </Button>
        <LabeledList>
          <LabeledList.Item label="Color">
            <Button onClick={() => act('marking_color', { marking: name })}>
              {our_marking.color}
              <ColorBox color={our_marking.color} ml={1} />
            </Button>
          </LabeledList.Item>
          {Object.entries(our_marking)
            .filter(([zone, value]) => typeof value === 'object')
            .map(
              ([zone, value]: [string, { on: BooleanLike; color: string }]) => (
                <LabeledList.Item
                  label={capitalize(BP_TO_NAME[zone] || zone)}
                  key={zone}
                >
                  <Button
                    onClick={() =>
                      act('zone_marking_color', { marking: name, zone })
                    }
                  >
                    {value.color} <ColorBox color={value.color} ml={1} />{' '}
                  </Button>
                  <Button.Checkbox
                    onClick={() =>
                      act('zone_marking_toggle', { marking: name, zone })
                    }
                    checked={value.on}
                    selected={value.on}
                    tooltip={value.on ? 'Disable Part' : 'Enable Part'}
                  />
                </LabeledList.Item>
              ),
            )}
        </LabeledList>
      </Section>
    </Dimmer>
  );
};

export const AddMarkingWindow = (props: {
  data: GeneralData;
  staticData: GeneralDataStatic;
  serverData: GeneralDataConstant;
  setShow: React.Dispatch<React.SetStateAction<boolean>>;
}) => {
  const { act } = useBackend();
  const { data, staticData, serverData, setShow } = props;
  const { body_markings } = serverData;
  const [showList, setShowList] = useState(false);
  const [search, setSearch] = useState('');

  let body_markings_list = Object.entries(body_markings);
  body_markings_list.sort((a, b) => a[0].localeCompare(b[0]));
  if (search !== '') {
    body_markings_list = body_markings_list.filter(([name, data]) =>
      name.toLowerCase().includes(search.toLowerCase()),
    );
  }

  return (
    <Dimmer
      style={{
        display: 'block',
        overflowY: 'auto',
        textIndent: 0,
        textAlign: 'center',
        zIndex: 100,
      }}
      height="100%"
      p={1}
    >
      <Stack fill>
        <Stack.Item>
          <Button icon="times" color="bad" onClick={() => setShow(false)}>
            Close
          </Button>
        </Stack.Item>
        <Stack.Item grow>
          <Stack vertical>
            <Stack.Item>
              <Input
                fluid
                expensive
                onInput={(e, val) => setSearch(val)}
                value={search}
              />
            </Stack.Item>
            <Stack.Item>
              {body_markings_list.map(([name, data]) => (
                <Button
                  fluid
                  key={name}
                  onClick={() => {
                    act('add_marking', { new_marking: name });
                    setShow(false);
                  }}
                >
                  {name}
                </Button>
              ))}
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};

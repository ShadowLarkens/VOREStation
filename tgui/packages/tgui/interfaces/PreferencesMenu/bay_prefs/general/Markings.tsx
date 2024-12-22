import { useState } from 'react';
import { Button, Dimmer, Input, Stack } from 'tgui-core/components';

import { GeneralData, GeneralDataConstant, GeneralDataStatic } from '../data';
import { ColorizedImageButton } from '../helper_components';

export const MarkingsPopup = (props: {
  data: GeneralData;
  staticData: GeneralDataStatic;
  serverData: GeneralDataConstant;
  setShow: React.Dispatch<React.SetStateAction<boolean>>;
}) => {
  const { data, staticData, serverData, setShow } = props;

  const { body_markings } = data;
  const { body_markings: available_body_markings } = serverData;

  const body_markings_with_extra_data = Object.entries(body_markings).map(
    ([name, data]) => ({
      name,
      data,
      serverData: available_body_markings[name],
    }),
  );

  const [showAddMenu, setShowAddMenu] = useState(false);

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
      <Stack vertical>
        <Stack.Item>
          <Button icon="times" color="bad" onClick={() => setShow(false)}>
            Close
          </Button>
          <Button icon="plus" color="good" onClick={() => setShowAddMenu(true)}>
            Add Marking
          </Button>
        </Stack.Item>
        <Stack.Item>
          {body_markings_with_extra_data.map((data) => {
            return (
              <ColorizedImageButton
                key={data.name}
                iconRef={data.serverData.icon}
                iconState={data.serverData.icon_state}
                tooltip={data.name}
                onClick={() => {}}
              >
                {data.name}
              </ColorizedImageButton>
            );
          })}
        </Stack.Item>
      </Stack>
      {showAddMenu && (
        <AddMarkingWindow
          data={data}
          staticData={staticData}
          serverData={serverData}
          setShow={setShowAddMenu}
        />
      )}
    </Dimmer>
  );
};

export const AddMarkingWindow = (props: {
  data: GeneralData;
  staticData: GeneralDataStatic;
  serverData: GeneralDataConstant;
  setShow: React.Dispatch<React.SetStateAction<boolean>>;
}) => {
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
          <Stack vertical>
            <Stack.Item>
              <Button icon="times" color="bad" onClick={() => setShow(false)}>
                Close
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button.Checkbox
                inline
                selected={showList}
                checked={showList}
                onClick={() => setShowList((x) => !x)}
              >
                List Mode
              </Button.Checkbox>
            </Stack.Item>
          </Stack>
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
              {showList
                ? body_markings_list.map(([name, data]) => (
                    <Button fluid key={name}>
                      {name}
                    </Button>
                  ))
                : body_markings_list.map(([name, data]) => (
                    <ColorizedImageButton
                      key={name}
                      iconRef={data.icon}
                      iconState={data.icon_state}
                      tooltip={name}
                      onClick={() => {}}
                    >
                      {name}
                    </ColorizedImageButton>
                  ))}
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};

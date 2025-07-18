import { useBackend } from 'tgui/backend';
import {
  AnimatedNumber,
  Box,
  Button,
  Icon,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';

import { damageTypes, statNames } from './constants';
import type { Data } from './types';

export const CryoContent = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    isOperating,
    hasOccupant,
    occupant,
    cellTemperature,
    cellTemperatureStatus,
    isBeakerLoaded,
  } = data;
  return (
    <>
      <Section
        title="Occupant"
        flexGrow
        buttons={
          <Button
            icon="user-slash"
            onClick={() => act('ejectOccupant')}
            disabled={!hasOccupant}
          >
            Eject
          </Button>
        }
      >
        {hasOccupant ? (
          <LabeledList>
            <LabeledList.Item label="Occupant">
              {occupant.name || 'Unknown'}
            </LabeledList.Item>
            <LabeledList.Item label="Health">
              <ProgressBar
                minValue={0}
                maxValue={1}
                value={occupant.health / occupant.maxHealth}
                color={occupant.health > 0 ? 'good' : 'average'}
              >
                <AnimatedNumber
                  value={occupant.health}
                  format={(value) => toFixed(value)}
                />
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item
              label="Status"
              color={statNames[occupant.stat][0]}
            >
              {statNames[occupant.stat][1]}
            </LabeledList.Item>
            <LabeledList.Item label="Temperature">
              <AnimatedNumber
                value={occupant.bodyTemperature}
                format={(value) => `${toFixed(value)} K`}
              />
            </LabeledList.Item>
            <LabeledList.Divider />
            {damageTypes.map((damageType, i) => (
              <LabeledList.Item key={i} label={damageType.label}>
                <ProgressBar
                  value={occupant[damageType.type] / 100}
                  ranges={{ bad: [0.01, Infinity] }}
                >
                  <AnimatedNumber
                    value={occupant[damageType.type]}
                    format={(value) => toFixed(value)}
                  />
                </ProgressBar>
              </LabeledList.Item>
            ))}
          </LabeledList>
        ) : (
          <Stack height="100%" textAlign="center">
            <Stack.Item grow align="center" color="label">
              <Icon name="user-slash" mb="0.5rem" size={5} />
              <br />
              No occupant detected.
            </Stack.Item>
          </Stack>
        )}
      </Section>
      <Section
        title="Cell"
        buttons={
          <Button
            icon="eject"
            onClick={() => act('ejectBeaker')}
            disabled={!isBeakerLoaded}
          >
            Eject Beaker
          </Button>
        }
      >
        <LabeledList>
          <LabeledList.Item label="Power">
            <Button
              icon="power-off"
              onClick={() => act(isOperating ? 'switchOff' : 'switchOn')}
              selected={isOperating}
            >
              {isOperating ? 'On' : 'Off'}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Temperature" color={cellTemperatureStatus}>
            <AnimatedNumber value={cellTemperature} /> K
          </LabeledList.Item>
          <LabeledList.Item label="Beaker">
            <CryoBeaker />
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </>
  );
};

const CryoBeaker = (props) => {
  const { act, data } = useBackend<Data>();
  const { isBeakerLoaded, beakerLabel, beakerVolume } = data;
  if (isBeakerLoaded) {
    return (
      <>
        {beakerLabel ? beakerLabel : <Box color="average">No label</Box>}
        <Box color={!beakerVolume && 'bad'}>
          {beakerVolume ? (
            <AnimatedNumber
              value={beakerVolume}
              format={(v) => `${toFixed(v)} units remaining`}
            />
          ) : (
            'Beaker is empty'
          )}
        </Box>
      </>
    );
  } else {
    return <Box color="average">No beaker loaded</Box>;
  }
};

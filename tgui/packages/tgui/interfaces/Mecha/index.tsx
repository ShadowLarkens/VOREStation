import { round } from 'common/math';
import { useBackend } from 'tgui/backend';
import { Window } from 'tgui/layouts';
import { Box, Button, LabeledList, Section } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { MechaCanvas } from './MechaCanvas';

export type Data = {
  appearance: string;
  internal_damage: number;
  health: number;
  health_max: number;
  armor: number | null;
  armor_max: number | null;
  hull: number | null;
  hull_max: number | null;
  cell_charge: number | null;
  cell_charge_max: number | null;
  use_internal_tank: BooleanLike;
  tank_pressure: number | null;
  tank_temperature: number | null;
  cabin_pressure: number;
  cabin_temperature: number;
  lights: BooleanLike;
  dna: string | null;
  defence_mode_possible: BooleanLike;
  defence_mode: BooleanLike;
  overload_possible: BooleanLike;
  overload: BooleanLike;
  smoke_possible: BooleanLike;
  smoke_reserve: number | null;
  thrusters_possible: BooleanLike;
  thrusters: BooleanLike;
  cargo: {
    name: string;
    appearance: string;
  }[];
  radio_broadcasting: BooleanLike;
  radio_listening: BooleanLike;
  radio_frequency: number;
  can_disconnect: BooleanLike;
  can_connect: BooleanLike;
  add_req_access: BooleanLike;
  maint_access: BooleanLike;

  MECHA_INT_FIRE: number;
  MECHA_INT_TEMP_CONTROL: number;
  MECHA_INT_SHORT_CIRCUIT: number;
  MECHA_INT_TANK_BREACH: number;
  MECHA_INT_CONTROL_LOST: number;
  WARNING_HIGH_PRESSURE: number;
};

export const Mecha = (props) => {
  const { act } = useBackend();

  return (
    <Window theme="hackerman">
      <Window.Content>
        <MechaCanvas />
        {/* Buttons that go over the canvas */}
        <OverlayButtons />
        <MechaStats />
      </Window.Content>
    </Window>
  );
};

const OverlayButtons = (props) => {
  const { act, data } = useBackend<Data>();

  return (
    <>
      <Button
        position="absolute"
        left={3.7}
        top={10.5}
        color="danger"
        onClick={() => act('eject')}
        fontSize={1.5}
      >
        EJECT
      </Button>
      <Button
        position="absolute"
        left={23}
        top={5}
        fontSize={2}
        icon="lightbulb"
        selected={data.lights}
        tooltip="Toggle Lights"
        tooltipPosition="bottom"
        onClick={() => act('toggle_lights')}
      />
      <Button
        position="absolute"
        left={27.4}
        top={5}
        fontSize={2}
        icon="wind"
        selected={data.use_internal_tank}
        tooltip="Toggle Internal Tank"
        tooltipPosition="bottom"
        onClick={() => act('toggle_internals')}
      />
    </>
  );
};

const InternalDamage = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    internal_damage,
    cabin_pressure,
    WARNING_HIGH_PRESSURE,
    MECHA_INT_CONTROL_LOST,
    MECHA_INT_FIRE,
    MECHA_INT_SHORT_CIRCUIT,
    MECHA_INT_TANK_BREACH,
    MECHA_INT_TEMP_CONTROL,
  } = data;

  return (
    <Box textColor="bad" bold lineHeight={1}>
      {internal_damage & MECHA_INT_FIRE ? (
        <Box mb={1}>INTERNAL FIRE</Box>
      ) : null}
      {internal_damage & MECHA_INT_TEMP_CONTROL ? (
        <Box mb={1}>LIFE SUPPORT SYSTEM MALFUNCTION</Box>
      ) : null}
      {internal_damage & MECHA_INT_TANK_BREACH ? (
        <Box mb={1}>GAS TANK BREACH</Box>
      ) : null}
      {internal_damage & MECHA_INT_CONTROL_LOST ? (
        <Box mb={1}>
          COORDINATE SYSTEM CALIBRATION FAILURE -{' '}
          <Button onClick={() => act('repair_int_control_lost')}>
            Recalibrate
          </Button>
        </Box>
      ) : null}
      {internal_damage & MECHA_INT_SHORT_CIRCUIT ? (
        <Box mb={1}>SHORT CIRCUIT</Box>
      ) : null}
      {cabin_pressure > WARNING_HIGH_PRESSURE ? (
        <Box mb={1}>DANGEROUSLY HIGH CABIN PRESSURE</Box>
      ) : null}
    </Box>
  );
};

const MechaStats = (props) => {
  const { act, data } = useBackend<Data>();

  const {
    use_internal_tank,
    tank_pressure,
    tank_temperature,
    cabin_pressure,
    cabin_temperature,
  } = data;

  return (
    <Section title="Status" className="MechaSection" lineHeight="0.7">
      <InternalDamage />
      <LabeledList>
        <LabeledList.Item label="Air Source" labelColor="#00aa00">
          {use_internal_tank ? (
            <Box color="good">Internal Tank</Box>
          ) : (
            <Box color="average">Environment</Box>
          )}
        </LabeledList.Item>
        <LabeledList.Item label="Airtank Pressure" labelColor="#00aa00">
          {tank_pressure ? tank_pressure + 'kPa' : 'No Tank'}
        </LabeledList.Item>
        <LabeledList.Item label="Airtank Temperature" labelColor="#00aa00">
          {tank_temperature
            ? round(tank_temperature, 2) +
              'K|' +
              round(tank_temperature - 273.15, 2) +
              'C'
            : 'No Tank'}
        </LabeledList.Item>
        <LabeledList.Item label="Cabin Pressure" labelColor="#00aa00">
          {round(cabin_pressure, 2) + 'kPa'}
        </LabeledList.Item>
        <LabeledList.Item label="Cabin Temperature" labelColor="#00aa00">
          {round(cabin_temperature, 2) +
            'K|' +
            round(cabin_temperature - 273.15, 2) +
            'C'}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

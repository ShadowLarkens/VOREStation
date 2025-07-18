import { useBackend } from 'tgui/backend';
import { Box, Button, LabeledList, Section, Stack } from 'tgui-core/components';
import { capitalize, toTitleCase } from 'tgui-core/string';

import type { Data } from './types';

export const RIGSuitModules = (props) => {
  const { act, data } = useBackend<Data>();

  const {
    // Seals disable Modules
    sealed,
    sealing,
    // Currently Selected system
    primarysystem,
    // The actual modules.
    modules,
  } = data;

  if (!sealed || sealing) {
    return (
      <Section title="Modules">
        <Box color="bad">HARDSUIT SYSTEMS OFFLINE</Box>
      </Section>
    );
  }

  return (
    <Section title="Modules">
      <Box color="label" mb="0.2rem" fontSize={1.5}>
        Selected Primary: {capitalize(primarysystem || 'None')}
      </Box>
      {modules?.map((module, i) => (
        <Section
          key={i}
          title={toTitleCase(module.name) + (module.damage ? ' (damaged)' : '')}
          buttons={
            <Stack>
              {module.can_select ? (
                <Stack.Item>
                  <Button
                    selected={module.name === primarysystem}
                    icon="arrow-circle-right"
                    onClick={() =>
                      act('interact_module', {
                        module: module.index,
                        module_mode: 'select',
                      })
                    }
                  >
                    {module.name === primarysystem ? 'Selected' : 'Select'}
                  </Button>
                </Stack.Item>
              ) : (
                ''
              )}
              {module.can_use ? (
                <Stack.Item>
                  <Button
                    icon="arrow-circle-down"
                    onClick={() =>
                      act('interact_module', {
                        module: module.index,
                        module_mode: 'engage',
                      })
                    }
                  >
                    {module.engagestring}
                  </Button>
                </Stack.Item>
              ) : (
                ''
              )}
              {module.can_toggle ? (
                <Stack.Item>
                  <Button
                    selected={module.is_active}
                    icon="arrow-circle-down"
                    onClick={() =>
                      act('interact_module', {
                        module: module.index,
                        module_mode: 'toggle',
                      })
                    }
                  >
                    {module.is_active
                      ? module.deactivatestring
                      : module.activatestring}
                  </Button>
                </Stack.Item>
              ) : (
                ''
              )}
            </Stack>
          }
        >
          {module.damage >= 2 ? (
            <Box color="bad">-- MODULE DESTROYED --</Box>
          ) : (
            <Stack>
              <Stack.Item grow>
                <Box color="average">Engage: {module.engagecost}</Box>
                <Box color="average">Active: {module.activecost}</Box>
                <Box color="average">Passive: {module.passivecost}</Box>
              </Stack.Item>
              <Stack.Item grow>{module.desc}</Stack.Item>
            </Stack>
          )}
          {module.charges ? (
            <Stack.Item>
              <Section title="Module Charges">
                <LabeledList>
                  <LabeledList.Item label="Selected">
                    {capitalize(module.chargetype)}
                  </LabeledList.Item>
                  {module.charges.map((charge, i) => (
                    <LabeledList.Item
                      key={charge.caption}
                      label={capitalize(charge.caption)}
                    >
                      <Button
                        selected={module.realchargetype === charge.index}
                        icon="arrow-right"
                        onClick={() =>
                          act('interact_module', {
                            module: module.index,
                            module_mode: 'select_charge_type',
                            charge_type: charge.index,
                          })
                        }
                      />
                    </LabeledList.Item>
                  ))}
                </LabeledList>
              </Section>
            </Stack.Item>
          ) : (
            ''
          )}
        </Section>
      ))}
    </Section>
  );
};

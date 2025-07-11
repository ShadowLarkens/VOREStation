import { Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import type { localPrefs } from '../types';
import { VoreUserPreferenceItem } from '../VorePanelElements/VoreUserPreferenceItem';

export const VoreUserPreferencesSoulcatcher = (props: {
  soulcatcher_allow_capture: BooleanLike;
  preferences: localPrefs;
}) => {
  const { soulcatcher_allow_capture, preferences } = props;

  return (
    <Section
      title="Soulcatcher Preferences"
      buttons={
        <VoreUserPreferenceItem
          spec={preferences.soulcatcher}
          tooltipPosition="top"
        />
      }
    >
      {soulcatcher_allow_capture ? (
        <Stack wrap="wrap" justify="center">
          <Stack.Item basis="32%">
            <VoreUserPreferenceItem
              spec={preferences.soulcatcher_transfer}
              tooltipPosition="right"
            />
          </Stack.Item>
          <Stack.Item basis="32%" grow>
            <VoreUserPreferenceItem
              spec={preferences.soulcatcher_takeover}
              tooltipPosition="top"
            />
          </Stack.Item>
          <Stack.Item basis="32%">
            <VoreUserPreferenceItem
              spec={preferences.soulcatcher_delete}
              tooltipPosition="left"
            />
          </Stack.Item>
        </Stack>
      ) : (
        ''
      )}
    </Section>
  );
};

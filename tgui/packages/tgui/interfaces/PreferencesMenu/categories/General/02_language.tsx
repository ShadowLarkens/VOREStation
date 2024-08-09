import { useBackend } from '../../../../backend';
import { Box, Button } from '../../../../components';
import { PlayerSetupItem } from '../../types';

export type LanguageCategory = PlayerSetupItem & {
  extra_languages: number;
  alternate_languages: string[];
  language_prefixes: string[];
  preferred_language: string;
  species: string;
  species_lang: string;
  species_default: string;
  num_alternate_languages: number;
};

export const LanguageItem = (props: { data: LanguageCategory }) => {
  const { act } = useBackend();
  const { data } = props;

  const {
    extra_languages,
    alternate_languages,
    language_prefixes,
    preferred_language,
    species_lang,
    species_default,
    num_alternate_languages,
  } = data;

  const secondaries_available =
    (num_alternate_languages || 0) + extra_languages;
  const remaining = secondaries_available - alternate_languages.length;

  return (
    <Box mb={2}>
      <Box bold color="label">
        Languages
      </Box>
      {!!species_lang && (
        <Box mt={0.3}>
          <Box inline bold>
            - {species_lang} -
          </Box>{' '}
          <Button
            compact
            onClick={() => act('set_custom_key', { language: species_lang })}
          >
            Set Custom Key
          </Button>
        </Box>
      )}
      {!!species_default && (
        <Box mt={0.3}>
          <Box inline bold>
            - {species_default} -
          </Box>{' '}
          <Button
            compact
            onClick={() => act('set_custom_key', { language: species_default })}
          >
            Set Custom Key
          </Button>
        </Box>
      )}
      {secondaries_available ? (
        <>
          {alternate_languages.map((val, index) => (
            <Box key={val} mt={0.3}>
              <Box inline bold>
                - {val} -{' '}
              </Box>{' '}
              <Button
                m={0}
                compact
                onClick={() => act('remove_language', { index: index + 1 })}
              >
                Remove
              </Button>{' '}
              -{' '}
              <Button
                compact
                onClick={() => act('set_custom_key', { language: val })}
              >
                Set Custom Key
              </Button>
            </Box>
          ))}
          {remaining > 0 && (
            <Box mt={0.3}>
              -{' '}
              <Button compact onClick={() => act('add_language')}>
                Add
              </Button>{' '}
              ({remaining} remaining)
            </Box>
          )}
        </>
      ) : (
        <Box>- You cannot select any secondary languages.</Box>
      )}
      <Box color="label">Language Keys</Box>
      <Box verticalAlign="middle" mt={0.4}>
        <code>{language_prefixes.join(' ')}</code>
        <Button ml={1} onClick={() => act('change_prefix')} compact>
          Change
        </Button>
        <Button onClick={() => act('reset_prefix')} compact>
          Reset
        </Button>
      </Box>
      <Box>
        <Box color="label" inline>
          Preferred Language:
        </Box>{' '}
        <Button onClick={() => act('pref_lang')}>{preferred_language}</Button>
      </Box>
    </Box>
  );
};

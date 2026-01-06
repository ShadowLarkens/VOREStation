import { useBackend } from 'tgui/backend';
import { Box, Input, Section, Stack } from 'tgui-core/components';

type Data = {
  guesses: number[][]; // Serialized guesses (NERDLE_YES, NERDLE_CLOSE, NERDLE_NO)
  guesses_raw: string[]; // Raw guesses (letters)
  max: number; // Maximum number of guesses
  used_guesses: number; // Number of guesses used
  target_word: string; // Target word for debugging (optional)
};

export const pda_nerdle = (props) => {
  const { act, data } = useBackend<Data>();

  const { guesses, guesses_raw, max, used_guesses, target_word } = data;

  const gameOver = used_guesses >= max || guesses_raw.includes(target_word);
  const getGuessResult = (row: number, col: number) => {
    if (row >= guesses.length || col >= guesses[row].length) {
      return -1;
    }
    return guesses[row][col];
  };
  const getGuessLetter = (row: number, col: number) => {
    if (row >= guesses_raw.length || col >= guesses_raw[row].length) {
      return '';
    }
    return guesses_raw[row][col];
  };
  const getColor = (guess: number, grey: boolean) => {
    if (guess === -1) {
      return grey ? '#3a3a3c' : '';
    } else if (guess == 1) {
      return 'good';
    } else if (guess == 2) {
      return 'average';
    } else {
      return 'bad';
    }
  };

  let rows = [0, 1, 2, 3, 4, 5];
  let cols = [0, 1, 2, 3, 4];

  return (
    <Box>
      <Section title="Nerdle V0.8 - A Bingle Collaboration Product">
        <Box>
          Guess the 5-letter word! You have {max - used_guesses} attempts left.
        </Box>
        {gameOver && (
          <Box color="good" bold>
            {guesses_raw.includes(target_word)
              ? 'You win!'
              : `Nice try! Today's word was ${target_word}`}
          </Box>
        )}
      </Section>
      <Section title="Guesses">
        {rows.map((row) => (
          <Box key={row} className="Pda__Nerdle__Row">
            {cols.map((col) => (
              <Box
                key={col}
                className="Pda__Nerdle__Box"
                backgroundColor={getColor(getGuessResult(row, col), false)}
                style={{
                  border: `2px solid ${getColor(getGuessResult(row, col), true)}`,
                }}
              >
                {getGuessLetter(row, col)}
              </Box>
            ))}
          </Box>
        ))}
        {!gameOver && (
          <Input
            mt={1}
            fluid
            placeholder="Enter your guess"
            onEnter={(value) => act('guess', { lastword: value })}
            fontSize={2}
          />
        )}
      </Section>
    </Box>
  );
};

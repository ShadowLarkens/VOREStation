import { useBackend } from 'tgui/backend';
import { Box, Button, Section, Table } from 'tgui-core/components';

type Data = { note: string; notename: string };

export const pda_notekeeper = (props) => {
  const { act, data } = useBackend<Data>();

  const { note, notename } = data;

  return (
    <Box>
      <Section>
        <Box className="Pda__Notekeeper__Grid">
          <Button icon="sticky-note-o" onClick={() => act('Note1')}>
            Note A
          </Button>
          <Button icon="sticky-note-o" onClick={() => act('Note2')}>
            Note B
          </Button>
          <Button icon="sticky-note-o" onClick={() => act('Note3')}>
            Note C
          </Button>
          <Button icon="sticky-note-o" onClick={() => act('Note4')}>
            Note D
          </Button>
          <Button icon="sticky-note-o" onClick={() => act('Note5')}>
            Note E
          </Button>
          <Button icon="sticky-note-o" onClick={() => act('Note6')}>
            Note F
          </Button>
          <Button icon="sticky-note-o" onClick={() => act('Note7')}>
            Note G
          </Button>
          <Button icon="sticky-note-o" onClick={() => act('Note8')}>
            Note H
          </Button>
          <Button icon="sticky-note-o" onClick={() => act('Note9')}>
            Note I
          </Button>
          <Button icon="sticky-note-o" onClick={() => act('Note10')}>
            Note J
          </Button>
          <Button icon="sticky-note-o" onClick={() => act('Note11')}>
            Note K
          </Button>
          <Button icon="sticky-note-o" onClick={() => act('Note12')}>
            Note L
          </Button>
        </Box>
      </Section>
      <Section title={notename}>
        <Button icon="pen" onClick={() => act('Edit')}>
          Edit Note
        </Button>
        <Button icon="file-word" onClick={() => act('Titleset')}>
          Edit Title
        </Button>
        <Button icon="sticky-note-o" onClick={() => act('Print')}>
          Print Note
        </Button>
      </Section>
      <Section>
        {/** biome-ignore lint/security/noDangerouslySetInnerHtml: Markdown in PDA notes */}
        <div dangerouslySetInnerHTML={{ __html: note }} />
      </Section>
    </Box>
  );
};

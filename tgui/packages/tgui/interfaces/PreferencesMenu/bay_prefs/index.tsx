import { logger } from '../../../logging';
import { General } from './General';

export const BayPrefsEntryPoint = (props: {
  type: string;
  data: LegacyValue;
}) => {
  const { type, data } = props;
  logger.log('Rendering bay prefs ', type);

  switch (type) {
    case 'General':
      return <General data={data as GeneralData} />;
    default: {
      return null;
    }
  }
};

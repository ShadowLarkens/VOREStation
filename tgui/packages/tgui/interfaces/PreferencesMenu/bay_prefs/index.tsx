import { GeneralDataStatic, LegacyStatic } from './data';
import { General } from './General';

export const BayPrefsEntryPoint = (props: {
  type: string;
  static_data: LegacyStatic;
}) => {
  const { type, static_data } = props;

  switch (type) {
    case 'General':
      return <General static_data={static_data as GeneralDataStatic} />;
    default: {
      return null;
    }
  }
};

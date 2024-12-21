import {
  GeneralData,
  GeneralDataStatic,
  LegacyData,
  LegacyStatic,
} from './data';
import { General } from './General';

export const BayPrefsEntryPoint = (props: {
  type: string;
  data: LegacyData;
  staticData: LegacyStatic;
}) => {
  const { type, data, staticData } = props;

  switch (type) {
    case 'General':
      return (
        <General
          data={data as GeneralData}
          staticData={staticData as GeneralDataStatic}
        />
      );
    default: {
      return null;
    }
  }
};

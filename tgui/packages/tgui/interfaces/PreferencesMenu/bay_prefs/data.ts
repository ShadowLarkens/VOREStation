import { BooleanLike } from 'tgui-core/react';

export type GeneralDataStatic = {
  real_name: string;
  be_random_name: BooleanLike;
  nickname: string;
  biological_sex: string;
  identifying_gender: string;
  age: number;
  bday_month: number;
  bday_day: number;
  bday_announce: BooleanLike;
  spawnpoint: string;
  allow_metadata: BooleanLike;
};

export type LegacyStatic = Partial<GeneralDataStatic>;

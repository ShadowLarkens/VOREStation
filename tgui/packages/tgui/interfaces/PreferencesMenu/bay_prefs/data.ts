import { BooleanLike } from 'tgui-core/react';

export type GeneralData = {
  h_style: string;
  r_hair: number;
  g_hair: number;
  b_hair: number;

  f_style: string;
  r_facial: number;
  g_facial: number;
  b_facial: number;
};

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
  available_hair_styles: string[];
  available_facial_styles: string[];
};

export type LegacyData = Partial<GeneralData>;

export type LegacyStatic = Partial<GeneralDataStatic>;

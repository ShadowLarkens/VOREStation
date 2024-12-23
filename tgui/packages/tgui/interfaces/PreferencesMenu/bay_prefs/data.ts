import { BooleanLike } from 'tgui-core/react';

export type BodyMarking = Record<
  string,
  {
    on: BooleanLike;
    color: string;
  }
>;

export type BasicData = {
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
};

export type BodyData = {
  has_hair_color: BooleanLike;

  h_style: string;
  r_hair: number;
  g_hair: number;
  b_hair: number;

  f_style: string;
  r_facial: number;
  g_facial: number;
  b_facial: number;

  grad_style: string;
  r_grad: number;
  g_grad: number;
  b_grad: number;

  ear_style: string | null;
  r_ears: number;
  g_ears: number;
  b_ears: number;

  r_ears2: number;
  g_ears2: number;
  b_ears2: number;

  r_ears3: number;
  g_ears3: number;
  b_ears3: number;

  ear_secondary_style: string | null;
  ear_secondary_colors: string[];

  body_markings: Record<string, BodyMarking>;
};

export type GeneralData = BasicData & BodyData;

export type GeneralDataStatic = {
  allow_metadata: BooleanLike;
  available_hair_styles: string[];
  available_facial_styles: string[];
  available_ear_styles: string[];
};

export type StandardStyle = { name: string; icon: string; icon_state: string };

export type EarStyle = StandardStyle & { type: string };

export type MarkingStyle = StandardStyle & {
  genetic: BooleanLike;
  body_parts: string[];
};

export type GeneralDataConstant = {
  hair_styles: Record<string, StandardStyle>;
  facial_styles: Record<string, StandardStyle>;
  grad_styles: Record<string, StandardStyle>;
  ear_styles: Record<string, EarStyle>;
  body_markings: Record<string, MarkingStyle>;
};

export type LegacyData = Partial<GeneralData>;
export type LegacyStatic = Partial<GeneralDataStatic>;
export type LegacyConstant = Partial<GeneralDataConstant>;

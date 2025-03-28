import { BooleanLike } from 'tgui-core/react';

export type BodyMarking = Record<
  string,
  {
    on: BooleanLike;
    color: string;
  }
> & {
  color: string;
};

export enum Gender {
  Male = 'Male',
  Female = 'Female',
  Neuter = 'Neuter',
  Plural = 'Plural',
}

export type BasicData = {
  real_name: string;
  be_random_name: BooleanLike;
  nickname: string;
  biological_sex: Gender;
  identifying_gender: Gender;
  age: number;
  bday_month: number;
  bday_day: number;
  bday_announce: BooleanLike;
  spawnpoint: string;
};

export type BodyData = {
  has_hair_color: BooleanLike;

  h_style: string;
  hair_color: string;

  f_style: string;
  facial_color: string;

  grad_style: string;
  grad_color: string;

  ear_style: string | null;
  ears_color1: string;
  ears_color2: string;
  ears_color3: string;

  ears_alpha: number;
  ears_alpha2: number;

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
  icon: string;
  icon_state: string;
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

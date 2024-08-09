export type Ref = string;

export enum AllCategoryNames {
  General = 'General',
}

export type PlayerSetupItem = {
  ref: Ref;
  name: string;
};

export type PlayerSetupGroup = {
  ref: Ref;
  name: string;
  items: PlayerSetupItem[];
};

export type PlayerSetupCollection = {
  ref: Ref;
  categories: { name: string; ref: Ref }[];
  selected_category: PlayerSetupGroup | null;
};

export type UIData = {
  player_setup: PlayerSetupCollection;
};

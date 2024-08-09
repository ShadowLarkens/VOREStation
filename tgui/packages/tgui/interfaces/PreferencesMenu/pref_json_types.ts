export type ServerDataCategory = {
  items: Record<string, any>;
};

export type ServerData = {
  categories: Record<string, ServerDataCategory>;
};

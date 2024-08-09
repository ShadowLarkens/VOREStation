import { ReactNode, useEffect, useState } from 'react';

import { resolveAsset } from '../../assets';
import { fetchRetry } from '../../http';
import { ServerData } from './pref_json_types';

export type PreferenceCallback = (data?: ServerData) => ReactNode;

// Store this outside the component - we only want to fetch this once ever for a given UI
let fetchServerData: Promise<ServerData> | undefined;

export const ServerPreferencesFetcher = (props: {
  render: PreferenceCallback;
}) => {
  let [serverData, setServerData] = useState<ServerData>();

  useEffect(() => {
    const populateServerData = async () => {
      if (!fetchServerData) {
        fetchServerData = fetchRetry(resolveAsset('preferences.json')).then(
          (response) => response.json(),
        );
      }

      const data = await fetchServerData;
      setServerData(data);
    };

    populateServerData();
  });

  return props.render(serverData);
};

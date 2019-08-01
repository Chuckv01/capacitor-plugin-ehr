import { WebPlugin } from '@capacitor/core';
import { EhrPluginPlugin } from './definitions';

export class EhrPluginWeb extends WebPlugin implements EhrPluginPlugin {
  constructor() {
    super({
      name: 'EhrPlugin',
      platforms: ['web']
    });
  }

  async echo(options: { value: string }): Promise<{value: string}> {
    console.log('ECHO', options);
    return options;
  }
}

const EhrPlugin = new EhrPluginWeb();

export { EhrPlugin };

import { registerWebPlugin } from '@capacitor/core';
registerWebPlugin(EhrPlugin);

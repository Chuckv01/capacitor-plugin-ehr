declare module "@capacitor/core" {
  interface PluginRegistry {
    EhrPlugin: EhrPluginPlugin;
  }
}

export interface EhrPluginPlugin {
  echo(options: { value: string }): Promise<{value: string}>;
}

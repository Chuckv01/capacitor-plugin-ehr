# capacitor-plugin-ehr
Ionic Capacitor plugin to access iOS Clinical Records (FHIR). iOS only.

## iOS installation

- `npm i capacitor-plugin-ehr && npx cap sync`

## API

- authorize()
- queryClinicalSampleType()
- getRequestStatusForAuthorization()

## Usage

```ts
import { Injectable } from '@angular/core';
import { EhrPlugin, ClinicalRecordAuthorization, HKClinicalRecord, HKClinicalSampleType } from 'capacitor-plugin-ehr';
declare var Capacitor;

@Injectable({
  providedIn: 'root'
})
export class HealthkitService {
  public ehrPlugin: EhrPlugin = Capacitor.Plugins.EhrPlugin as any;

  public async authorize() {
    return this.ehrPlugin.authorize({
      writePermissions: environment.healthKit.writePermissions as [HKClinicalSampleType],
      readPermissions: environment.healthKit.readPermissions as [HKClinicalSampleType]
    });
  }

  public async calculateAuthorizationStatus() {
    return await this.ehrPlugin.getRequestStatusForAuthorization({
      writePermissions: environment.healthKit.writePermissions as [HKClinicalSampleType],
      readPermissions: environment.healthKit.readPermissions as [HKClinicalSampleType]
    });
  }

  public async queryClinicalSampleType(sampleType: HKClinicalSampleType) {
    return this.ehrPlugin.queryClinicalSampleType({ sampleType });
  }
}
```
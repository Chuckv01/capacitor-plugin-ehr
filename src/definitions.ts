declare global {
  interface PluginRegistry {
    EhrPlugin: EhrPlugin;
  }
}

export enum ClinicalRecordAuthorization {
  unknown = 0,
  shouldRequest = 1,
  unnecessary = 2,
}

export type HKClinicalSampleType =
  | 'HKClinicalTypeIdentifierAllergyRecord'
  | 'HKClinicalTypeIdentifierConditionRecord'
  | 'HKClinicalTypeIdentifierImmunizationRecord'
  | 'HKClinicalTypeIdentifierLabResultRecord'
  | 'HKClinicalTypeIdentifierMedicationRecord'
  | 'HKClinicalTypeIdentifierProcedureRecord'
  | 'HKClinicalTypeIdentifierVitalSignRecord';

export interface HKClinicalRecord {
  fhirResource: FHIRResource;
  startDate: string;
  endDate: string;
  uuid: string;
  sourceURL: string;
  metadata?: [string, any];
  displayName: string;
}

export interface FHIRResource {
  data: any;
  sourceURL: string;
  displayName: string;
  identifier: number;
}

export interface EhrPlugin {
  authorize(options: {
    writePermissions: [HKClinicalSampleType],
    readPermissions: [HKClinicalSampleType]
  }): Promise<null>;

  queryClinicalSampleType(options: {
    sampleType: [HKClinicalSampleType]
  }): Promise<[HKClinicalRecord]>;

  getRequestStatusForAuthorization(options: {
    writePermissions: [HKClinicalSampleType],
    readPermissions: [HKClinicalSampleType]
  }): Promise<ClinicalRecordAuthorization>;
}

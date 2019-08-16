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

export type HKObjectType = 
  | 'HKQuantityTypeIdentifierStepCount'
  | 'HKCategoryTypeIdentifierSleepAnalysis'

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
  recorder: any;
}

export interface EhrPlugin {
  authorize(options: {
    writePermissions: [HKClinicalSampleType | HKObjectType],
    readPermissions: [HKClinicalSampleType | HKObjectType]
  }): Promise<null>;

  querySampleType(options: {
    sampleType: HKClinicalSampleType | HKObjectType,
    limit?: number,
    startDate?: Date,
    endDate?: Date
  }): Promise<{records: [HKClinicalRecord]}>;

  querySampleTypeAggregated(options: {
    startDate: Date;
    endDate: Date;
    interval: number;
    quantityType: HKObjectType;
  }): Promise<{
    records: [{
      value: number,
      date: Date
    }];
  }>;

  getRequestStatusForAuthorization(options: {
    writePermissions: [HKClinicalSampleType],
    readPermissions: [HKClinicalSampleType]
  }): Promise<{status: ClinicalRecordAuthorization}>;
}

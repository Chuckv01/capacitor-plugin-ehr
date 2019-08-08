import Foundation
import Capacitor
import HealthKit

var healthStore: HKHealthStore = HKHealthStore();

@objc(EhrPlugin)
public class EhrPlugin: CAPPlugin {
    
    @available(iOS 12.0, *)
    @objc func authorize(_ call: CAPPluginCall) {
        if HKHealthStore.isHealthDataAvailable() {
            let readTypes: Set<HKObjectType> = self.getHKObjectTypes(call, key: "readPermissions")
            let writeTypes: Set<HKObjectType> = self.getHKObjectTypes(call, key: "writePermissions")
            
            healthStore.requestAuthorization(toShare: writeTypes as! Set<HKSampleType>, read: readTypes) { (success, error) in
                if !success {
                    call.reject("Could not get permission")
                    return
                }
                call.resolve();
            }
        } else {
            call.reject("Health data not available")
        }
    }
    
    @available(iOS 12.0, *)
    @objc func getRequestStatusForAuthorization(_ call: CAPPluginCall) {
        let readTypes: Set<HKObjectType> = self.getHKObjectTypes(call, key: "readPermissions")
        let writeTypes: Set<HKObjectType> = self.getHKObjectTypes(call, key: "writePermissions")
        
        healthStore.getRequestStatusForAuthorization(toShare: writeTypes as! Set<HKSampleType>, read: readTypes) { (success, error) in
            call.resolve(["status": success.rawValue]);
        }
    }
    
    @available(iOS 12.0, *)
    @objc func queryClinicalSampleType(_ call: CAPPluginCall) {
        guard let sampleType = call.options["sampleType"] as? String else {
            call.reject("Must provide a sampleType to queryClinicalSampleType")
            return
        }
        
        guard let clinicalType = HKObjectType.clinicalType(forIdentifier:HKClinicalTypeIdentifier(rawValue: sampleType)) else {
            call.reject("Invalid sampleType received")
            return
        }
        
        let query = HKSampleQuery(sampleType: clinicalType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
            
            guard let actualSamples = samples else {
                call.reject("*** An error occurred: \(error?.localizedDescription ?? "nil") ***")
                return
            }
            
            var results: [Any] = []
            
            for sample in (actualSamples as? [HKClinicalRecord])! {
                results.append([
                    "startDate": sample.startDate.description,
                    "endDate": sample.endDate.description,
                    "uuid": sample.uuid.uuidString,
                    "metadata": sample.metadata,
                    "sourceURL": (sample.fhirResource?.sourceURL!.absoluteString)!,
                    "displayName": sample.displayName,
                    "fhirResource": self.toJson(data: sample.fhirResource!.data)
                    ])
            }
            call.resolve(["records": results])
        }
        healthStore.execute(query)
    }
    
    func toJson(data: Data) -> NSDictionary {
        var json: NSDictionary = [:]
        do {
            json = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
        } catch let error {
            print(error)
        }
        return json;
    }
    
    @available(iOS 12.0, *)
    func getHKObjectTypes(_ call: CAPPluginCall, key: String) -> Set<HKObjectType> {
        let sampleTypes = call.options[key]
        var types = Set<HKObjectType>([])
        for type in (sampleTypes as? [String])! {
            let hkObject = self.getHKObjectFromString(type: type);
            if (hkObject !== nil) {
                types.insert(hkObject!)
            }
        }
        return types
    }
    
    @available(iOS 12.0, *)
    func getHKObjectFromString(type: String) -> HKObjectType? {
        var hkType: HKObjectType?;
        print(type)
        
        hkType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: type))
        if (hkType != nil) {
            return hkType!;
        }
        
        hkType = HKObjectType.clinicalType(forIdentifier:HKClinicalTypeIdentifier(rawValue: type))
        if (hkType != nil) {
            return hkType!;
        }
        
        
        hkType = HKObjectType.categoryType(forIdentifier:HKCategoryTypeIdentifier(rawValue: type))
        if (hkType != nil) {
            return hkType!;
        }
        
        return hkType;
    }
}

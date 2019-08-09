import Foundation
import Capacitor
import HealthKit

var healthStore: HKHealthStore = HKHealthStore();

@available(iOS 12.0, *)
@objc(EhrPlugin)
public class EhrPlugin: CAPPlugin {
    
    @objc func authorize(_ call: CAPPluginCall) {
        if HKHealthStore.isHealthDataAvailable() {
            let readTypes = self.getHKSampleTypes(call, key: "readPermissions")
            let writeTypes = self.getHKSampleTypes(call, key: "writePermissions")
            
            healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { (success, error) in
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
    
    @objc func getRequestStatusForAuthorization(_ call: CAPPluginCall) {
        let readTypes = self.getHKSampleTypes(call, key: "readPermissions")
        let writeTypes = self.getHKSampleTypes(call, key: "writePermissions")
        
        healthStore.getRequestStatusForAuthorization(toShare: writeTypes, read: readTypes) { (success, error) in
            call.resolve(["status": success.rawValue]);
        }
    }
    
    @objc func querySampleType(_ call: CAPPluginCall) {
        guard let sampleType = call.options["sampleType"] as? String else {
            call.reject("Must provide a sampleType to queryClinicalSampleType")
            return
        }
        guard let sampleTypeObject = self.getSampleTypeFromString(type: sampleType) else {
            call.reject("Invalid sampleType received")
            return
        }
        
        let limit = call.options["limit"] as? Int
        let startDate = call.options["startDate"] as? Date
        let endDate = call.options["endDate"] as? Date
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        let query = HKSampleQuery(sampleType: sampleTypeObject, predicate: predicate, limit: limit ?? 100, sortDescriptors: nil) { (query, samples, error) in
            
            guard let actualSamples = samples else {
                call.reject("*** An error occurred: \(error?.localizedDescription ?? "nil") ***")
                return
            }
            
            var results: [[String: Any]] = []
            
            for sample in (actualSamples) {
                results.append(self.sampleToDictionary(sampleType: sampleType, sample: sample))
            }
            call.resolve(["records": results])
        }
        healthStore.execute(query)
    }
    
    func sampleToDictionary(sampleType: String, sample: HKObject) -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if sampleType.contains("HKClinicalType") {
            let clinicalSample = sample as! HKClinicalRecord;
            dictionary = [
                "startDate": clinicalSample.startDate.description,
                "endDate": clinicalSample.endDate.description,
                "uuid": clinicalSample.uuid.uuidString,
                "metadata": clinicalSample.metadata ?? "",
                "sourceURL": (clinicalSample.fhirResource?.sourceURL!.absoluteString)!,
                "displayName": clinicalSample.displayName,
                "fhirResource": self.toJson(data: clinicalSample.fhirResource!.data)
            ]
        }
        else if sampleType.contains("HKQuantityType") {
            let quantitySample = sample as! HKQuantitySample;
            dictionary = [
                "quantity": quantitySample.quantity.description,
                "quantityType": quantitySample.quantityType.description,
                "count": quantitySample.count.description,
            ]
        }
        else if sampleType.contains("HKCategoryType") {
            let categorySample = sample as! HKCategorySample;
            dictionary = [
                "value": categorySample.value.description,
                "categoryType": categorySample.categoryType.description
            ]
        }
        return dictionary;
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
    
    func getHKSampleTypes(_ call: CAPPluginCall, key: String) -> Set<HKSampleType> {
        let sampleTypes = call.options[key]
        var types = Set<HKSampleType>([])
        for type in (sampleTypes as? [String])! {
            let hkObject = self.getSampleTypeFromString(type: type);
            if (hkObject !== nil) {
                types.insert(hkObject!)
            }
        }
        return types
    }
    
    func getSampleTypeFromString(type: String) -> HKSampleType? {
        var hkType: HKSampleType?;
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

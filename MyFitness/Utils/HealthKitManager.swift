//
//  HealthKitManager.swift
//  MyFitness
//
//  Created by UMCios on 2023/09/26.
//

import HealthKit

class HealthKitManager {
    
    @Published
    var footsteps: Int = 0
    
    private let healthStore = HKHealthStore()

    init() {
        
    }
    
    // Request authorization to access HealthKit data.
    func authorizeHealthKit() async -> Bool {
        // Check if HealthKit is available on the device.
        guard HKHealthStore.isHealthDataAvailable() else {
            return false
        }
        
        // Set the types of data you want to read from HealthKit.
        let readDataTypes: Set = [HKObjectType.quantityType(forIdentifier: .stepCount)!]
        let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let writeDataTypes: Set = [stepCountType]

        return await withCheckedContinuation { continuation in
            healthStore.requestAuthorization(toShare: writeDataTypes, read: readDataTypes) { success, error in
                if success {
                    self.fetchStepCount()
                    continuation.resume(returning: true)
                } else if let error = error {
                    continuation.resume(returning: false)
                }
            }
        }
        
    }
    
    func fetchStepCount() {
        // Define the step count type.
        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else { return }

        // Get today's date.
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        // Create a query to fetch the step count.
        let query = HKSampleQuery(
            sampleType: stepCountType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: nil
        ) { query, samples, error in
            // Unwrap the samples and calculate the total step count.
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                print("Error fetching step count: \(error?.localizedDescription ?? "")")
                return
            }

            let totalSteps = samples.reduce(0) { total, sample in
                total + Int(sample.quantity.doubleValue(for: .count()))
            }

            print("Total steps today: \(totalSteps)")
        }

        // Execute the query.
        healthStore.execute(query)
    }

}

extension HealthKitManager {
    // Save step count to HealthKit.
    func saveStepCount(ofDate: Date, steps: Int) async -> Bool {
        // Check if the step count type is available.
        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            return false
        }
        
        // Get the current date.
        let now = ofDate
        
        // Get the start and end of the previous day.
        let startOfToday = Calendar.current.startOfDay(for: now)
        let startOfYesterday = Calendar.current.date(byAdding: .day, value: 0, to: startOfToday)!
        let endOfYesterday = Calendar.current.date(byAdding: .day, value: +1, to: startOfToday)!
        
        // Create a new quantity sample.
        let stepCountSample = HKQuantitySample(
            type: stepCountType,
            quantity: HKQuantity(unit: .count(), doubleValue: Double(steps)),
            start: startOfYesterday,
            end: endOfYesterday
        )
        
        return await withCheckedContinuation { continuation in
            // Save the step count sample to the health store.
            healthStore.save(stepCountSample) { success, error in
                if success {
                    continuation.resume(returning: true)
                } else {
                    continuation.resume(returning: false)
                }
            }
        }
    }

}

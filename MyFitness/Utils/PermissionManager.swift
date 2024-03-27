//
//  PermissionManager.swift
//  MyFitness
//
//  Created by UMCios on 2023/05/10.
//

import Foundation
import Photos

class PermissionManager {
    
    static var shared = PermissionManager()
    
    func checkPhotoLibraryPermission() async -> Bool {
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .limited:
            return false
        case .authorized:
            return true
        case .notDetermined:
            let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            switch status {
            case .limited:
                return false
            case .authorized:
                return true
            case .restricted, .denied:
                return false
            default:
                return false
            }
        case .restricted, .denied:
            return false
        default:
            return false
        }
    }
}

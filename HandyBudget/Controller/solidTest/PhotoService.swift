//
//  PhotoService.swift
//  HandyBudget
//
//  Created by Jadson on 21/08/2024.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

struct PhotoService {
    
    func savePhoto(image: UIImage?, onSucess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        
        guard let imageData = image?.jpegData(compressionQuality: 0.4) else { return }
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let storageRef = Storage.storage().reference(forURL: URL_STORAGE_ROOT)
        let storageProfileRef = storageRef.child(STORAGE_PROFILE).child(userID)
        
        let metadata = StorageMetadata()
        metadata.contentType = CONTENT_TYPE
        
        storageProfileRef.putData(imageData, metadata: metadata) { storageMetadata, error in
            if error != nil {
                onError(error!.localizedDescription) //REMOVE LOCALIZED DESCRIPTION
                return
            }
        }
    }
    
    //CHECK THIS WHEN IMPLEMENTING THE EDIT PROFILE
    func editPhoto(imageURL: URL, dict: Dictionary<String, Any>, uid: String) {
        if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
            changeRequest.photoURL = imageURL
            changeRequest.commitChanges { error in
                if let error {
                    print(error.localizedDescription) //CHANGE THIS URGENTLY
                }
            }
        }
        
        var dicTemp = dict
        dicTemp[PROFILE_IMAGE_URL] = imageURL
        Database.database().reference().child(REF_USER).child(uid).updateChildValues(dicTemp)
    }
    
    func downloadPhoto() {
        
    }
    
}

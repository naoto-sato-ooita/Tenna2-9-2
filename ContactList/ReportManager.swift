import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore


final class ReportManager : ObservableObject {
    
    static let shared = ReportManager()
    
    func sendReport(selectedUid : String,reason: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let Ref = Firestore.firestore().collection("CustmerReport").document(currentUserId)
        
        let uid: String = selectedUid
        let reason: String = reason
        
        let documentData: [String : Any] = [
            "uid" : uid,
            "reason" : reason,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        Ref.setData(documentData,merge: true) { error in
            if let error = error { print("Error adding report: \(String(describing: error))") }
            else{ print("Report added with ID") }
        }
    }
}

//
//  RequestManager.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/06/05.
//
import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore


final class RequestManager : ObservableObject {
    
    static let shared = RequestManager()
    @StateObject var friend_manager = FriendManager.shared
    @Published var requestUsers:    [User] = []
    @Published var requestImages:   [String: UIImage] = [:]
    
    
    private let storageURL = Storage.storage().reference(forURL: "gs://glif-c9e53.appspot.com")
    
    //MARK: - 追加
    
    func sendFriendRequest(selectedUserId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let selectUserRef = Firestore.firestore().collection("users").document(selectedUserId)
        selectUserRef.updateData([
            "requestList": FieldValue.arrayUnion([currentUserId])
        ]) { error in
            if let error = error {
                print("Error sending request: \(error)")
            } else {
                print("Request sent to user: \(selectedUserId)")
            }
        }
    }
    
    //MARK: - 削除
    func deleteRequest(selectedUserId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let userRef = Firestore.firestore().collection("users").document(currentUserId)
        
        userRef.updateData([
            "requestList": FieldValue.arrayRemove([selectedUserId])
        ]) { error in
            if let error = error {
                print("Error declining request: \(error)")
            } else {
                self.loadFriendRequests()
            }
        }
    }
    
    //MARK: - 読み込み
    func loadFriendRequests() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let userRef = Firestore.firestore().collection("users").document(currentUserId)
        
        userRef.getDocument { document, error in
            if let document = document, document.exists {
                if let requestIds = document.get("requestList") as? [String] {
                    Task {
                        let fetchedUsers = await self.fetchUsers(with: requestIds)
                        DispatchQueue.main.async { //UIビューの更新はメインスレッドで行う必要があり
                            self.requestUsers = fetchedUsers.filter { !BlockManager.shared.isBlocked(user: $0, targetUserId: currentUserId) }
                        }
                        await self.fetchImpressionImages(for: fetchedUsers)
                    }
                }
            }
        }

    }
    
    //ユーザー読み込み
    func fetchUsers(with ids: [String]) async -> [User] {
        let userRefs = ids.map { Firestore.firestore().collection("users").document($0) }
        var users: [User] = []
        
        for userRef in userRefs {
            do {
                let document = try await userRef.getDocument()
                let user = try document.data(as: User.self)
                users.append(user)
                
            } catch {
                print("Error fetching user: \(error)")
            }
        }
        return users
    }
    //画像の読み込み
    func fetchImpressionImages(for users: [User]) async {
        for user in users {
            if let uid = user.uid {
                if let image = await self.fetchImage(for: uid){
                    DispatchQueue.main.async {
                        self.requestImages[uid] = image
                    }
                }
            }
        }
    }
    //画像の参照先を変更
    func fetchImage(for uid: String) async -> UIImage? {
        let ref = Firestore.firestore().collection("users").document(uid)
        
        do {
            let document = try await ref.getDocument()
            guard let path = document.get("path") as? String else {
                print("No path found in document")
                return nil
            }
            
            let storageRef = storageURL.child(path)
            let data = try await storageRef.getDataAsync(maxSize: 1 * 1024 * 1024)
            
            return UIImage(data: data)
        }
        
        catch {
            print("Download error: \(error)")
            return nil
        }
    }

}

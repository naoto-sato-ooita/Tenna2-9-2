//
//  FriendManager.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/06/05.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore


final class FriendManager : ObservableObject {
    
    static let shared = FriendManager()
    @StateObject var request_manager = RequestManager.shared
    @Published var friendUsers:     [User] = []
    @Published var friendsImages:   [String: UIImage] = [:]
    
    private let storageURL = Storage.storage().reference(forURL: "gs://glif-c9e53.appspot.com")
    
    
    //MARK: - フレンド承認
    func approveFriendRequest(from userId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let friendRef = Firestore.firestore().collection("users").document(userId)
        let userRef = Firestore.firestore().collection("users").document(currentUserId)
        userRef.updateData([
            "friendList": FieldValue.arrayUnion([userId]),
            "requestList": FieldValue.arrayRemove([userId])
        ]) { error in
            if let error = error {
                print("Error approving request: \(error)")
            } else {
                friendRef.updateData([
                    "friendList": FieldValue.arrayUnion([currentUserId])
                ])
                self.request_manager.loadFriendRequests()
                self.loadFriends()
            }
        }
    }
    
    //MARK: - フレンド却下
    func declineFriendRequest(from userId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let userRef = Firestore.firestore().collection("users").document(currentUserId)
        
        userRef.updateData([
            "requestList": FieldValue.arrayRemove([userId])
        ]) { error in
            if let error = error {
                print("Error declining request: \(error)")
            } else {
                self.request_manager.loadFriendRequests()
            }
        }
    }
    
    //MARK: - delete friend
    func deleteFriend(selectedUid: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let userRef = Firestore.firestore().collection("users").document(currentUserId)
        
        userRef.updateData([
            "friendList": FieldValue.arrayRemove([selectedUid])
        ]) { error in
            if let error = error {
                print("Error declining request: \(error)")
            } else {
                self.loadFriends()
            }
        }
    }
    
    
    //Load friend users from Firestore
    func loadFriends() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let userRef = Firestore.firestore().collection("users").document(currentUserId)
        
        userRef.getDocument { document, error in
            if let document = document, document.exists {
                if let friendIds = document.get("friendList") as? [String] {
                    Task {
                        let fetchedUsers = await self.fetchUsers(with: friendIds)
                        DispatchQueue.main.async { //UIビューの更新はメインスレッドで行う必要があるため
                            self.friendUsers = fetchedUsers.filter { !BlockManager.shared.isBlocked(user: $0, targetUserId: currentUserId) }
                        }
                        await self.loadFriendImages(for: fetchedUsers)
                    }
                }
            }
        }
    }
    
    
    //画像読み込み
    func loadFriendImages(for users: [User]) async {
        for user in users {
            if let uid = user.uid {
                if let image = await fetchImage(for: uid){
                    DispatchQueue.main.async {
                        self.friendsImages[uid] = image
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

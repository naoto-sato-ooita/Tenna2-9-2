//
//  BlockManager.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/06/05.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore


final class BlockManager : ObservableObject {
    
    @StateObject var friend_manager = FriendManager.shared
    @StateObject var impression_manager = ImpressionManager.shared
    @StateObject var request_manager = RequestManager.shared
    
    static let shared = BlockManager()
    
    @Published var users: [User] = []
    
    //private let storageURL = Storage.storage().reference(forURL: "gs://glif-c9e53.appspot.com")
    
    // Block a user and save to Firestore
    func blockUser(_ user: User, targetUserId: String) {
        guard let index = users.firstIndex(where: { $0.id == user.id }) else { return }
        var blockedUsers = users[index].blockedUsers ?? []
        


        if !blockedUsers.contains(targetUserId) {
            blockedUsers.append(targetUserId)
            users[index].blockedUsers = blockedUsers
            updateBlockedUsersInFirestore(userId: user.id, blockedUsers: blockedUsers)
        }
        
        impression_manager.removeImpression(selectedUserId: targetUserId)
        friend_manager.deleteFriend(selectedUid: targetUserId)
        request_manager.deleteRequest(selectedUserId: targetUserId)
        self.declineRelation(userId: targetUserId)

    }
    
    //MARK: - データ削除
    func declineRelation(userId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let userRef = Firestore.firestore().collection("users").document(currentUserId)
        
        userRef.updateData([
            "requestList": FieldValue.arrayRemove([userId]),
            "friendList": FieldValue.arrayRemove([userId])
        ]) { error in
            if let error = error {
                print("Error declining request: \(error)")
            } else {
                self.request_manager.loadFriendRequests()
            }
        }
        
    }
    
    // Unblock a user and save to Firestore
    func unblockUser(_ user: User, targetUserId: String) {
        guard let index = users.firstIndex(where: { $0.id == user.id }) else { return }
        var blockedUsers = users[index].blockedUsers ?? []
        
        if let blockedIndex = blockedUsers.firstIndex(of: targetUserId) {
            blockedUsers.remove(at: blockedIndex)
            users[index].blockedUsers = blockedUsers
            updateBlockedUsersInFirestore(userId: user.id, blockedUsers: blockedUsers)
        }
    }
    
    // Check if a user is blocked
    func isBlocked(user: User, targetUserId: String) -> Bool {
        guard let index = users.firstIndex(where: { $0.id == user.id }) else { return false }
        return users[index].blockedUsers?.contains(targetUserId) ?? false
    }
    
    // Update blocked users in Firestore
    private func updateBlockedUsersInFirestore(userId: String?, blockedUsers: [String]) {
        guard let userId = userId else { return }
        let userRef = Firestore.firestore().collection("users").document(userId)
        userRef.updateData(["blockedUsers": blockedUsers]) { error in
            if let error = error {
                print("Error updating blocked users: \(error)")
            } else {
                print("Blocked users updated successfully")
            }
        }
    }
    
    // Load blocked users from Firestore
    func loadBlockedUsers() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let userRef = Firestore.firestore().collection("users").document(currentUserId)
        
        userRef.getDocument { document, error in
            guard let document = document, document.exists else { return }
            if let blockedUsers = document.get("blockedUsers") as? [String] {
                if let index = self.users.firstIndex(where: { $0.id == currentUserId }) {
                    self.users[index].blockedUsers = blockedUsers
                }
            }
        }
    }
}

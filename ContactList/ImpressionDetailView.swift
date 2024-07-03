//
//  ImpressionDetailView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/06/17.
//

import Foundation
import SwiftUI
import Firebase

struct ImpressionDetailView: View {
    
    
    @StateObject var friend_manager = FriendManager.shared
    @StateObject var request_manager = RequestManager.shared
    @StateObject var impression_manager = ImpressionManager.shared
    @StateObject var block_manager = BlockManager.shared
    
    @Binding var ImpressionSendUser : User
    @Binding var showImpressionDetail : Bool
    
    // ReportSendViewを表示するための状態変数
    @State var showReportSendView: Bool = false
    @State var showBlockView: Bool = false
    @State var selectedUidForReport: String?
    
    var body: some View {
        
        ZStack {
            Rectangle()
                .fill(Color.black)
                .opacity(0.4)
            
            HStack(alignment: .center){
                
                Spacer()
                
                VStack(alignment: .trailing){
                    Text(ImpressionSendUser.fullname)
                        .font(.custom(fontx, size: 26))
                        .fontWeight(.heavy)
                        .opacity(1)
                    
                    
                    if let timestamp = ImpressionSendUser.timestamp?.dateValue() {
                        Text("\(timestamp.timestampString())")
                            .font(.custom(fontx, size: 18))
                            .fontWeight(.heavy)
                            .opacity(1)
                    }
                    if let address = ImpressionSendUser.address {
                        Text("\(address)")
                            .font(.custom(fontx, size: 18))
                            .fontWeight(.heavy)
                            .opacity(1)
                    }
                    
                    HStack {
                        Button {
                            if let uid = ImpressionSendUser.uid {
                                selectedUidForReport = uid
                                showReportSendView = true
                            }
                        } label: {
                            Image(systemName:"lanyardcard.fill")
                                .frame(width: 30,height: 30)
                                .foregroundColor(.yellow)
                        }
                        
                        Button {
                            if let uid = ImpressionSendUser.uid {
                                showBlockView = true
                            }
                        } label: {
                            Image(systemName:"lanyardcard.fill")
                                .frame(width: 30,height: 30)
                                .foregroundColor(.red)
                        }
                    }
                }
                
            }
            
        }
        
        .frame(width: UIScreen.main.bounds.width - 64,height: 150)
        .foregroundColor(.white)
        
        
        
        
        
        .onTapGesture {
            withAnimation {
                showImpressionDetail = false
            }
        }
        .sheet(isPresented: $showReportSendView) {
            if let selectedUid = selectedUidForReport {
                ReportSendView(selectedUid: selectedUid)
                    .presentationDetents([.height(280)])
            }
        }
        
        .alert(isPresented: $showBlockView) {
            Alert(
                title: Text("Block?"),
                message: Text(""),
                primaryButton: .destructive(Text("Yes")) {
                    blockUser(user: ImpressionSendUser)
                    
                }
                ,secondaryButton: .cancel()
            )
        }
        
        
        
    }
    func blockUser(user: User) {
        if let currentUser = Auth.auth().currentUser {
            block_manager.blockUser(user, targetUserId: currentUser.uid)
            impression_manager.impressionUsers.removeAll { $0.uid == user.uid }
            friend_manager.friendUsers.removeAll { $0.uid == user.uid }
            request_manager.requestUsers.removeAll { $0.uid == user.uid }
        }
    }
}

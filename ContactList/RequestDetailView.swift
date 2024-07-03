//
//  RequestDetailView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/05/25.
//

import Foundation
import SwiftUI


struct RequestDetailView: View {
    
    @StateObject var friend_manager = FriendManager.shared
    @StateObject var locationManager = LocationManager.shared
    
    @Binding var requestSendUser : User
    @Binding var showRequestDetail : Bool
    
    var body: some View {
        
        ZStack {
            Rectangle()
                .fill(Color.black)
                .opacity(0.4)
            
            VStack {
                Text(requestSendUser.fullname)
                    .font(.custom(fontx, size: 24))
                    .fontWeight(.heavy)
                    .foregroundColor(Color(.white))
                    .font(.footnote)
                
                HStack(spacing: 12){
                    
                    Button() {
                        friend_manager.approveFriendRequest(from: requestSendUser.uid!)
                        showRequestDetail = false
                    } label: {
                        Text("Add")
                            .font(.custom(fontx, size: 18))
                            .frame(width: 100,height: 30)
                            .foregroundColor(.white)
                            .background(Color.mint)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Button() {
                        friend_manager.declineFriendRequest(from: requestSendUser.uid!)
                        showRequestDetail = false
                    } label: {
                        Text("Sorry")
                            .font(.custom(fontx, size: 18))
                            .frame(width: 100,height: 30)
                            .foregroundColor(.white)
                            .background(Color.pink)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width - 64,height: 150)
        .onTapGesture {
            withAnimation {
                showRequestDetail = false
            }
        }
    }
}

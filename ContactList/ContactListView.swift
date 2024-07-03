//
//  ContactListView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/05/06.
//
import Foundation
import SwiftUI


struct ContactListView: View {
    @StateObject var friend_manager = FriendManager.shared
    @StateObject var request_manager = RequestManager.shared
    @StateObject var impression_manager = ImpressionManager.shared
    @StateObject var block_manager = BlockManager.shared
    @StateObject var geo_manager = GeoManager.shared
    
    @State private var showRequestDetail = false
    @State private var showImpressionDetail = false
    @State private var requestSendUser : User?
    @State private var ImpressionSendUser : User?
    @State private var isshow :Bool = false
    @Binding var isTabBarHidden: Bool
    
    var columns : [GridItem] = Array(repeating:.init(.fixed(60)), count: 5)
    let backcolor = Color.clear
    let backopacity = 0.1
    

    var body: some View {
        NavigationStack{
            ZStack {
                LinearGradient(gradient: Gradient(colors: [yellow_color,purple_font_color]), startPoint: .bottom, endPoint: .top)
                    .ignoresSafeArea()
                
                VStack(spacing: 8) {
                    //MARK: - FRIEND
                    
                    HStack{
                        
                        Text("Friend")
                            .font(.custom(fontx, size: 26))
                            .foregroundColor(Color.white)
                            .fontWeight(.heavy)
                            .padding(.leading,32)
                        
                        Image(systemName: "balloon.2.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20,height: 20)
                            .foregroundColor(Color.white)
                        
                        Spacer()
                    }
                    
                    if !friend_manager.friendUsers.isEmpty {
                        
                        
                        
                        ZStack{
                            RoundedRectangle(cornerRadius: 10)
                                .fill(backcolor)
                                .opacity(backopacity)
                                .blur(radius: 3)
                                .frame(width: UIScreen.main.bounds.width - 32, height: 100)
                                .shadow(color: .black, radius: 10)
                            
                            RoundedRectangle(cornerRadius: 10,style: .continuous)
                                .stroke(lineWidth: 0.1)
                                .blur(radius: 1)
                                .frame(width: UIScreen.main.bounds.width - 32, height: 100)
                            
                            LazyVGrid(columns: columns,alignment: .trailing) {
                                ForEach(friend_manager.friendUsers, id: \.id) { user in
                                    NavigationLink(destination: ChatView(user: user, isTabBarHidden: $isTabBarHidden)) {
                                        
                                        if let image = friend_manager.friendsImages[user.uid ?? UUID().uuidString] {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 80, height: 80)
                                                .clipShape(Circle())
                                                .shadow(radius: 10)
                                            
                                        } else {
                                            Image(systemName: "person.circle.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 80,height: 80)
                                                .foregroundColor(Color.orange)
                                        }
                                    }
                                }
                            }
                        }.shadow(color:.black.opacity(0.4), radius: 20, x: 50, y:30)
                    }
                    
                    //MARK: - Impression
                    
                    if !impression_manager.impressionUsers.isEmpty {
                        
                        HStack {
                            Text("Popcorn")
                                .font(.custom(fontx, size: 26))
                                .foregroundColor(Color.white)
                                .fontWeight(.heavy)
                                .padding(.leading,32)
                            
                            
                            Image(systemName: "popcorn.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20,height: 20)
                                .foregroundColor(Color.white)
                            
                            Spacer()
                        }
                        
                        ZStack{
                            RoundedRectangle(cornerRadius: 10)
                                .fill(backcolor)
                                .opacity(backopacity)
                                .blur(radius: 3)
                                .frame(width: UIScreen.main.bounds.width - 32, height: 200)
                                .shadow(color: .black, radius: 10)
                            
                            RoundedRectangle(cornerRadius: 10,style: .continuous)
                                .stroke(lineWidth: 0.1)
                                .blur(radius: 1)
                                .frame(width: UIScreen.main.bounds.width - 32, height: 200)
                            
                            TabView{
                                ForEach(impression_manager.impressionUsers, id: \.id) { user in
                                    ZStack(alignment: .bottom){
                                        
                                        if let image = impression_manager.impressionImages[user.uid ?? UUID().uuidString] {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .onTapGesture {
                                                    withAnimation {
                                                        showImpressionDetail.toggle()
                                                        ImpressionSendUser = user
                                                    }
                                                }

                                            
                                        } else {
                                            Image(systemName: "person.circle.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .foregroundColor(Color(purple_font_color))
                                                .onTapGesture {
                                                    withAnimation {
                                                        showImpressionDetail.toggle()
                                                        ImpressionSendUser = user
                                                    }
                                                }

                                        }
                                    }
                                }
                            }//Tab
                            .tabViewStyle(.page)
                            .frame(width: UIScreen.main.bounds.width - 64, height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding()
                            
                            if let ImpressionSendUser = ImpressionSendUser, showImpressionDetail {
                                ImpressionDetailView(ImpressionSendUser: .constant(ImpressionSendUser), showImpressionDetail: $showImpressionDetail)
                            }
                            
                        }//ZStack
                        .shadow(color:.black.opacity(0.4), radius: 20, x: 50, y:30)
                    }
                    
                    
                    //MARK: - REQUEST
                    if !request_manager.requestUsers.isEmpty {
                        HStack {
                            Text("Request")
                                .font(.custom(fontx, size: 26))
                                .foregroundColor(Color.white)
                                .fontWeight(.heavy)
                                .padding(.leading,32)
                            
                            Image(systemName: "plus.square.fill.on.square.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20,height: 20)
                                .foregroundColor(Color.white)
                            Spacer()
                        }
                        
                        ZStack{
                            RoundedRectangle(cornerRadius: 10,style: .continuous)
                                .fill(backcolor)
                                .opacity(backopacity)
                                .blur(radius: 3)
                                .frame(width: UIScreen.main.bounds.width - 32, height: 200)
                                .shadow(color: .black, radius: 10)
                            
                            RoundedRectangle(cornerRadius: 10,style: .continuous)
                                .stroke(lineWidth: 0.1)
                                .blur(radius: 1)
                                .frame(width: UIScreen.main.bounds.width - 32, height: 200)
                            
                            TabView{
                                ForEach(request_manager.requestUsers, id: \.id) { user in
                                    if let image = request_manager.requestImages[user.uid ?? UUID().uuidString] {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .shadow(radius: 8)
                                            .onTapGesture {
                                                withAnimation {
                                                    showRequestDetail.toggle()
                                                    requestSendUser = user
                                                }
                                            }
                                    } else {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(Color(purple_font_color))
                                            .onTapGesture {
                                                withAnimation {
                                                    showRequestDetail.toggle()
                                                    requestSendUser = user
                                                }
                                            }
                                    }
                                }
                            }//Tab
                            .tabViewStyle(.page)
                            .frame(width: UIScreen.main.bounds.width - 64, height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding()
                            
                            if let requestSendUser = requestSendUser, showRequestDetail {
                                RequestDetailView(requestSendUser: .constant(requestSendUser), showRequestDetail: $showRequestDetail)
                            }
                            
                        }
                        .shadow(color:.black.opacity(0.4), radius: 20, x: 50, y:30)
                    }
                    
                    
                    //MARK: -
                    Spacer()
                }//Vstack
                
                .onAppear {
                    isTabBarHidden = false
                }
                .overlay(alignment: .bottom) {
                    HStack(alignment: .bottom) {
                        Spacer()
                        Button {
                            isshow.toggle()
                        } label: {
                            ZStack{
                                Circle()
                                    .fill(yellow_color)
                                    .opacity(0.9)
                                    .blur(radius: 1)
                                    .scaledToFill()
                                    .frame(width: 60,height: 60)
                                
                                Image(systemName: "waveform")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50,height: 50)
                                    .foregroundColor(Color(.white))
                                
                            }
                        }
                        .navigationDestination(isPresented: $isshow) { KeySetView(isTabBarHidden: $isTabBarHidden) }
                    }
                    .padding()
                    .padding(.bottom,80)
                }
                .onAppear {
                    DispatchQueue.main.async {
                        impression_manager.loadImpressions()
                        request_manager.loadFriendRequests()
                        friend_manager.loadFriends()
                    }
                }

                
            }//ZSrack
        }//NavSTack

    }

}

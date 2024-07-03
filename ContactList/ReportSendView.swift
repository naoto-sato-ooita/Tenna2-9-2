//
//  ReportSendView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/06/27.
//

import SwiftUI

struct ReportSendView: View {
    @StateObject var report_manager = ReportManager.shared

    @State private var selectedReason : String = ""
    @State var isConfirm : Bool = false
    
    var selectedUid : String
    
    let reasons : [String] = [
        "It's spam",
        "I just don't like it",
        "Nudity or sexual activity",
        "Fraud/Deception",
        "Hate speech or Discriminatory symbols",
        "False report",
        "Bullying or Harassment",
        "Violent or Dangerous group",
        "Intellectual property infringement",
        "Sale of illegal or Regulated goods",
        "Suicide or Self-harm",
        "Eating disorder"
    ]
    
    
    var body: some View {
        
        ZStack{
            LinearGradient(gradient: Gradient(colors: [yellow_color,purple_font_color]), startPoint: .bottom, endPoint: .top)
                .ignoresSafeArea()
            
            VStack {
                Text("Please select the reason for reporting")
                    .fontWeight(.bold)
                    .padding(.top,10)
                    .foregroundColor(.white)
                
                Picker("", selection: $selectedReason) {
                    ForEach(reasons, id: \.self) { reason in
                        Text(reason)
                            .foregroundColor(.white)
                    }
                }
                .pickerStyle(.wheel)
                
                Button {
                    isConfirm = true
                } label : {
                    HStack{
                        Text("Report")
                            .font(.custom(fontx, size: 20))
                            .fontWeight(.semibold)
                            .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                            .background(Color(.yellow))
                            .cornerRadius(10)
                            .foregroundColor(.black)
                        //Image(system)
                        
                    }

                }
                
            }

//            .frame(width: UIScreen.main.bounds.width - 32, height: 48)
            
            .alert(isPresented: $isConfirm) {
                Alert(
                    title: Text("Report to administrator?"),
                    message: Text(""),
                    primaryButton: .destructive(Text("YES")) {
                        report_manager.sendReport(selectedUid : selectedUid,reason: selectedReason)
                    }
                    ,secondaryButton: .cancel()
                )
            }
        }
    }
}


//
//  SettingView.swift
//  Recode
//
//  Created by Trung Nguyen on 2/19/24.
//

import SwiftUI
import StoreKit

struct SettingView: View {
    @AppStorage("darkModeOn") private var darkModeOn = false
    @Environment(\.requestReview) private var requestReview
        
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    List {
                        
                        NavigationLink {
                            AboutView()
                        } label: {
                            Image(systemName: "questionmark.app")
                            Text("How To Use")
                        }
                        
                        Toggle(isOn: $darkModeOn, label: {
                            HStack {
                                Image(systemName: "moon.dust")
                                Text("Dark Mode")
                            }
                        })
                        
                        Button(action: {
                            DispatchQueue.main.async {
                                requestReview()
                            }
                        }, label: {
                            Image(systemName: "hand.thumbsup")
                            Text("Like The App? Write Us A Review")
                        })
                        .buttonStyle(.plain)
                    }
                }
                .listStyle(.inset)
                .navigationTitle("Setting")
                .navigationBarTitleDisplayMode(.inline)
            } // end NavigationStack
        }
    }
    
    struct AboutView: View {
        var body: some View {
            ScrollView {
                Text("CodeRev helps you ace coding interviews by using a smart system that reminds you to review questions at optimal intervals.")
                    .font(.headline)
                Text("🚀 Step 1: Choose questions to review in Questions (Select a question -> turn on Review -> Save). You can add custom question as well.")
                    .padding(.leading, 10)
                    .padding(.vertical)
                Text("📝 Step 2: Head to Deck to add note or hints for each question.")
                    .padding(.leading, 10)
                    .padding(.vertical)
                Text("🔍 Step 3: Go to Review to see questions that need reviewing. Try to recall the approach for each question. Then, choose whether it is easy (Good) or difficult (Hard) so that the app can calculate the next review time.")
                    .padding(.leading, 10)
                    .padding(.vertical)
                Divider()
                Text("💡 Tip: Utilize note to summarize question, enhancing your understanding of the question and eliminating the need to visit the problem statement link.")
                    .padding(.leading, 10)
                    .padding(.vertical)
                Text("💡 Tip: Don't remember code, focus on remember the approach instead. Use hints to assist you with this.")
                    .padding(.leading, 10)
                    .padding(.vertical)
                Text("💡 Tip: It's good to review once a day or before solving a new coding challenge. Good luck! 😉")
                    .padding(.leading, 10)
                    .padding(.vertical)
            }
            .scrollIndicators(.hidden)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(Color(UIColor.systemBackground))
                    .shadow(radius: 5)
            )
            .padding()
            Spacer()
        }
    }
    
}

#Preview {
    SettingView()
}

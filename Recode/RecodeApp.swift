//
//  RecodeApp.swift
//  Recode
//
//  Created by Trung Nguyen on 2/17/24.
//

import SwiftUI
import SwiftData

@main
struct RecodeApp: App {
    @AppStorage("darkModeOn") private var darkModeOn = false
    @StateObject var model: RecodeModel = RecodeModel()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Review", systemImage: "book")
                    }

                ContentView()
                    .tabItem {
                        Label("Questions", systemImage: "square.3.layers.3d.down.left")
                    }
                
                UserQuestionsView()
                    .tabItem {
                        Label("Deck", systemImage: "folder")
                    }
                
                SettingView()
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Setting")
                    }
            }
            .modelContainer(for: Question.self)
            .environmentObject(model)
            .environment(\.colorScheme, darkModeOn ? .dark : .light)
        }
    }
}

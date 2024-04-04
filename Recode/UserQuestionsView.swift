//
//  UserQuestionsView.swift
//  Recode
//
//  Created by Trung Nguyen on 2/18/24.
//

import SwiftUI
import SwiftData

struct UserQuestionsView: View {
    @Query let questions: [Question]
    
    var body: some View {
        NavigationStack {
            List(questions) { q in
                if let qInfo = q.qInfo { // if a question have qInfo, that mean the user is reviewing it
                    NavigationLink {
                        QinfoEditor(name: q.name, qInfo: qInfo)
                    } label: {
                        Text(q.name)
                    }
                }
            }
            .navigationTitle("Deck")
            .navigationBarTitleDisplayMode(.inline)
        } // end navigationstack
    }
}

struct QinfoEditor: View {
    let name: String
    let qInfo: QuestionInfo
    @Environment(\.modelContext) var context
    
    @State private var note: String = ""
    @State private var hints: [String] = [""]
    @State private var isPaused: Bool = false
    
    @Environment(\.dismiss) var dismiss
    @State private var forgetAlert: Bool = false
    @State private var deleteAlert: Bool = false
    
    var body: some View {
        Form {
            Section("Note") {
                TextField("", text: $note, axis: .vertical)
                    .lineLimit(1...5)
            }
            Section("Hints") {
                ForEach(hints.indices, id: \.self) { index in
                    TextField("\(Image(systemName: "plus"))", text: $hints[index], axis: .vertical)
                        .onChange(of: hints[index]) {
                            if index == hints.endIndex - 1 && hints.last != "" {
                                hints.append("")
                            } else if hints[index] == "" {
                                hints.remove(at: index)
                            }
                        }
                        .lineLimit(1...5)
                }
            }
            Toggle("Pause", isOn: $isPaused) // pause exclude question from review
            
            Section("Review Stats") {
                Text("Due: \(qInfo.card.due.formatted())")
                Text("Difficulty: \(qInfo.card.difficulty)")
                Text("Elapsed Days: \(qInfo.card.elapsedDays)")
                Text("Scheduled Days: \(qInfo.card.scheduledDays)")
                Text("Reps: \(qInfo.card.lapses)")
                Text("Status: \(qInfo.card.status.stringValue)")
                Text("Last Review: \(qInfo.card.lastReview.formatted())")
            }
            
            Button("Forget") { // reset review progress to beginning
                forgetAlert = true
            }
            Button("Delete") { // Remove from deck, delete everything, show alert
                deleteAlert = true
            }
            .tint(.red)
        }
        .onAppear {
            hints = qInfo.hints
            isPaused = qInfo.isPaused
            note = qInfo.note
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(name)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    withAnimation {
                        save()
                        dismiss()
                    }
                }
            }
        }
        .alert("Delete Card", isPresented: $deleteAlert) {
            Button(role: .cancel) {

            } label: {
                Text("Cancel")
            }
            Button(role: .destructive) {
                context.delete(qInfo)
                //print("delete card")
                dismiss()
            } label: {
                Text("Delete Card")
            }
        } message: {
            HStack {
                Text("This action will delete notes, hints, and review progress for this question. If you wish to temporarily suspend reviewing this question, please use the 'Pause' option instead.")
            }
        }
        .alert("Forget Card", isPresented: $forgetAlert) {
            Button(role: .cancel) {
                
            } label: {
                Text("Cancel")
            }
            Button("Forget Card") {
                qInfo.card = Card()
                //print("forget card")
            }
        } message: {
            Text("Reset the review progress for question in which you made considerable progress in the past but have completely forgotten now.")
        }
    }
    
    private func save() {
        qInfo.note = note
        qInfo.hints = hints
        qInfo.isPaused = isPaused
        //print(qInfo.hints)
    }
    
}

#Preview {
    UserQuestionsView()
}

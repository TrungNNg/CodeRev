//
//  ContentView.swift
//  Recode
//
//  Created by Trung Nguyen on 2/17/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var model: RecodeModel
    @Environment(\.modelContext) var context
    @Query var questions: [Question]
    
    @State private var selectQuestionId: PersistentIdentifier?
    
    // this value will be use to cache data from json 1 time only
    @AppStorage("cachedQuestions") var cachedQuestions: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                /*
                Button("Delete all question") {
                    try? context.delete(model: Question.self)
                }
                Button("cached again") { cachedQuestions = false }
                */
                if model.isSearching {
                    List(model.filteredQuestions) { q in
                        HStack {
                            Text(q.name)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            //print("tapped")
                            model.searchText = ""
                            selectQuestionId = q.id
                        }
                    }
                } else {
                    if questions.isEmpty {
                        Text("Tap + to add new question.")
                    } else {
                        List(Pattern.allCases, id: \.self) { p in
                            Section(p.rawValue) {
                                ForEach(questions.filter{$0.pattern == p}) { q in
                                    NavigationLink {
                                        QuestionEditor(question: q)
                                    } label: {
                                        HStack {
                                            Text(q.name)
                                            Spacer()
                                            if q.qInfo != nil {
                                                Image(systemName: "checkmark")
                                                    .foregroundStyle(.green)
                                            }
                                        }
                                    }
                                    .id(q.id)
                                }
                                .onDelete { IndexSet in
                                    for i in IndexSet {
                                        context.delete(questions[i])
                                    }
                                }
                            }
                        }
                        .onAppear {
                            //print("start scroll")
                            withAnimation {
                                if selectQuestionId != nil {
                                    print("hit here")
                                    proxy.scrollTo(selectQuestionId, anchor: .top)
                                    selectQuestionId = nil
                                }
                            }
                        }
                    }
                }
            } // scrollviewreader end here
            .searchable(text: $model.searchText, placement: .automatic, prompt: "Search questions...")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    NavigationLink {
                        QuestionEditor(question: nil)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationTitle("Questions")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                // this task should only fetch 1 time the first time this view open
                //print("task run")
                
                // See RecodeModel.swift for explaination
                model.questions = questions
                
                if !cachedQuestions {
                    cachedQuestions = true
                    //print("start cache question")
                    do {
                        try await model.fetchQuestions()
                        for qd in model.questionsDecode {
                            let q = Question(name: qd.name, link: qd.link, difficulty: qd.difficulty, pattern: qd.pattern)
                            context.insert(q)
                        }
                    } catch {
                        // if error or urlrequest timeout, continue to use the app normally
                        print("error caching questions")
                    }
                }
            }
        } // end nav stack
    }
    
}

struct QuestionEditor: View {
    
    let question: Question?
    @Environment(\.modelContext) var context
    
    @State private var name: String = ""
    @State private var link: String = ""
    @State private var difficulty: Difficulty = .easy
    @State private var pattern: Pattern = .arrayAndHash
    @State private var isReviewing: Bool = false
    
    private var editorTitle: String {
        question == nil ? "Add Question" : "Edit Question"
    }
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        //NavigationStack {
            Form {
                Section("Title") {
                    TextField("e.g: Two Sum", text: $name, axis: .vertical)
                        .lineLimit(1...2)
                }
                Section("Link") {
                    TextField("e.g: https://leetcode.com/problems/two-sum/description/", text: $link, axis: .vertical)
                        .lineLimit(1...2)
                }
                Picker("Difficulty", selection: $difficulty) {
                    ForEach(Difficulty.allCases, id: \.self) { d in
                        Text(d.rawValue).tag(d)
                    }
                }
                Picker("Pattern", selection: $pattern) {
                    ForEach(Pattern.allCases, id: \.self) { p in
                        Text(p.rawValue).tag(p)
                    }
                }
                Toggle("Review", isOn: $isReviewing)
            }
            .onAppear {
                if let question {
                    name = question.name
                    link = question.link
                    difficulty = question.difficulty
                    pattern = question.pattern
                    if question.qInfo != nil {  // the question is reviewing
                        isReviewing = true
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(editorTitle)
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
        //}
    }
    
    private func save() {
        if let question {
            question.name = name
            question.link = link
            question.difficulty = difficulty
            question.pattern = pattern
            if isReviewing {
                if question.qInfo == nil { // only add new qInfo if there is no old qInfo
                    let qInfo = QuestionInfo()
                    question.qInfo = qInfo
                }
            } else {
                if question.qInfo != nil { // reset the questions's review progress
                    context.delete(question.qInfo!)
                }
            }
        } else {
            let newQuestion = Question(name: name, link: link, difficulty: difficulty, pattern: pattern)
            if isReviewing {
                let qInfo = QuestionInfo()
                newQuestion.qInfo = qInfo
            }
            context.insert(newQuestion)
        }
    }
}

#Preview {
    ContentView()
}

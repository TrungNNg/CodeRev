//
//  RecodeModel.swift
//  Recode
//
//  Created by Trung Nguyen on 2/17/24.
//

import Foundation
import SwiftData
import Combine
import UserNotifications

class RecodeModel: ObservableObject {
    var questionsDecode: [QuestionDecode] = []
    
    //let testURL = "http://127.0.0.1:5500/test2.json"
    //let testURL2 = "https://trungnng.github.io/test2.json"
    let questionsURL = "https://trungnng.github.io/pattern.json"
    
    @Published var searchText: String = ""
    private var cancellables = Set<AnyCancellable>()
    @Published var filteredQuestions: [Question] = []
    var isSearching: Bool { !searchText.isEmpty }
    
    // To filter questions that match search text, I need to access a list of all Question [Question]
    // to get that list, in the ContentView() there is a task that run everytime the view appear
    // this task copy the [Question] from @Query in View and pass it to the questions var below
    // the var then use for filtering quesiton
    var questions: [Question] = []
    
    init() {
        addSubscriber()
        //requestNotification()
    }
    
    private func addSubscriber() {
        $searchText
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] searchText in
                //print("sink hit, searchText: \(searchText)")
                self?.filterQuestions(searchText: searchText)
            }
            .store(in: &cancellables)
    }
    
    private func filterQuestions(searchText: String) {
        //print("filterQuestions hit")
        guard !searchText.isEmpty else {
            filteredQuestions.removeAll()
            return
        }
        filteredQuestions = questions.filter({ q in
            let nameContainsSearch: Bool = q.name.localizedCaseInsensitiveContains(searchText)
            let patternContainsSearch: Bool = q.pattern.rawValue.localizedCaseInsensitiveContains(searchText)
            //print("2 condition: \(nameContainsSearch), \(patternContainsSearch)")
            return nameContainsSearch || patternContainsSearch
        })
    }

    func fetchQuestions() async throws {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForResource = 3 // the request will take at most 3 seconds
        let session = URLSession(configuration: sessionConfig)
        do {
            if let url = URL(string: questionsURL) {
                let (data, _) = try await session.data(from: url)
                let decoder = JSONDecoder()
                questionsDecode = try decoder.decode([QuestionDecode].self, from: data)
            }
        } catch {
            print("error fetching json")
            print(error.localizedDescription)
            throw error
        }
    }
    
}

enum Difficulty: String, Codable, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
}

enum Pattern: String, Codable, CaseIterable {
    case arrayAndHash = "Array & Hashing"
    case twoPointers = "Two Pointers"
    case slidingWindow = "Sliding Window"
    case stack = "Stack"
    case binarySearch = "Binary Search"
    case linkedList = "Linked List"
    case tree = "Tree"
    case trie = "Trie"
    case heap = "Heap/Priority Queue"
    case backtrack = "Backtracking"
    case graph = "Graphs"
    case oneDP = "1D Dynamic Programming"
    case twoDP = "2D Dynamic Programming"
    case greedy = "Greedy"
    case intervals = "Intervals"
    case mandAndGeo = "Math & Geometry"
    case bitwise = "Bitwise"
    case string = "String"
    case cyclicSort = "Cyclic Sort"
    case topKelement = "Top K Element"
    case kWayMerge = "K-way Merge"
    case zeroOneKnapsack = "0/1 Knapsack"
    case other = "Other"
}

struct QuestionDecode: Decodable {
    let name: String
    let link: String
    let difficulty: Difficulty
    let pattern: Pattern
}

@Model
class Question {
    var name: String
    var link: String
    var difficulty: Difficulty
    var pattern: Pattern
    
    @Relationship(deleteRule: .cascade) var qInfo: QuestionInfo?
    
    init(name: String, link: String, difficulty: Difficulty, pattern: Pattern) {
        self.name = name
        self.link = link
        self.difficulty = difficulty
        self.pattern = pattern
    }
}

@Model
class QuestionInfo {
    var note: String
    var hints: [String]
    var isPaused: Bool
    var card: Card
    
    var question: Question?
    
    // hints need to be [""] for QinfoEditorView to work
    init(note: String = "", hints: [String] = [""], isPaused: Bool = false, card: Card = Card()) {
        self.note = note
        self.hints = hints
        self.isPaused = isPaused
        self.card = card
    }
}



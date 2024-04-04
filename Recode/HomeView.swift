//
//  HomeView.swift
//  Recode
//
//  Created by Trung Nguyen on 2/17/24.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(filter: #Predicate<Question>{ $0.qInfo != nil }) var questions: [Question]
    var questionsRemain: Int {
        questions.filter{ $0.qInfo!.card.due < .now && $0.qInfo!.isPaused == false }.count
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                /*
                //Spacer()
                //Spacer()
                //Spacer()
                 */
                NavigationLink {
                    ReviewView()
                        .toolbar(.hidden, for: .tabBar)
                } label: {
                    ZStack(alignment: .topTrailing) {
                        Text("Review".uppercased())
                            .badge(Text("\(questionsRemain)"))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding()
                            .padding(.horizontal, 20)
                            .background {
                                Color.blue
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .shadow(radius: 2)
                            }
                        if questionsRemain > 0 {
                            NumberBadge(number: questionsRemain)
                                .offset(x: 10, y: -14)
                        }
                    }
                }
                /*
                //Spacer()
                //Spacer()
                NavigationLink {
                    AffiliateView()
                } label: {
                    HStack {
                        Text("Affiliate Courses")
                        Image(systemName: "arrow.forward.circle")
                    }
                    .fontWeight(.light)
                }
                //Spacer()
                 */
                
            } // end VStack
            .navigationTitle("CodeRev")
            .navigationBarTitleDisplayMode(.inline)
        } // end navigationStack
    } // end body
    
}

struct AffiliateView: View {
    var body: some View {
        Text("Affiliate Courses")
    }
}

struct ReviewView: View {
    // this view need to go over all questions that user are reviewing and pass due date
    @Query(filter: #Predicate<Question>{ $0.qInfo != nil }) var questions: [Question]
    
    @State private var currentQuestion: Question?
    @State private var f: FSRS = FSRS()
    @State private var schedulingCards: [Rating:SchedulingInfo] = [:]
    
    @State private var showHints: [Int:Bool] = [:]

    @State private var remainQuestions: [Question] = []
    
    var body: some View {
        VStack {
            if currentQuestion == nil {
                Text("Nothing to review.")
                    .fontWeight(.semibold)
            } else if let currentQuestion, let qInfo = currentQuestion.qInfo {
                HStack {
                    Text("\(currentQuestion.name) (\(currentQuestion.difficulty.rawValue))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(3)
                    Spacer()
                    
                    if let url = URL(string: currentQuestion.link) {
                        Link(destination: url) {
                            Circle()
                                .fill(.white)
                                .frame(width: 45, height: 45, alignment: .center)
                                .shadow(radius: 5)
                                .overlay {
                                    Image(systemName: "link")
                                        .foregroundStyle(.blue)
                                }
                        }
                        .padding(.horizontal)
                    }
                }
                //.border(.blue, width: 1)
                Divider()
                Text("Note:")
                    .fontWeight(.semibold)
                Text(qInfo.note)
                Divider()
                Text("Hints:")
                    .fontWeight(.semibold)
                // 0..<hints.count-1 to skip the last element which is ""
                List {
                    ForEach(0..<qInfo.hints.count-1, id: \.self) { i in
                        if let showHint = showHints[i] {
                            if !showHint {
                                HStack {
                                    Text("Hint \(i+1)")
                                    Spacer()
                                    Button("Show") {
                                        showHints[i] = true
                                    }
                                    .buttonStyle(.bordered)
                                }
                            } else {
                                Text(qInfo.hints[i])
                                    .onTapGesture {
                                        showHints[i] = false
                                    }
                            }
                        }
                    }
                }
                .listStyle(.inset)
                
                HStack {
                    Spacer()
                    Button("Good") {
                        if let s = schedulingCards[.good] { qInfo.card = s.card }
                        getNewCurrentQuestion()
                    }
                    .tint(.green)
                    .controlSize(.large)
                    Spacer()
                    Button("Hard") {
                        if let s = schedulingCards[.hard] { qInfo.card = s.card }
                        getNewCurrentQuestion()
                    }
                    .tint(.red)
                    .controlSize(.large)
                    Spacer()
                }
                .buttonStyle(.borderedProminent)
                .padding(.vertical,15)
            }
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Remaining: \(remainQuestions.count)")
            }
        }
        .onAppear {
            // when the view first appear, we query for Questions that have qInfo (meaning the user select the
            // question for review). Then we filter it again for quesitons which pass due date and not pause.
            // I can not build a #Predicate for these 3 conditions so I have to do 2 step.
            remainQuestions = questions.filter{ $0.qInfo!.card.due < .now && $0.qInfo!.isPaused == false }
            getNewCurrentQuestion()
        }
    }
    
    private func getNewCurrentQuestion() {
        remainQuestions = remainQuestions.filter { $0.qInfo!.card.due < .now }
        currentQuestion = remainQuestions.first
        
        if let currentQuestion, let qInfo = currentQuestion.qInfo {
            //print("schedule new card")
            // if currentQuestion is not nil, schedule it with new qInfo.card
            schedulingCards = f.repeat(card: qInfo.card, now: .now)
            
            // update showHints for new questions
            showHints.removeAll()
            for i in qInfo.hints.indices {
                showHints[i] = false
            }
        }
    }
    
}

struct NumberBadge: View {
    var number: Int

    var body: some View {
        Text(number > 99 ? "99+" : "\(number)")
            .foregroundColor(.white)
            .font(.caption)
            .padding(10)
            .background {
                if number < 10 {
                    Circle()
                        .foregroundStyle(.red)
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.red)
                }
            }
    }
}

#Preview {
    HomeView()
}

//
//  ContentView.swift
//  testing_code
//
//  Created by MacBook Pro on 10/11/23.
//

import SwiftUI


struct Card: Codable, Identifiable {
    let id: String
    let name: String
    let manaCost: String?
    let typeLine: String?
    let oracleText: String?
    let colors: [String]?
    let rarity: String
    let set: String
    let imageUrl: ImageUris?
    let prices: Prices?
    let foil: Bool?
    let nonfoil: Bool?
    let reserved: Bool?
    let legalities: Legalities
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case manaCost = "mana_cost"
        case typeLine = "type_line"
        case oracleText = "oracle_text"
        case colors
        case rarity
        case set
        case imageUrl = "image_uris"
        case prices
        case foil
        case reserved
        case nonfoil
        case legalities
    }
}

struct Prices: Codable {
    var usd: String?
    var usdFoil: String?
    
    enum CodingKeys: String, CodingKey {
        case usd
        case usdFoil = "usd_foil"
    }
}

struct ImageUris: Codable {
    var small: URL
    var normal: URL
    var large: URL?
    var png: URL?
    var artCrop: URL?
    var borderCrop: URL?
    
    enum CodingKeys: String, CodingKey {
        case small
        case normal
        case large
        case png
        case artCrop = "art_crop"
        case borderCrop = "border_crop"
    }
}

struct Legalities: Codable {
    let standard: String
    let future: String
    let historic: String
    let gladiator: String
    let pioneer: String
    let explorer: String
    let modern: String
    let legacy: String
    let pauper: String
    let vintage: String
    let penny: String
    let commander: String
    let oathbreaker: String
    let brawl: String
    let historicbrawl: String
    let alchemy: String
    let paupercommander: String
    let duel: String
    let oldschool: String
    let premodern: String
    let predh: String
}

struct CardResponse: Codable {
    let data: [Card]
}

class CardViewModel: ObservableObject {
    @Published var cards: [Card] = []
    
    init() {
        if let url = Bundle.main.url(forResource: "WOT-Scryfall", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let response = try decoder.decode(CardResponse.self, from: data)
                self.cards = response.data
            } catch {
                print("error decoding json: \(error)")
            }
        }
    }
}
struct CardImageView: View {
    let card: Card
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .bottom)) {
            if let imageUris = card.imageUrl {
                AsyncImage(url: imageUris.small) { image in
                    image.resizable()
                } placeholder: {
                    Color.secondary.frame(width: 80, height: 120)
                        .opacity(0.6)
                }
                .frame(width: 80, height: 120)
                .cornerRadius(6)
                
                if card.foil == true{
                    Text("F")
                        .fontWeight(.bold)
                        .font(.caption2)
                        .padding(4)
                        .background(Color.accentColor.opacity(0.7))
                        .cornerRadius(4)
                        .padding([.bottom, .leading], 4)
                }
                
                if card.nonfoil == true {
                    Text("N")
                        .fontWeight(.bold)
                        .font(.caption2)
                        .padding(4)
                        .background(Color.indigo.opacity(0.7))
                        .cornerRadius(4)
                        .padding([.leading], 22)
                        .padding([.bottom], 4)
                }
            }
        }
    }
}

private struct previewCardImageView: View {
    @ObservedObject var cardViewModel = CardViewModel()
    var body: some View{
        CardImageView(card: cardViewModel.cards[0])
    }
}
#Preview {
    previewCardImageView()
}

struct CardDetailView: View {
    let card: Card
    @State private var isPeeking = false
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .center, content: {
                    if let imageUris = card.imageUrl {
                        AsyncImage(url: imageUris.artCrop) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: UIScreen.main.bounds.width * 0.9)
                                .onTapGesture {
                                    isPeeking.toggle()
                                }
                        } placeholder: {
                            Color.secondary
                                .opacity(0.6)
                                .frame(width: UIScreen.main.bounds.width * 0.9)
                        }
                        .cornerRadius(14)
                    }
                    HStack(alignment: .top , content: {
                        VStack(alignment: .leading, content: {
                            Text(card.name)
                                .multilineTextAlignment(.leading)
                                .font(.title2)
                                .bold()
                            Text(card.typeLine ?? "")
                                .multilineTextAlignment(.leading)
                                .font(.subheadline)
                        })
                        Spacer()
                        if let manaCost = card.manaCost {
                            HStack(spacing: 5) {
                                ForEach(Array(manaCost.replacingOccurrences(of: "{", with: "").replacingOccurrences(of: "}", with: "")), id: \.self) { char in
                                    Text(String(char))
                                        .font(.subheadline)
                                        .bold()
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.secondary)
                                        .clipShape(Circle())
                                }
                            }
                        }
                    })
                    .padding(.vertical)
                    Text(card.oracleText ?? "")
                        .font(.caption)
                        .padding()
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(14)
                    HStack {
                        Text("Legalities")
                            .font(.subheadline)
                            .bold()
                            .padding(.top)
                        Spacer()
                    }
                    legalitiesView(legalities: card.legalities)
                })
                .padding()
            }
            
            if isPeeking {
                Color.black.opacity(0.8)
                    .edgesIgnoringSafeArea(.all) // Dark overlay
                    .onTapGesture {
                        isPeeking = false
                    }
                
                if let imageUris = card.imageUrl {
                    AsyncImage(url: imageUris.large) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: UIScreen.main.bounds.width * 0.9)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                isPeeking = false
                            }
                    } placeholder: {
                        Color.secondary
                            .opacity(0.6)
                            .frame(width: UIScreen.main.bounds.width * 0.9)
                    }
                    .cornerRadius(14)
                    .onTapGesture {
                        isPeeking = false
                    }
                }
            }
        }
        
    }
}

private struct legalitiesView: View {
    let legalities: Legalities
    var body: some View {
        HStack(alignment: .top, content: {
            VStack {
                helperView(label: "Standard", value: legalities.standard)
                helperView(label: "Future", value: legalities.future)
                helperView(label: "Historic", value: legalities.historic)
                helperView(label: "Gladiator", value: legalities.gladiator)
                helperView(label: "Pioneer", value: legalities.pioneer)
                helperView(label: "Explorer", value: legalities.explorer)
                helperView(label: "Modern", value: legalities.modern)
                helperView(label: "Legacy", value: legalities.legacy)
                helperView(label: "Pauper", value: legalities.pauper)
                helperView(label: "Penny", value: legalities.penny)
                helperView(label: "Vintage", value: legalities.vintage)
            }
            .padding(.trailing)
            VStack {
                helperView(label: "Commander", value: legalities.commander)
                helperView(label: "Oathbreaker", value: legalities.oathbreaker)
                helperView(label: "Brawl", value: legalities.brawl)
                helperView(label: "Historic Brawl", value: legalities.historicbrawl)
                helperView(label: "Alchemy", value: legalities.alchemy)
                helperView(label: "Pauper Commander", value: legalities.paupercommander)
                helperView(label: "Duel", value: legalities.duel)
                helperView(label: "Old School", value: legalities.oldschool)
                helperView(label: "Premodern", value: legalities.premodern)
                helperView(label: "Pre DH", value: legalities.predh)
            }
            .padding(.leading)
        })
    }
    
    func helperView(label: String, value: String) -> some View {
        HStack {
            Text(value == "legal" ? "Legal" : "Not Legal")
                .font(.caption)
                .bold()
                .padding(7)
                .frame(minWidth: 80)
                .background(getBackgroudColor(value))
                .cornerRadius(6)
                .multilineTextAlignment(.center) // Align the text center
            Spacer()
            Text(label)
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    func getBackgroudColor(_ value: String) -> Color {
        switch value {
        case "legal":
            return Color.green.opacity(0.5)
        case "not_legal":
            return Color.secondary.opacity(0.5)
        default:
            return Color.secondary.opacity(0.5)
        }
    }
}

private struct previewCardDetailView: View {
    @ObservedObject var cardViewModel = CardViewModel()
    var body: some View {
        CardDetailView(card: cardViewModel.cards[0])
    }
}

#Preview {
    previewCardDetailView()
}


struct LoadingView: View {
    var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .green))
            .scaleEffect(2.0, anchor: .center)
    }
}

struct ContentView: View {
    @ObservedObject var cardViewModel = CardViewModel()
    @State var searchvalue = ""
    @State var sortingAscending: Bool? = nil
    @State private var isLoading = true
    
    var filteredCards: [Card] {
        var sortedCards = cardViewModel.cards
        
        if let isAscending = sortingAscending {
            sortedCards.sort(by: { card1, card2 in
                if isAscending {
                    return card1.name < card2.name
                } else {
                    return card1.name > card2.name
                }
            })
        }
        
        if !searchvalue.isEmpty {
            sortedCards = sortedCards.filter { $0.name.lowercased().contains(searchvalue.lowercased()) }
        }
        
        return sortedCards
    }
    
    var body: some View {
        ZStack {
            if isLoading {
                LoadingView()
            } else {
                NavigationView {
                    List(filteredCards) { card in
                        NavigationLink(destination: CardDetailView(card: card)) {
                            HStack(alignment: .center) {
                                CardImageView(card: card)
                                VStack(alignment: .leading) {
                                    Text(card.name)
                                        .font(.headline)
                                        .bold()
                                    
                                    Text(card.rarity)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .padding(.bottom, 15)
                                    Text(card.oracleText ?? "")
                                        .font(.caption2)
                                }
                                .padding(.vertical, 10)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .searchable(text: $searchvalue, prompt: "Search Card")
                    .navigationTitle("Card List")
                    .navigationBarItems(trailing: Button(action: {
                        if sortingAscending == nil {
                            sortingAscending = true
                        } else if sortingAscending == true {
                            sortingAscending = false
                        } else {
                            sortingAscending = nil
                        }
                    }) {
                        Text(sortingAscending == nil ? "Sort A-Z" : (sortingAscending! ? "Sort Z-A" : "Clear Sort"))
                            .padding(.horizontal)
                    })
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut(duration: 1)) {
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

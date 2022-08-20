import Foundation

struct Starships: Decodable { //Like with Films you only care about count and results.
  var count: Int
  var all: [Starship]
  
  enum CodingKeys: String, CodingKey {
    case count
    case all = "results"
  }
}

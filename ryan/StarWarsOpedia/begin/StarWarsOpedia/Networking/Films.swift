import Foundation

struct Films: Decodable {// This struct denotes a collection of films.
  let count: Int
  let all: [Film]
  
  enum CodingKeys: String, CodingKey {
    case count
    case all = "results"
  }
}

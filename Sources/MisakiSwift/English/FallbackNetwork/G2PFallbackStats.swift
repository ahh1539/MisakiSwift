import Foundation

/// Counts of out-of-lexicon BART fallback lookups since the last consume.
/// `hits` are words that reused a cached phoneme and skipped generation.
public struct G2PFallbackStats: Sendable, Equatable {
  public var lookups: Int
  public var hits: Int
  public var misses: Int { lookups - hits }

  public static let zero = G2PFallbackStats(lookups: 0, hits: 0)

  public init(lookups: Int, hits: Int) {
    self.lookups = lookups
    self.hits = hits
  }
}

/// Bounded `word → phoneme` memo for the OOV BART fallback.
///
/// BART decode does up to 50 host-sync `.item()` calls per miss and runs on the
/// same MLX worker as the TTS decoder, so a repeated proper noun in later chunks
/// should not pay that cost again. Capacity is an insertion-order cap, not LRU.
struct G2PFallbackCache: Sendable {
  struct Entry: Sendable, Equatable {
    let phoneme: String
    let rating: Int
  }

  private var storage: [String: Entry] = [:]
  private var insertionOrder: [String] = []
  private let capacity: Int
  private(set) var lookups = 0
  private(set) var hits = 0

  init(capacity: Int = 4096) {
    self.capacity = max(1, capacity)
  }

  mutating func lookup(_ key: String) -> Entry? {
    lookups += 1
    if let entry = storage[key] {
      hits += 1
      return entry
    }
    return nil
  }

  mutating func store(_ key: String, phoneme: String, rating: Int) {
    if storage[key] == nil {
      if storage.count >= capacity {
        let oldest = insertionOrder.removeFirst()
        storage.removeValue(forKey: oldest)
      }
      insertionOrder.append(key)
    }
    storage[key] = Entry(phoneme: phoneme, rating: rating)
  }

  mutating func consumeStats() -> G2PFallbackStats {
    let stats = G2PFallbackStats(lookups: lookups, hits: hits)
    lookups = 0
    hits = 0
    return stats
  }
}

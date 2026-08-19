import Testing
@testable import MisakiSwift

@Test func fallbackCacheCountsLookupsHitsAndResetsOnConsume() {
  var cache = G2PFallbackCache(capacity: 8)

  #expect(cache.lookup("Junco") == nil)
  cache.store("Junco", phoneme: "ʤˈʌŋkoʊ", rating: 1)
  #expect(cache.lookup("Junco")?.phoneme == "ʤˈʌŋkoʊ")
  #expect(cache.lookup("Junco")?.rating == 1)

  let stats = cache.consumeStats()
  #expect(stats.lookups == 3)
  #expect(stats.hits == 2)
  #expect(stats.misses == 1)
  #expect(cache.consumeStats() == .zero)
}

@Test func fallbackCacheEvictsOldestKeyAtCapacity() {
  var cache = G2PFallbackCache(capacity: 2)
  cache.store("one", phoneme: "a", rating: 1)
  cache.store("two", phoneme: "b", rating: 1)
  cache.store("three", phoneme: "c", rating: 1)

  _ = cache.consumeStats()
  #expect(cache.lookup("one") == nil)
  #expect(cache.lookup("two")?.phoneme == "b")
  #expect(cache.lookup("three")?.phoneme == "c")
}

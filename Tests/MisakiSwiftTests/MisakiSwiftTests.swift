import Testing
@testable import MisakiSwift

@Test func packageResourcesLoadFromModuleBundle() {
  #expect(!DataResourcesUtil.loadGold(british: false).isEmpty)
  #expect(!DataResourcesUtil.loadSilver(british: false).isEmpty)
  #expect(!DataResourcesUtil.loadGold(british: true).isEmpty)
  #expect(!DataResourcesUtil.loadSilver(british: true).isEmpty)
}

let texts: [(originalText: String, britishPhonetization: String, americanPhoneitization: String)] = [
  ("[Misaki](/misˈɑki/) is a G2P engine designed for [Kokoro](/kˈOkəɹO/) models.",
   "misˈɑki ɪz ɐ ʤˈiːtəpˈiː ˈɛnʤɪn dɪzˈInd fɔː kˈOkəɹO mˈɒdᵊlz.",
   "misˈɑki ɪz ɐ ʤˈitəpˈi ˈɛnʤən dəzˈInd fɔɹ kˈOkəɹO mˈɑdᵊlz."),
  ("“To James Mortimer, M.R.C.S., from his friends of the C.C.H.,” was engraved upon it, with the date “1884.”",
   "“tə ʤˈAmz mˈɔːtɪmə, ˌɛmˌɑːsˌiːˈɛs, fɹɒm hɪz fɹˈɛndz ɒv ðə sˌiːsˌiːˈAʧ,” wɒz ɪnɡɹˈAvd əpˈɒn ɪt, wɪð ðə dˈAt “ˌAtˈiːn ˈAti fˈɔː.”",
   "“tə ʤˈAmz mˈɔɹTəməɹ, ˌɛmˌɑɹsˌiˈɛs, fɹʌm hɪz fɹˈɛndz ʌv ðə sˌisˌiˈAʧ,” wʌz ɪnɡɹˈAvd əpˈɑn ɪt, wɪð ðə dˈAt “ˌAtˈin ˈATi fˈɔɹ.”")
]

/// MLX G2P is stream-thread-local and needs a bundled metallib. Mac `swift test`
/// hops threads and aborts; keep these on iOS where the app already pins MLX.
#if os(iOS)
@Suite("EnglishG2P", .serialized)
struct EnglishG2PTests {
  @Test func testStrings_BritishPhonetization() {
    let englishG2P = EnglishG2P(british: true)

    for pair in texts {
      #expect(englishG2P.phonemize(text: pair.0).0 == pair.1)
    }
  }

  @Test func testStrings_AmericanPhonetization() {
    let englishG2P = EnglishG2P(british: false)

    for pair in texts {
      #expect(englishG2P.phonemize(text: pair.0).0 == pair.2)
    }
  }

  @Test func testRetokenize_CurrencyWithFollowingTokens() {
    let englishG2P = EnglishG2P(british: true)
    let (result, _) = englishG2P.phonemize(text: "$50 is the price for this item")
    #expect(!result.isEmpty)
    #expect(result.contains("dˈɒlə"))
  }

  @Test func testRetokenize_CurrencyInMiddleOfSentence() {
    let englishG2P = EnglishG2P(british: false)
    let (result, _) = englishG2P.phonemize(text: "The total cost was $100 and we paid it yesterday")
    #expect(!result.isEmpty)
    #expect(result.contains("dˈɑləɹz"))
  }

  @Test func testRetokenize_MultipleCurrenciesInText() {
    let englishG2P = EnglishG2P(british: true)
    let (result, _) = englishG2P.phonemize(text: "I exchanged $200 for €150 at the bank today")
    #expect(!result.isEmpty)
    #expect(result.contains("dˈɒlə"))
    #expect(result.contains("jˈʊəɹQz"))
  }

  @Test func oovFallbackIsMemoizedAcrossRepeatedWords() {
    let g2p = EnglishG2P(british: false)
    let word = "Xyzzyqwertyblorple"

    let first = g2p.phonemize(text: word)
    let firstStats = g2p.consumeFallbackStats()
    let second = g2p.phonemize(text: word)
    let secondStats = g2p.consumeFallbackStats()

    #expect(first.0 == second.0)
    #expect(firstStats.lookups >= 1)
    #expect(firstStats.hits == 0)
    #expect(secondStats.lookups == firstStats.lookups)
    #expect(secondStats.hits == secondStats.lookups)
    #expect(secondStats.hits >= 1)
  }
}
#endif

import Foundation
import Testing
@testable import BlackOut

struct DateExtensionTests {

    @Test
    func timeAgoReturnsNonEmptyString() {
        let fiveMinutesAgo = Date().addingTimeInterval(-300)
        let result = fiveMinutesAgo.timeAgo(compare: fiveMinutesAgo)

        #expect(!result.isEmpty)
    }

    @Test
    func timeAgoForRecentDate() {
        let tenSecondsAgo = Date().addingTimeInterval(-10)
        let result = tenSecondsAgo.timeAgo(compare: tenSecondsAgo)

        #expect(!result.isEmpty)
    }

    @Test
    func timeAgoForOlderDate() {
        let twoDaysAgo = Date().addingTimeInterval(-172800)
        let result = twoDaysAgo.timeAgo(compare: twoDaysAgo)

        #expect(!result.isEmpty)
    }
}

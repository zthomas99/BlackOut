import Foundation
import Testing
@testable import BlackOut

struct AdviceTests {

    private func validDict(overrides: [String: Any] = [:]) -> [String: Any] {
        var dict: [String: Any] = [
            "username": "testUser",
            "date": "2026-04-17 00:00:00 +0000",
            "hasReply": false,
            "commentCount": 3,
            "comment": "some advice",
            "upVoters": ["a", "b"],
            "downVoters": ["c"]
        ]
        for (key, value) in overrides { dict[key] = value }
        return dict
    }

    @Test
    func initFromValidDict() {
        let advice = Advice(id: "id-1", dict: validDict())

        #expect(advice != nil)
        #expect(advice?.id == "id-1")
        #expect(advice?.user == "testUser")
        #expect(advice?.comment == "some advice")
        #expect(advice?.commentCount == 3)
        #expect(advice?.hasReply == false)
        #expect(advice?.upVoters == ["a", "b"])
        #expect(advice?.downVoters == ["c"])
        #expect(advice?.isExpanded == false)
        #expect(advice?.replies == nil)
    }

    @Test
    func initReturnsNilWhenMissingUsername() {
        var dict = validDict()
        dict.removeValue(forKey: "username")
        #expect(Advice(id: "id", dict: dict) == nil)
    }

    @Test
    func initReturnsNilWhenMissingDate() {
        var dict = validDict()
        dict.removeValue(forKey: "date")
        #expect(Advice(id: "id", dict: dict) == nil)
    }

    @Test
    func initReturnsNilWhenDateFormatInvalid() {
        let dict = validDict(overrides: ["date": "April 17, 2026"])
        #expect(Advice(id: "id", dict: dict) == nil)
    }

    @Test
    func initReturnsNilWhenMissingComment() {
        var dict = validDict()
        dict.removeValue(forKey: "comment")
        #expect(Advice(id: "id", dict: dict) == nil)
    }

    @Test
    func initReturnsNilWhenMissingHasReply() {
        var dict = validDict()
        dict.removeValue(forKey: "hasReply")
        #expect(Advice(id: "id", dict: dict) == nil)
    }

    @Test
    func initReturnsNilWhenMissingCommentCount() {
        var dict = validDict()
        dict.removeValue(forKey: "commentCount")
        #expect(Advice(id: "id", dict: dict) == nil)
    }

    @Test
    func votersAreOptional() {
        var dict = validDict()
        dict.removeValue(forKey: "upVoters")
        dict.removeValue(forKey: "downVoters")
        let advice = Advice(id: "id", dict: dict)

        #expect(advice != nil)
        #expect(advice?.upVoters == nil)
        #expect(advice?.downVoters == nil)
    }

    @Test
    func dateParsingProducesCorrectValue() {
        let advice = Advice(id: "id", dict: validDict())!
        let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.timeZone = TimeZone(secondsFromGMT: 0)
        components.year = 2026
        components.month = 4
        components.day = 17
        let expected = calendar.date(from: components)!

        #expect(calendar.isDate(advice.date, inSameDayAs: expected))
    }
}

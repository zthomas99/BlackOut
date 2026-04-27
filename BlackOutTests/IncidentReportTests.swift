import Foundation
import Testing
@testable import BlackOut

struct IncidentReportTests {

    private func validDict(overrides: [String: Any] = [:]) -> [String: Any] {
        var dict: [String: Any] = [
            "username": "reporter",
            "businessName": "Test Business",
            "descriptionMessage": "Something happened here",
            "reportTitle": "Test Report",
            "businessLocation": "123 Main St",
            "businessPhoto": "photo.jpg",
            "replyCount": 5,
            "date": "2026-04-17 12:30:00 +0000",
            "businessCity": "Springfield",
            "state": "IL",
            "zipCode": "62704"
        ]
        for (key, value) in overrides { dict[key] = value }
        return dict
    }

    @Test
    func initFromValidDict() {
        let report = IncidentReport(postId: "post-1", dict: validDict())

        #expect(report != nil)
        #expect(report?.postId == "post-1")
        #expect(report?.username == "reporter")
        #expect(report?.businessName == "Test Business")
        #expect(report?.descriptionMessage == "Something happened here")
        #expect(report?.reportTitle == "Test Report")
        #expect(report?.businessLocation == "123 Main St")
        #expect(report?.businessPhoto == "photo.jpg")
        #expect(report?.replyCount == 5)
        #expect(report?.businessCity == "Springfield")
        #expect(report?.state == "IL")
        #expect(report?.zipCode == "62704")
        #expect(report?.incidentMedia == nil)
    }

    @Test
    func initWithIncidentMedia() {
        let media: [String: [String]] = ["key1": ["img1.jpg", "img2.jpg"]]
        let report = IncidentReport(postId: "p", dict: validDict(overrides: ["incidentMedia": media]))

        #expect(report?.incidentMedia?["key1"] == ["img1.jpg", "img2.jpg"])
    }

    @Test
    func initReturnsNilWhenMissingUsername() {
        var dict = validDict()
        dict.removeValue(forKey: "username")
        #expect(IncidentReport(postId: "p", dict: dict) == nil)
    }

    @Test
    func initReturnsNilWhenMissingBusinessName() {
        var dict = validDict()
        dict.removeValue(forKey: "businessName")
        #expect(IncidentReport(postId: "p", dict: dict) == nil)
    }

    @Test
    func initReturnsNilWhenMissingDate() {
        var dict = validDict()
        dict.removeValue(forKey: "date")
        #expect(IncidentReport(postId: "p", dict: dict) == nil)
    }

    @Test
    func initReturnsNilWhenDateFormatInvalid() {
        let dict = validDict(overrides: ["date": "not-a-date"])
        #expect(IncidentReport(postId: "p", dict: dict) == nil)
    }

    @Test
    func initReturnsNilWhenMissingReplyCount() {
        var dict = validDict()
        dict.removeValue(forKey: "replyCount")
        #expect(IncidentReport(postId: "p", dict: dict) == nil)
    }

    @Test
    func initReturnsNilWhenMissingDescription() {
        var dict = validDict()
        dict.removeValue(forKey: "descriptionMessage")
        #expect(IncidentReport(postId: "p", dict: dict) == nil)
    }

    @Test
    func hashUsesPostId() {
        let a = IncidentReport(postId: "same", dict: validDict())!
        let b = IncidentReport(postId: "same", dict: validDict(overrides: ["username": "other"]))!

        #expect(a.hashValue == b.hashValue)
    }

    @Test
    func differentPostIdsProduceDifferentHashes() {
        let a = IncidentReport(postId: "id-1", dict: validDict())!
        let b = IncidentReport(postId: "id-2", dict: validDict())!

        #expect(a.hashValue != b.hashValue)
    }
}

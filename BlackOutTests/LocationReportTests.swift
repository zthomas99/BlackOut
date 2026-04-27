import Foundation
import Testing
@testable import BlackOut

struct LocationReportTests {

    private func validDict(overrides: [String: Any] = [:]) -> [String: Any] {
        var dict: [String: Any] = [
            "businessName": "Test Shop",
            "businessLocation": "456 Oak Ave",
            "businessCity": "Portland",
            "state": "OR",
            "zipCode": "97201",
            "incidentReports": ["report-1", "report-2"],
            "hasMediaFiles": true
        ]
        for (key, value) in overrides { dict[key] = value }
        return dict
    }

    @Test
    func initFromValidDict() {
        let location = LocationReport(postId: "loc-1", dict: validDict())

        #expect(location != nil)
        #expect(location?.postId == "loc-1")
        #expect(location?.businessName == "Test Shop")
        #expect(location?.businessLocation == "456 Oak Ave")
        #expect(location?.businessCity == "Portland")
        #expect(location?.state == "OR")
        #expect(location?.zipCode == "97201")
        #expect(location?.incidentReports == ["report-1", "report-2"])
        #expect(location?.hasMediaFiles == true)
        #expect(location?.profilePhotos == nil)
        #expect(location?.mediaList.isEmpty == true)
    }

    @Test
    func initParsesProfilePhotos() {
        let dict = validDict(overrides: ["profiles": ["pic1.jpg", "pic2.jpg"]])
        let location = LocationReport(postId: "loc", dict: dict)

        #expect(location?.profilePhotos == ["pic1.jpg", "pic2.jpg"])
    }

    @Test
    func initReturnsNilWhenMissingBusinessName() {
        var dict = validDict()
        dict.removeValue(forKey: "businessName")
        #expect(LocationReport(postId: "loc", dict: dict) == nil)
    }

    @Test
    func initReturnsNilWhenMissingIncidentReports() {
        var dict = validDict()
        dict.removeValue(forKey: "incidentReports")
        #expect(LocationReport(postId: "loc", dict: dict) == nil)
    }

    @Test
    func initReturnsNilWhenMissingHasMediaFiles() {
        var dict = validDict()
        dict.removeValue(forKey: "hasMediaFiles")
        #expect(LocationReport(postId: "loc", dict: dict) == nil)
    }

    @Test
    func initReturnsNilWhenMissingState() {
        var dict = validDict()
        dict.removeValue(forKey: "state")
        #expect(LocationReport(postId: "loc", dict: dict) == nil)
    }

    @Test
    func setMediaListUpdatesProperty() {
        var location = LocationReport(postId: "loc", dict: validDict())!
        #expect(location.mediaList.isEmpty)

        location.setMediaList(list: ["file1.jpg", "file2.mp4"])
        #expect(location.mediaList == ["file1.jpg", "file2.mp4"])
    }

    @Test
    func hashUsesPostId() {
        let a = LocationReport(postId: "same", dict: validDict())!
        let b = LocationReport(postId: "same", dict: validDict(overrides: ["businessName": "Other"]))!

        #expect(a.hashValue == b.hashValue)
    }

    @Test
    func designatedInitSetsAllFields() {
        let location = LocationReport(
            postId: "p1",
            businessLocation: "loc",
            businessName: "name",
            businessCity: "city",
            state: "ST",
            zipCode: "00000",
            incidentReports: ["r1"],
            hasMediaFiles: false,
            profilePhotos: ["photo.jpg"]
        )

        #expect(location.postId == "p1")
        #expect(location.businessName == "name")
        #expect(location.hasMediaFiles == false)
        #expect(location.profilePhotos == ["photo.jpg"])
    }
}

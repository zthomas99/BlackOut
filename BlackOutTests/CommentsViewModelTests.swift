import Foundation
import Testing
@testable import BlackOut

private final class MockCommentsService: CommentsViewModelServicing {
    var blockedUsersToReturn: [String] = []
    var addBlockedUserError: Error?
    var setVotersError: Error?

    var capturedBlockedUsername: String?
    var capturedPostId: String?
    var capturedAdviceId: String?
    var capturedUpVoters: [String]?
    var capturedDownVoters: [String]?

    func retrieveBlockedUsers(completion: @escaping ([String]) -> Void) {
        completion(blockedUsersToReturn)
    }

    func addBlockedUser(username: String, completion: @escaping (Error?) -> Void) {
        capturedBlockedUsername = username
        completion(addBlockedUserError)
    }

    func setVoters(postId: String, adviceId: String, upVoters: [String], downVoters: [String], completion: @escaping (Error?) -> Void) {
        capturedPostId = postId
        capturedAdviceId = adviceId
        capturedUpVoters = upVoters
        capturedDownVoters = downVoters
        completion(setVotersError)
    }
}

private func makeAdvice(upVoters: [String], downVoters: [String]) -> Advice {
    let dateString = "2026-04-17 00:00:00 +0000"
    let dict: [String: Any] = [
        "username": "userA",
        "date": dateString,
        "hasReply": false,
        "commentCount": 0,
        "comment": "comment",
        "upVoters": upVoters,
        "downVoters": downVoters
    ]

    return Advice(id: "advice-id", dict: dict)!
}

struct CommentsViewModelTests {

    @Test
    func applyUpVote_movesUserFromDownToUp() {
        let service = MockCommentsService()
        let sut = CommentsViewModel(databaseService: service, firestoreService: CommentService.shared)
        var advice = makeAdvice(upVoters: [], downVoters: ["u1"])

        sut.applyUpVote(to: &advice, userId: "u1")

        #expect(advice.upVoters == ["u1"])
        #expect(advice.downVoters?.isEmpty == true)
    }

    @Test
    func applyDownVote_movesUserFromUpToDown() {
        let service = MockCommentsService()
        let sut = CommentsViewModel(databaseService: service, firestoreService: CommentService.shared)
        var advice = makeAdvice(upVoters: ["u1"], downVoters: [])

        sut.applyDownVote(to: &advice, userId: "u1")

        #expect(advice.downVoters == ["u1"])
        #expect(advice.upVoters?.isEmpty == true)
    }

    @Test
    func retrieveBlockedUsers_forwardsServiceResponse() async {
        let service = MockCommentsService()
        service.blockedUsersToReturn = ["one", "two"]
        let sut = CommentsViewModel(databaseService: service, firestoreService: CommentService.shared)

        var result: [String] = []
        sut.retrieveBlockedUsers { users in
            result = users
        }

        #expect(result == ["one", "two"])
    }

    @Test
    func addBlockedUser_forwardsUsernameAndError() {
        let service = MockCommentsService()
        let expectedError = NSError(domain: "test", code: 1)
        service.addBlockedUserError = expectedError
        let sut = CommentsViewModel(databaseService: service, firestoreService: CommentService.shared)

        var completionError: Error?
        sut.addBlockedUser(username: "target") { error in
            completionError = error
        }

        #expect(service.capturedBlockedUsername == "target")
        #expect((completionError as NSError?)?.domain == "test")
        #expect((completionError as NSError?)?.code == 1)
    }

    @Test
    func setVoters_forwardsAdviceDataToService() {
        let service = MockCommentsService()
        let sut = CommentsViewModel(databaseService: service, firestoreService: CommentService.shared)
        let advice = makeAdvice(upVoters: ["up"], downVoters: ["down"])

        sut.setVoters(postId: "post-1", advice: advice) { _ in }

        #expect(service.capturedPostId == "post-1")
        #expect(service.capturedAdviceId == "advice-id")
        #expect(service.capturedUpVoters == ["up"])
        #expect(service.capturedDownVoters == ["down"])
    }
}

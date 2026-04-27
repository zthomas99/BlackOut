import Foundation
import Testing
@testable import BlackOut

private final class StubService: CommentsViewModelServicing {
    func retrieveBlockedUsers(completion: @escaping ([String]) -> Void) { completion([]) }
    func addBlockedUser(username: String, completion: @escaping (Error?) -> Void) { completion(nil) }
    func setVoters(postId: String, adviceId: String, upVoters: [String], downVoters: [String], completion: @escaping (Error?) -> Void) { completion(nil) }
}

private func makeAdvice(upVoters: [String] = [], downVoters: [String] = []) -> Advice {
    let dict: [String: Any] = [
        "username": "user",
        "date": "2026-04-17 00:00:00 +0000",
        "hasReply": false,
        "commentCount": 0,
        "comment": "test",
        "upVoters": upVoters,
        "downVoters": downVoters
    ]
    return Advice(id: "a1", dict: dict)!
}

private func makeSUT() -> CommentsViewModel {
    CommentsViewModel(databaseService: StubService(), firestoreService: CommentService.shared)
}

struct VoteLogicTests {

    // MARK: - applyUpVote

    @Test
    func upVote_addsUserToUpVoters() {
        let sut = makeSUT()
        var advice = makeAdvice()

        sut.applyUpVote(to: &advice, userId: "u1")

        #expect(advice.upVoters == ["u1"])
        #expect(advice.downVoters?.isEmpty == true)
    }

    @Test
    func upVote_removesUserFromDownVoters() {
        let sut = makeSUT()
        var advice = makeAdvice(downVoters: ["u1", "u2"])

        sut.applyUpVote(to: &advice, userId: "u1")

        #expect(advice.upVoters == ["u1"])
        #expect(advice.downVoters == ["u2"])
    }

    @Test
    func upVote_doesNotDuplicateIfAlreadyUpVoted() {
        let sut = makeSUT()
        var advice = makeAdvice(upVoters: ["u1"])

        sut.applyUpVote(to: &advice, userId: "u1")

        #expect(advice.upVoters == ["u1"])
    }

    @Test
    func upVote_preservesOtherVoters() {
        let sut = makeSUT()
        var advice = makeAdvice(upVoters: ["existing"], downVoters: ["other"])

        sut.applyUpVote(to: &advice, userId: "new")

        #expect(advice.upVoters == ["existing", "new"])
        #expect(advice.downVoters == ["other"])
    }

    // MARK: - applyDownVote

    @Test
    func downVote_addsUserToDownVoters() {
        let sut = makeSUT()
        var advice = makeAdvice()

        sut.applyDownVote(to: &advice, userId: "u1")

        #expect(advice.downVoters == ["u1"])
        #expect(advice.upVoters?.isEmpty == true)
    }

    @Test
    func downVote_removesUserFromUpVoters() {
        let sut = makeSUT()
        var advice = makeAdvice(upVoters: ["u1", "u2"])

        sut.applyDownVote(to: &advice, userId: "u1")

        #expect(advice.downVoters == ["u1"])
        #expect(advice.upVoters == ["u2"])
    }

    @Test
    func downVote_doesNotDuplicateIfAlreadyDownVoted() {
        let sut = makeSUT()
        var advice = makeAdvice(downVoters: ["u1"])

        sut.applyDownVote(to: &advice, userId: "u1")

        #expect(advice.downVoters == ["u1"])
    }

    @Test
    func downVote_preservesOtherVoters() {
        let sut = makeSUT()
        var advice = makeAdvice(upVoters: ["other"], downVoters: ["existing"])

        sut.applyDownVote(to: &advice, userId: "new")

        #expect(advice.downVoters == ["existing", "new"])
        #expect(advice.upVoters == ["other"])
    }

    // MARK: - Toggle behavior

    @Test
    func switchFromUpToDown() {
        let sut = makeSUT()
        var advice = makeAdvice(upVoters: ["u1"])

        sut.applyDownVote(to: &advice, userId: "u1")

        #expect(advice.upVoters?.isEmpty == true)
        #expect(advice.downVoters == ["u1"])
    }

    @Test
    func switchFromDownToUp() {
        let sut = makeSUT()
        var advice = makeAdvice(downVoters: ["u1"])

        sut.applyUpVote(to: &advice, userId: "u1")

        #expect(advice.downVoters?.isEmpty == true)
        #expect(advice.upVoters == ["u1"])
    }
}

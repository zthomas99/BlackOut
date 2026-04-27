//
//  CommentsViewModel.swift
//  BlackOut
//
//  Created by Codex on 4/17/26.
//

import Foundation
import FirebaseAuth

protocol CommentsViewModelServicing {
    func retrieveBlockedUsers(completion: @Sendable @escaping ([String]) -> Void)
    func addBlockedUser(username: String, completion: @Sendable @escaping (Error?) -> Void)
    func setVoters(postId: String, adviceId: String, upVoters: [String], downVoters:[String], completion: @Sendable @escaping (Error?) -> Void)
}

extension FireDatabaseService: CommentsViewModelServicing {}

final class CommentsViewModel: @unchecked Sendable {

    private final class SyncArray<T>: @unchecked Sendable {
        private let lock: NSLock
        private var _values = [T]()
        var values: [T] { lock.withLock { _values } }
        init(lock: NSLock) { self.lock = lock }
        func append(_ element: T) { lock.withLock { _values.append(element) } }
    }

    private let databaseService: CommentsViewModelServicing
    private let firestoreService: CommentService
    private let syncLock = NSLock()

    init(databaseService: CommentsViewModelServicing = FireDatabaseService.shared,
         firestoreService: CommentService = CommentService.shared) {
        self.databaseService = databaseService
        self.firestoreService = firestoreService
    }

    func retrieveBlockedUsers(completion: @Sendable @escaping ([String]) -> Void) {
        databaseService.retrieveBlockedUsers(completion: completion)
    }

    func addBlockedUser(username: String, completion: @Sendable @escaping (Error?) -> Void) {
        databaseService.addBlockedUser(username: username, completion: completion)
    }

    func currentUserId() -> String? {
        return Auth.auth().currentUser?.uid
    }

    func applyUpVote(to advice: inout Advice, userId: String) {
        if advice.downVoters?.contains(userId) == true {
            let removalIndex = advice.downVoters?.firstIndex(of: userId)
            if removalIndex != nil {
                advice.downVoters?.remove(at: removalIndex!)
            }
        }

        if advice.upVoters?.contains(userId) == false {
            advice.upVoters?.append(userId)
        }
    }

    func applyDownVote(to advice: inout Advice, userId: String) {
        if advice.upVoters?.contains(userId) == true {
            let removalIndex = advice.upVoters?.firstIndex(of: userId)
            if removalIndex != nil {
                advice.upVoters?.remove(at: removalIndex!)
            }
        }

        if advice.downVoters?.contains(userId) == false {
            advice.downVoters?.append(userId)
        }
    }

    func setVoters(postId: String, advice: Advice, completion: @Sendable @escaping (Error?) -> Void) {
        let newUpVoters = advice.upVoters ?? []
        let newDownVoters = advice.downVoters ?? []
        databaseService.setVoters(postId: postId, adviceId: advice.id, upVoters: newUpVoters, downVoters: newDownVoters, completion: completion)
    }

    func retrieveAdvice(postId: String, adviceId: String, blockedUsers: [String], completion: @Sendable @escaping (Advice?) -> Void) {
        firestoreService.commentReference.document(postId).collection("Advices").document(adviceId).getDocument(completion: {
            (document, error)
            in
            if error != nil {
                completion(nil)
                return
            }

            guard let document = document, let data = document.data(), let adviceData = Advice(id: document.documentID, dict: data) else {
                completion(nil)
                return
            }

            if blockedUsers.contains(adviceData.user) {
                completion(nil)
                return
            }

            if adviceData.hasReply {
                self.retrieveReplies(postId: postId, adviceId: adviceData.id, blockedUsers: blockedUsers, completion: {
                    (replies)
                    in
                    var advice = adviceData
                    advice.replies = replies
                    advice.isExpanded = true
                    completion(advice)
                })
            } else {
                completion(adviceData)
            }
        })
    }

    func retrieveAdvices(postId: String, blockedUsers: [String], completion: @Sendable @escaping ([Advice]) -> Void) {
        firestoreService.commentReference.document(postId).collection("Advices").getDocuments {
            (snapshot, error)
            in
            if error != nil {
                completion([])
                return
            }

            guard let documents = snapshot?.documents else {
                completion([])
                return
            }

            if documents.count == 0 {
                completion([])
                return
            }

            let collectedAdvices = SyncArray<Advice>(lock: self.syncLock)
            let group = DispatchGroup()

            for document in documents {
                guard let adviceData = Advice(id: document.documentID, dict: document.data()) else {
                    continue
                }

                if blockedUsers.contains(adviceData.user) {
                    continue
                }

                if adviceData.hasReply {
                    group.enter()
                    self.retrieveReplies(postId: postId, adviceId: adviceData.id, blockedUsers: blockedUsers, completion: {
                        (replies)
                        in
                        var advice = adviceData
                        advice.replies = replies
                        collectedAdvices.append(advice)
                        group.leave()
                    })
                } else {
                    collectedAdvices.append(adviceData)
                }
            }

            group.notify(queue: .main) {
                let sortedAdvices = collectedAdvices.values.sorted(by: { $0.date < $1.date })
                completion(sortedAdvices)
            }
        }
    }

    private func retrieveReplies(postId: String, adviceId: String, blockedUsers: [String], completion: @Sendable @escaping ([Reply]) -> Void) {
        let replyReference = firestoreService.commentReference.document(postId).collection("Advices").document(adviceId).collection("Replies")

        replyReference.getDocuments() {
            (snapshot, err)
            in
            if err != nil {
                completion([])
                return
            }

            guard let documents = snapshot?.documents else {
                completion([])
                return
            }

            var replies = [Reply]()
            for document in documents {
                let reply = Reply(id: document.documentID, reference: document.reference, dict: document.data())
                if reply != nil && !blockedUsers.contains(reply!.user) {
                    replies.append(reply!)
                }
            }

            let sortedReplies = replies.sorted(by: { $0.date < $1.date })
            completion(sortedReplies)
        }
    }
}

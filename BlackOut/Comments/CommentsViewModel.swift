//
//  CommentsViewModel.swift
//  BlackOut
//
//  Created by Codex on 4/17/26.
//

import Foundation
import FirebaseAuth

protocol CommentsViewModelServicing {
    func RetrieveBlockedUsers(completion: @escaping ([String]) -> Void)
    func AddBlockedUser(username: String, completion: @escaping (Error?) -> Void)
    func SetVoters(postId: String, adviceId: String, upVoters: [String], downVoters:[String], completion: @escaping (Error?) -> Void)
}

extension FireDatabaseService: CommentsViewModelServicing {}

final class CommentsViewModel {

    private let databaseService: CommentsViewModelServicing
    private let firestoreService: FireDatabaseService
    private let syncLock = NSLock()

    init(databaseService: CommentsViewModelServicing = FireDatabaseService.shared,
         firestoreService: FireDatabaseService = FireDatabaseService.shared) {
        self.databaseService = databaseService
        self.firestoreService = firestoreService
    }

    func retrieveBlockedUsers(completion: @escaping ([String]) -> Void) {
        databaseService.RetrieveBlockedUsers(completion: completion)
    }

    func addBlockedUser(username: String, completion: @escaping (Error?) -> Void) {
        databaseService.AddBlockedUser(username: username, completion: completion)
    }

    func currentUserId() -> String? {
        return Auth.auth().currentUser?.uid
    }

    func applyUpVote(to advice: inout Advice, userId: String) {
        if advice.downVoters?.contains(userId) == true {
            let removalIndex = advice.downVoters?.index(of: userId)
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
            let removalIndex = advice.upVoters?.index(of: userId)
            if removalIndex != nil {
                advice.upVoters?.remove(at: removalIndex!)
            }
        }

        if advice.downVoters?.contains(userId) == false {
            advice.downVoters?.append(userId)
        }
    }

    func setVoters(postId: String, advice: Advice, completion: @escaping (Error?) -> Void) {
        let newUpVoters = advice.upVoters ?? []
        let newDownVoters = advice.downVoters ?? []
        databaseService.SetVoters(postId: postId, adviceId: advice.id, upVoters: newUpVoters, downVoters: newDownVoters, completion: completion)
    }

    func retrieveAdvice(postId: String, adviceId: String, blockedUsers: [String], completion: @escaping (Advice?) -> Void) {
        firestoreService.commentReference.document(postId).collection("Advices").document(adviceId).getDocument(completion: {
            (document, error)
            in
            if let err = error {
                print("Failed to retrieve advice for post id \(postId) with error \(err)")
                completion(nil)
                return
            }

            guard let document = document, let data = document.data(), var advice = Advice(id: document.documentID, dict: data) else {
                completion(nil)
                return
            }

            if blockedUsers.contains(advice.user) {
                completion(nil)
                return
            }

            if advice.hasReply {
                self.retrieveReplies(postId: postId, adviceId: advice.id, blockedUsers: blockedUsers, completion: {
                    (replies)
                    in
                    advice.replies = replies
                    advice.isExpanded = true
                    completion(advice)
                })
            } else {
                completion(advice)
            }
        })
    }

    func retrieveAdvices(postId: String, blockedUsers: [String], completion: @escaping ([Advice]) -> Void) {
        firestoreService.commentReference.document(postId).collection("Advices").getDocuments {
            (snapshot, error)
            in
            if let err = error {
                print("Failed to retrieve advices for post id \(postId) with error \(err)")
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

            var collectedAdvices = [Advice]()
            let group = DispatchGroup()

            for document in documents {
                guard var advice = Advice(id: document.documentID, dict: document.data()) else {
                    continue
                }

                if blockedUsers.contains(advice.user) {
                    continue
                }

                if advice.hasReply {
                    group.enter()
                    self.retrieveReplies(postId: postId, adviceId: advice.id, blockedUsers: blockedUsers, completion: {
                        (replies)
                        in
                        advice.replies = replies
                        self.syncLock.lock()
                        collectedAdvices.append(advice)
                        self.syncLock.unlock()
                        group.leave()
                    })
                } else {
                    collectedAdvices.append(advice)
                }
            }

            group.notify(queue: .main) {
                let sortedAdvices = collectedAdvices.sorted(by: { $0.date < $1.date })
                completion(sortedAdvices)
            }
        }
    }

    private func retrieveReplies(postId: String, adviceId: String, blockedUsers: [String], completion: @escaping ([Reply]) -> Void) {
        let replyReference = firestoreService.commentReference.document(postId).collection("Advices").document(adviceId).collection("Replies")
        var replies = [Reply]()

        replyReference.getDocuments() {
            (snapshot, err)
            in
            if let err = err {
                print("Failed to retrieve reply documents with the following error \(err)")
                completion(replies)
                return
            }

            guard let documents = snapshot?.documents else {
                completion(replies)
                return
            }

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

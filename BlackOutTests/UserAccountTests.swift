import Foundation
import Testing
@testable import BlackOut

struct UserAccountTests {

    @Test
    func initFromValidDict() {
        let dict: [String: Any] = [
            "username": "testuser",
            "blockedUsers": ["blocked1", "blocked2"],
            "fcmTokens": ["token1"]
        ]
        let account = UserAccount(id: "uid-123", dict: dict)

        #expect(account != nil)
        #expect(account?.id == "uid-123")
        #expect(account?.username == "testuser")
        #expect(account?.blockedUsers == ["blocked1", "blocked2"])
        #expect(account?.fcmTokens == ["token1"])
    }

    @Test
    func initReturnsNilWhenMissingUsername() {
        let dict: [String: Any] = [
            "blockedUsers": ["a"]
        ]
        #expect(UserAccount(id: "uid", dict: dict) == nil)
    }

    @Test
    func initDefaultsFcmTokensWhenMissing() {
        let dict: [String: Any] = [
            "username": "user",
            "blockedUsers": []
        ]
        let account = UserAccount(id: "uid", dict: dict)

        #expect(account != nil)
        #expect(account?.fcmTokens.isEmpty == true)
    }

    @Test
    func initParsesFcmTokens() {
        let dict: [String: Any] = [
            "username": "user",
            "blockedUsers": [],
            "fcmTokens": ["t1", "t2", "t3"]
        ]
        let account = UserAccount(id: "uid", dict: dict)

        #expect(account?.fcmTokens == ["t1", "t2", "t3"])
    }
}

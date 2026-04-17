# iOS Security

> This file extends [common/security.md](../common/security.md) and [swift/security.md](../swift/security.md) with iOS-specific content.

## Secrets Management

- Never hardcode API keys or tokens in source files
- Use Xcode build configuration files (`.xcconfig`) and inject via `Info.plist` entries
- Store sensitive data in the iOS Keychain via `Security` framework or `KeychainAccess`

```swift
import Security

func saveToken(_ token: String, for key: String) throws {
    let data = Data(token.utf8)
    let query: [CFString: Any] = [
        kSecClass: kSecClassGenericPassword,
        kSecAttrAccount: key,
        kSecValueData: data,
        kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
    ]
    SecItemDelete(query as CFDictionary)
    let status = SecItemAdd(query as CFDictionary, nil)
    guard status == errSecSuccess else { throw KeychainError.saveFailed(status) }
}
```

## Network Security

- Enforce App Transport Security (ATS); avoid `NSAllowsArbitraryLoads` exceptions
- Pin certificates for high-security endpoints using `URLSessionDelegate`

```swift
extension NetworkClient: URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard
            challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            let serverTrust = challenge.protectionSpace.serverTrust,
            validateCertificatePin(serverTrust)
        else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        completionHandler(.useCredential, URLCredential(trust: serverTrust))
    }
}
```

## Data Protection

- Set file protection class when writing sensitive files: `FileManager.default.createFile(atPath:contents:attributes: [FileAttributeKey.protectionKey: FileProtectionType.complete])`
- Use `@AppStorage` only for non-sensitive preferences; use Keychain for credentials
- Clear sensitive in-memory state on `sceneDidEnterBackground`

## Privacy

- Declare all required permission strings in `Info.plist` (`NSCameraUsageDescription`, etc.)
- Request permissions lazily — only when the feature is first used
- Respect `ATTrackingManager` for IDFA access (iOS 14.5+)

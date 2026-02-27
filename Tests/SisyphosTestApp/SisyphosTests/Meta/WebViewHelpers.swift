import SwiftUI
import WebKit
import AuthenticationServices

/// A WKWebView wrapper that lets us set `accessibilityIdentifier` directly on the WKWebView element,
/// which SwiftUI's `.accessibilityIdentifier()` modifier does not propagate to.
@available(iOS 16.4, *)
struct IdentifiableWebView: UIViewRepresentable {
    let url: URL
    let accessibilityId: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.accessibilityIdentifier = accessibilityId
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}
}

@available(iOS 16.4, *)
struct AuthSessionTrigger: UIViewControllerRepresentable {
    let url: URL
    let callbackURLScheme: String

    func makeUIViewController(context: Context) -> AuthSessionViewController {
        AuthSessionViewController(url: url, callbackURLScheme: callbackURLScheme)
    }

    func updateUIViewController(_ vc: AuthSessionViewController, context: Context) {}
}

@available(iOS 16.4, *)
class AuthSessionViewController: UIViewController, ASWebAuthenticationPresentationContextProviding {
    let url: URL
    let callbackURLScheme: String
    private var session: ASWebAuthenticationSession?
    private var hasStarted = false

    init(url: URL, callbackURLScheme: String) {
        self.url = url
        self.callbackURLScheme = callbackURLScheme
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasStarted else { return }
        hasStarted = true
        let session = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: callbackURLScheme
        ) { _, _ in }
        session.prefersEphemeralWebBrowserSession = true
        session.presentationContextProvider = self
        session.start()
        self.session = session
    }

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        view.window!
    }
}

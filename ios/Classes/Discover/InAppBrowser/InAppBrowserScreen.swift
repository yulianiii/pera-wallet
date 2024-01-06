// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   InAppBrowserScreen.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonUtils
import WebKit

/// @abstract
/// <todo>
/// How to prevent the standalone usage ???
class InAppBrowserScreen<ScriptMessage>:
    BaseViewController,
    WKNavigationDelegate,
    NotificationObserver,
    WKUIDelegate,
    WKScriptMessageHandler
where ScriptMessage: InAppBrowserScriptMessage {
    var allowsPullToRefresh: Bool = true
    
    var notificationObservations: [NSObjectProtocol] = []
    
    private(set) lazy var webView: WKWebView = createWebView()
    private(set) lazy var noContentView = InAppBrowserNoContentView(theme.noContent)

    private(set) lazy var userContentController = createUserContentController()

    private(set) var userAgent: String? = nil
    private(set) var fakeUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"

    private var sourceURL: URL?

    private var isViewLayoutLoaded = false

    private var lastURL: URL? { webView.url ?? sourceURL }

    private let theme = InAppBrowserScreenTheme()
    private let socialMediaDeeplinkParser = DiscoverSocialMediaRouter()

    deinit {
        userContentController.removeAllScriptMessageHandlers()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if view.bounds.isEmpty { return }

        if !isViewLayoutLoaded {
            updateUIForLoading()
            isViewLayoutLoaded = true
        }
    }

    func createWebView() -> WKWebView {
        let configuration = createWebViewConfiguration()
        let webView = WKWebView(
            frame: .zero,
            configuration: configuration
        )
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.allowsLinkPreview = false
        return webView
    }

    func createWebViewConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        configuration.userContentController = userContentController
        configuration.preferences = WKPreferences()
        return configuration
    }

    func createUserContentController() -> InAppBrowserUserContentController {
        let controller = InAppBrowserUserContentController()
        let selectionString  = """
        var css = '*{-webkit-touch-callout:none;-webkit-user-select:none}textarea,input{user-select:text;-webkit-user-select:text;}';
        var head = document.head || document.getElementsByTagName('head')[0];
        var style = document.createElement('style'); style.type = 'text/css';
        style.appendChild(document.createTextNode(css)); head.appendChild(style);
        """
        let selectionScript = WKUserScript(
            source: selectionString,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        controller.addUserScript(selectionScript)
        ScriptMessage.allCases.forEach {
            controller.add(
                secureScriptMessageHandler: self,
                forMessage: $0
            )
        }
        return controller
    }

    func updateUIForLoading() {
        let state = InAppBrowserNoContentView.State.loading(theme.loading)
        updateUI(for: state)
    }

    func updateUIForURL() {
        let clearNoContent = {
            [weak self] in
            guard let self else { return }

            self.noContentView.setState(
                nil,
                animated: false
            )
        }

        if !webView.isHidden {
            clearNoContent()
            return
        }

        updateUI(
            from: noContentView,
            to: webView,
            animated: isViewAppeared
        ) { isCompleted in
            if !isCompleted { return }
            clearNoContent()
        }
    }

    func updateUIForError(_ error: Error) {
        defer {
            endRefreshingIfNeeded()
        }

        if !isPresentable(error) {
            updateUIForURL()
            return
        }

        let viewModel = InAppBrowserErrorViewModel(error: error)
        let state = InAppBrowserNoContentView.State.error(theme.error, viewModel)
        updateUI(for: state)
    }

    @objc
    func didPullToRefresh() {
        webView.reload()
    }

    /// <mark>
    /// WKNavigationDelegate
    func webView(
        _ webView: WKWebView,
        didStartProvisionalNavigation navigation: WKNavigation!
    ) {
        updateUIForLoading()
    }

    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        updateUIForError(error)
    }

    func webView(
        _ webView: WKWebView,
        didFinish navigation: WKNavigation!
    ) {
        updateUIForURL()
        endRefreshingIfNeeded()
    }

    func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: Error
    ) {
        updateUIForError(error)
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        preferences: WKWebpagePreferences,
        decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void
    ) {
        guard var url = navigationAction.request.url else {
            decisionHandler(.cancel, preferences)
            return
        }
       
        url = URL(string: url.absoluteString.replacingOccurrences(of: "defly-wc:", with: "algorand-wc:")) ?? url

        if !url.absoluteString.contains("discover-mobile.perawallet.app") {
            webView.customUserAgent = fakeUserAgent
        } else {
            webView.customUserAgent = userAgent
        }

        let policy: WKNavigationActionPolicy
        if url.isMailURL {
            policy = navigateToMail(url)
        } else if let socialMediaURL = socialMediaDeeplinkParser.route(url: url) {
            policy = navigateToSocialMedia(socialMediaURL)
        } else if let walletConnectSessionURL = DeeplinkQR(url: url).walletConnectUrl() {
            policy = navigateToWalletConnectSession(walletConnectSessionURL)
        } else {
            policy = url.isWebURL ? .allow : .cancel
        }

        decisionHandler(policy, preferences)
    }

    /// <mark>
    /// WKUIDelegate
    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }

        return nil
    }

    /// <mark>
    /// WKScriptMessageHandler
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {}
}

extension InAppBrowserScreen {
    func load(url: URL?) {
        guard let url = url else {
            return
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        webView.load(request)

        sourceURL = url
    }
}

extension InAppBrowserScreen {
    private func endRefreshingIfNeeded() {
        if !allowsPullToRefresh { return }

        webView.scrollView.refreshControl?.endRefreshing()
    }
}

extension InAppBrowserScreen {
    private func addUI() {
        addBackground()
        addWebView()
        addNoContent()
    }

    private func updateUI(for state: InAppBrowserNoContentView.State) {
        let isNoContentVisible = !noContentView.isHidden

        noContentView.setState(
            state,
            animated: isViewAppeared && isNoContentVisible
        )

        if isNoContentVisible { return }

        updateUI(
            from: webView,
            to: noContentView,
            animated: isViewAppeared
        )
    }

    private typealias UpdateUICompletion = (Bool) -> Void
    private func updateUI(
        from fromView: UIView,
        to toView: UIView,
        animated: Bool,
        completion: UpdateUICompletion? = nil
    ) {
        UIView.transition(
            from: fromView,
            to: toView,
            duration: animated ? 0.3 : 0,
            options: [.transitionCrossDissolve, .showHideTransitionViews],
            completion: completion
        )
    }

    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addWebView() {
        /// <note>
        /// The transition state should be maintained manually at the beginning because both views
        /// are being added so it won't be detected that which view is actually visible. It seems
        /// like `isHidden` property is the only way to prevent unnecessary transition.
        webView.isHidden = true

        view.addSubview(webView)
        webView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        if let userAgent {
            webView.customUserAgent = userAgent
        }

        webView.navigationDelegate = self
        webView.uiDelegate = self

        addRefreshControlIfNeeded()
    }

    private func addRefreshControlIfNeeded() {
        if !allowsPullToRefresh { return }

        let refreshControl = UIRefreshControl()
        webView.scrollView.refreshControl = refreshControl

        refreshControl.addTarget(
            self,
            action: #selector(didPullToRefresh),
            for: .valueChanged
        )
    }

    private func addNoContent() {
        view.addSubview(noContentView)
        noContentView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        noContentView.startObserving(event: .retry) {
            [unowned self] in
            self.load(url: self.lastURL)
        }
    }
}

extension InAppBrowserScreen {
    private func isPresentable(_ error: Error) -> Bool {
        guard let urlError = error as? URLError else { return true }
        return urlError.code != .cancelled
    }
}

extension InAppBrowserScreen {
    private func navigateToMail(_ url: URL) -> WKNavigationActionPolicy {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }

        return .cancel
    }

    private func navigateToSocialMedia(_ url: URL) -> WKNavigationActionPolicy {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }

        return .cancel
    }

    private func navigateToWalletConnectSession(_ url: URL) -> WKNavigationActionPolicy {
        let src: DeeplinkSource = .walletConnectSessionRequestForDiscover(url)
        launchController.receive(deeplinkWithSource: src)
        return .cancel
    }
}

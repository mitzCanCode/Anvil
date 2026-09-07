//
//  InAppBrowserView.swift
//  DevPoint
//
//  Created by mitz on 24/8/26.
//

import SwiftUI
import WebKit

struct InAppBrowserView: View {
    let url: URL

    @Environment(\.dismiss) private var dismiss
    @State private var pageTitle: String = "Loading..."
    @State private var isLoading = true
    @State private var estimatedProgress: Double = 0
    @State private var canGoBack = false
    @State private var canGoForward = false
    @State private var currentURL: URL?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if isLoading {
                    ProgressView(value: estimatedProgress)
                        .progressViewStyle(.linear)
                        .tint(.accentColor)
                }

                WebView(
                    url: url,
                    pageTitle: $pageTitle,
                    isLoading: $isLoading,
                    estimatedProgress: $estimatedProgress,
                    canGoBack: $canGoBack,
                    canGoForward: $canGoForward,
                    currentURL: $currentURL
                )
            }
            .navigationTitle(pageTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }

                ToolbarItemGroup(placement: .bottomBar) {
                    Button {
                        NotificationCenter.default.post(name: .webViewGoBack, object: nil)
                    } label: {
                        Image(systemName: "chevron.backward")
                    }
                    .disabled(!canGoBack)

                    Button {
                        NotificationCenter.default.post(name: .webViewGoForward, object: nil)
                    } label: {
                        Image(systemName: "chevron.forward")
                    }
                    .disabled(!canGoForward)

                    Spacer()

                    Button {
                        NotificationCenter.default.post(name: .webViewReload, object: nil)
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
}

private extension Notification.Name {
    static let webViewGoBack = Notification.Name("DevPoint.WebView.goBack")
    static let webViewGoForward = Notification.Name("DevPoint.WebView.goForward")
    static let webViewReload = Notification.Name("DevPoint.WebView.reload")
}

private struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var pageTitle: String
    @Binding var isLoading: Bool
    @Binding var estimatedProgress: Double
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool
    @Binding var currentURL: URL?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        context.coordinator.observe(webView)
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // Navigation is driven by user actions / initial load.
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        private let parent: WebView
        private var observations: [NSKeyValueObservation] = []
        private var notificationTokens: [NSObjectProtocol] = []
        private weak var webView: WKWebView?

        init(_ parent: WebView) {
            self.parent = parent
        }

        deinit {
            observations.forEach { $0.invalidate() }
            notificationTokens.forEach { NotificationCenter.default.removeObserver($0) }
        }

        func observe(_ webView: WKWebView) {
            self.webView = webView

            observations = [
                webView.observe(\.isLoading, options: [.new]) { [weak self] webView, _ in
                    DispatchQueue.main.async {
                        self?.parent.isLoading = webView.isLoading
                    }
                },
                webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
                    DispatchQueue.main.async {
                        self?.parent.estimatedProgress = webView.estimatedProgress
                    }
                },
                webView.observe(\.title, options: [.new]) { [weak self] webView, _ in
                    DispatchQueue.main.async {
                        self?.parent.pageTitle = webView.title?.isEmpty == false
                            ? (webView.title ?? "Browser")
                            : (webView.url?.host ?? "Browser")
                    }
                },
                webView.observe(\.canGoBack, options: [.new]) { [weak self] webView, _ in
                    DispatchQueue.main.async {
                        self?.parent.canGoBack = webView.canGoBack
                    }
                },
                webView.observe(\.canGoForward, options: [.new]) { [weak self] webView, _ in
                    DispatchQueue.main.async {
                        self?.parent.canGoForward = webView.canGoForward
                    }
                },
                webView.observe(\.url, options: [.new]) { [weak self] webView, _ in
                    DispatchQueue.main.async {
                        self?.parent.currentURL = webView.url
                    }
                }
            ]

            let center = NotificationCenter.default
            notificationTokens = [
                center.addObserver(forName: .webViewGoBack, object: nil, queue: .main) { [weak self] _ in
                    self?.webView?.goBack()
                },
                center.addObserver(forName: .webViewGoForward, object: nil, queue: .main) { [weak self] _ in
                    self?.webView?.goForward()
                },
                center.addObserver(forName: .webViewReload, object: nil, queue: .main) { [weak self] _ in
                    self?.webView?.reload()
                }
            ]
        }
    }
}

#Preview {
    InAppBrowserView(url: URL(string: "https://example.com")!)
}

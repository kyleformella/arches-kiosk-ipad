// comment

import SwiftUI
import WebKit

struct ContentView: View {
    @ObservedObject var webViewModel = WebViewModel(url: "https://osf-kiosk-app.web.app")
    //@State var webViewContainer = WebViewContainer()
    
    var body: some View {
        NavigationView {
            ZStack {
                WebViewContainer(webViewModel: webViewModel)
                if webViewModel.isLoading {
                    ProgressView()
                        .frame(height: 30)
                }
            }
            .navigationBarTitle(Text(webViewModel.title), displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                webViewModel.shouldGoBack.toggle()
            }, label: {
                if webViewModel.canGoBack {
                    Image(systemName: "arrow.left")
                        .frame(width: 64, height: 64, alignment: .center)
                        .foregroundColor(.black)
                } else {
                    EmptyView()
                        .frame(width: 0, height: 0, alignment: .center)
                }
            }),
                trailing: Button(action: {
                    // Call the function to reset to the default page
                    webViewModel.loadHomepage()
                }) {
                    Image(systemName: "house")
                        .frame(width: 64, height: 64, alignment: .center)
                        .foregroundColor(.black)
                }
            )
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

extension WebViewContainer {
    class Coordinator: NSObject, WKNavigationDelegate {
        @ObservedObject private var webViewModel: WebViewModel
        private let parent: WebViewContainer
        
        init(_ parent: WebViewContainer, _ webViewModel: WebViewModel) {
            self.parent = parent
            self.webViewModel = webViewModel
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            webViewModel.isLoading = true
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webViewModel.isLoading = false
            webViewModel.title = webView.title ?? ""
            webViewModel.canGoBack = webView.canGoBack
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            webViewModel.isLoading = false
        }
    }
    static func clearCache() {
        let websiteDataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        let date = Date(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes, modifiedSince: date) {}
        print("cache has been cleared!!!!!!!!")
    }
}

struct WebViewContainer: UIViewRepresentable {
    @ObservedObject var webViewModel: WebViewModel
    //var webView: WKWebView = WKWebView()
    
    func makeCoordinator() -> WebViewContainer.Coordinator {
        Coordinator(self, webViewModel)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        guard let url = URL(string: self.webViewModel.url) else {
            return WKWebView()
        }
        
        let request = URLRequest(url: url)
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(request)
        
        return webView
    }
    
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if webViewModel.shouldGoBack {
            uiView.goBack()
            webViewModel.shouldGoBack = false
        }
    }
}

class WebViewModel: NSObject, ObservableObject, WKNavigationDelegate {
    @Published var isLoading: Bool = false
    @Published var canGoBack: Bool = false
    @Published var shouldGoBack: Bool = false
    @Published var title: String = ""
    @Published var currentURL: URL
    
    var timer: Timer?
    var runCount = 0
    var webView: WKWebView?
    var url: String
    
    init(url: String) {
        self.url = url
        self.currentURL = URL(string: url)!
        print("Timer is started")
    }
    
    
    func startTimer() {
        timer = .scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
        // Do whatever
        self.runCount += 1

        if self.runCount == 120 {
            print("FUNCTION I WANT TO TRIGGER WHEN TIMER REACHES 120 SECONDS")
            //ContentView.tabs.remove(at: 1)
            WebViewContainer.clearCache()
            //self.resetTimer()
            }
      
        })
    }

    func resetTimer() {
        timer?.invalidate()
        runCount = 0
            
        startTimer()
    }
    
    func goHome() {
            webView?.reload()
                print("the whole thing should have completed")
            
        objectWillChange.send()
        }
    
    func loadHomepage() {
        url = "https://osf-kiosk-app.web.app"
        canGoBack = false
        //return url
    }
    func resetToDefaultPage() {
        //goHome()
        let defaultURLString = "https://example.com"  // Replace with your default URL
            self.currentURL = URL(string: defaultURLString)!
            print("goHome should have called")
        }
}

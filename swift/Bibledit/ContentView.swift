import SwiftUI
import WebKit

let web_view = WebView()

struct ContentView: View {
    
    var body: some View {
        VStack {
            // main webview
            web_view
        }
        .onAppear(){

            // When the webview appears, it shows a "loading" splash screen.
            let index_html_path : String = Bundle.main.path(forResource: "loading", ofType: "html")!
            let index_html_url : URL = URL(fileURLWithPath: index_html_path)
            web_view.loadURL(urlString: String(describing: index_html_url))

            // The file URL where the app has stored its resources.
            print ("Resources URL", resources_url())
            
            // Any iOS app gets a slice of storage just for itself.
            // This is called the documents directory.
            // It is read-write storage.
            print ("Documents URL", documents_url())
            
            print ("Webroot URL", webroot_url())

            print ("Bibledit kernel version", kernel_software_version())
            print ("Installed webroot version", get_installed_webroot_version())
            if (kernel_software_version() != get_installed_webroot_version()) {
                print ("Copy the resources to the webroot")
                // Run a task that may take long as a background thread.
                DispatchQueue.global(qos: .background).async {
                    // Copy the relevant sources to the writable webroot.
                    copy_resources_to_webroot()
                    // Update installed version number.
                    set_installed_webroot_version(version: kernel_software_version())
                    // Once done, update the UI on the main thread.
                    DispatchQueue.main.async {
                        web_view.loadURL(urlString: get_server_url_string())
                    }
                }
            } else {
                web_view.loadURL(urlString: get_server_url_string())
            }
        }
        .onDisappear(){
        }
    }
}

struct WebView: UIViewRepresentable {
    
    let webView: WKWebView
    
    init() {
        self.webView = WKWebView()
        
    }
    
    func makeUIView(context: Context) -> WKWebView {
        webView.allowsBackForwardNavigationGestures = true
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        
    }
    
    func goBack(){
        webView.goBack()
    }
    
    func goForward(){
        webView.goForward()
    }
    
    func loadURL(urlString: String) {
        webView.load(URLRequest(url: URL(string: urlString)!))
    }
}


/*
struct ContentView: View {
  
    // With @State before a property, it indicates to SwiftUI that, when that state changes, SwiftUI knows to automatically reload the view with the latest changes so it can reflect its new information.
    @State private var current_date = Date.now
    
    // Use .main for the runloop option, because the timer will update the user interface.
    // The .common mode allows the timer to run alongside other common events,
    // for example, if the text was in a scroll view that was moving.
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View
    {
        VStack
        {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("\(current_date)")
            // The onReceive() closure gets passed in some input containing the current date.
                .onReceive(timer) { input in
                    current_date = input
                }
            Text(String(cString: jesus_saves()))
            Text(String(cString: trust_jesus()))
            // This opens the link in a browser.
            Link("Bibledit demo", destination: URL(string: "https://bibledit.org:8091")!)
        }
        .padding()
    }
}
*/
 
//#Preview {
//    ContentView()
//}

//struct WebView: UIViewRepresentable {
//    
//    let webView: WKWebView
//    
//    init() {
//        webView = WKWebView(frame: .zero)
//        webView.allowsBackForwardNavigationGestures = true
//        
//    }
//    
//    func makeUIView(context: Context) -> WKWebView {
//        return webView
//    }
//    func updateUIView(_ uiView: WKWebView, context: Context) {
//        webView.load(URLRequest(url: URL(string: "https://bibledit.org:8091")!))
//    }
//}

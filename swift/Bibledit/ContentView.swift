import SwiftUI
import WebKit

let web_view = WebView()

struct ContentView: View {
    
    @State var urlString = "https://bibledit.org:8091"
    
    var body: some View {
        VStack {
            // main webview
            web_view
        }
        .onAppear(){
            print (String(cString: jesus_saves()))
            
            
            // Information about bundles:
            // https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/Introduction/Introduction.html

            let index_html_path : String = Bundle.main.path(forResource: "index", ofType: "html")!
            print (index_html_path)
            
            let index_html_url : URL = URL(fileURLWithPath: index_html_path)
            print (index_html_url)
            
            urlString = String(describing: index_html_url)
            
            let resource_path = Bundle.main.resourcePath!
            print (resource_path)
            
            
            let file_manager = FileManager.default
            do {
                let items = try file_manager.contentsOfDirectory(atPath: resource_path)
                for item in items {
                    print (item)
                }
            }
            catch {
            }
            

            // This iOS app gets a slice of storage just for itself.
            // This is called the documents directory.
            // It is read-write storage.
            let paths = file_manager.urls(for: .documentDirectory, in: .userDomainMask)
            let documents_directory = paths.first!
            print (documents_directory)
            
            

            
            
          
            
            web_view.loadURL(urlString: urlString)
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
    
//    func onLoginAction() {
//        print("submitting")
//    }

}


//struct ContentView: View {
//    var body: some View {
//        WebView()
//    }
//}

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

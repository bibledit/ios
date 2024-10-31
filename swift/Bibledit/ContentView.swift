import SwiftUI
import WebKit

let web_view = WebView()

struct ContentView: View {
    
    @State var urlString = "https://bibledit.org:8091"
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    web_view.goBack()
                }){
                    Image(systemName: "arrow.backward")
                        .font(.title)
                        .padding()
                }
                
                TextField("Enter url", text: $urlString)
                
                Button(action: {
                    web_view.loadURL(urlString: urlString)
                }, label: {
                    Text("Go")
                })
                
                Button(action: {
                    web_view.goForward()
                }){
                    Image(systemName: "arrow.forward")
                        .font(.title)
                        .padding()
                    
                    
                }
            }.background(Color(.systemGray6))
            
            // main webview
            web_view
        }
        .onAppear(){
            web_view.loadURL(urlString: urlString)
        }
    }
}
#Preview {
    ContentView()
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

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

            let index_html_path : String = Bundle.main.path(forResource: "loading", ofType: "html")!
            
            let index_html_url : URL = URL(fileURLWithPath: index_html_path)
            
            urlString = String(describing: index_html_url)

            web_view.loadURL(urlString: urlString)

            let resource_path = Bundle.main.resourcePath!
            print ("Resource path", resource_path)
            
            let kernel_version = String(cString: bibledit_get_version_number())
            print ("Bibledit kernel version", kernel_version)
            
            // This iOS app gets a slice of storage just for itself.
            // This is called the documents directory.
            // It is read-write storage.
            let file_manager = FileManager.default
            let paths = file_manager.urls(for: .documentDirectory, in: .userDomainMask)
            let documents_directory = paths.first!
            print ("Documents directory", documents_directory)

            let webroot = documents_directory.appendingPathComponent("webroot")
            print ("Webroot", webroot)
            
            DispatchQueue.global(qos: .background).async {
                // Run task that may take relatively long.
                let dir_hash = "dir#"
                let file_hash = "file#"
                let dot_res = ".res"
                let hash = "#"
                let slash = "/"
                let file_manager = FileManager.default
                do {
                    let filenames = try file_manager.contentsOfDirectory(atPath: resource_path)
                    // The refresh.sh script has encoded all directories in the source webroot
                    // to specially crafted files encoding the original directory structure.
                    // Decode the desired directories, and create them all in the webroot.
                    var directory_count = 0
                    for resource_filename in filenames {
                        if resource_filename.hasPrefix(dir_hash) {
                            if resource_filename.hasSuffix(dot_res) {
                                // Example: dir#mimetic098#codec.res
                                var webroot_filename = resource_filename
                                // Example: mimetic098#codec.res
                                webroot_filename = String(webroot_filename.dropFirst(dir_hash.count))
                                // Example: mimetic098#codec
                                webroot_filename = String(webroot_filename.dropLast(dot_res.count))
                                // Example: mimetic098/codec
                                webroot_filename = webroot_filename.replacingOccurrences(of: hash, with: slash)
                                // Full folder path to create.
                                let webroot_filename_url = webroot.appendingPathComponent(webroot_filename)
                                // Create this directory.
                                try! file_manager.createDirectory(at: webroot_filename_url, withIntermediateDirectories: true)
                                directory_count += 1
                            }
                        }
                    }
                    print ("Created", directory_count, "directories in the webroot")

                    // Once the directories have been created first, now go on with the files in those directories.
                    // The refresh.sh script has encoded all files in the source webroot
                    // to specially crafted files encoding the original file path.
                    // Decode the desired files, and create them all in the webroot.
                    var file_count = 0
                    for resource_filename in filenames {
                        if resource_filename.hasPrefix(file_hash) {
                            if resource_filename.hasSuffix(dot_res) {
                                // Example: file#bootstrap#loading.css.res
                                var webroot_filename = resource_filename
                                // Example: bootstrap#loading.css.res
                                webroot_filename = String(webroot_filename.dropFirst(dir_hash.count))
                                // Example: bootstrap#loading.css
                                webroot_filename = String(webroot_filename.dropLast(dot_res.count))
                                // Example: bootstrap/loading.css
                                webroot_filename = webroot_filename.replacingOccurrences(of: hash, with: slash)
                                // Full file path to copy the resource to.
                                let webroot_filename_url = webroot.appendingPathComponent(webroot_filename)
                                // The full original resource path.
                                let resource_path = resource_path + slash + resource_filename
                                // Copy the resource to this full file path.
                                do {
                                    try file_manager.copyItem(atPath: resource_path, toPath: webroot_filename_url.path())
                                }
                                catch {}
                                file_count += 1
                            }
                        }
                    }
                    print ("Created", file_count, "files in the webroot")
                }
                catch {
                }

                // Once done, update the UI on the main thread.
                DispatchQueue.main.async {
                    urlString = "https://bibledit.org:8091"
                    web_view.loadURL(urlString: urlString)
                }
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

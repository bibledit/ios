import SwiftUI
import WebKit
import Combine

let web_view = WebView()

struct ContentView: View {

    @Environment(\.scenePhase) var scenePhase

    @State var startup_timer = Timer.publish(every: 5, tolerance: 0.5, on: .main, in: .common).autoconnect()
    
//
    var body: some View {
        VStack {
            web_view
        }
        .onAppear(){

            // When the webview appears, it shows a "loading" splash screen.
            let index_html : URL = URL(fileURLWithPath: Bundle.main.path(forResource: "loading", ofType: "html")!)
            web_view.loadURL(urlString: String(describing: index_html))
            
            startup_timer = Timer.publish(every: 1, tolerance: 0.5, on: .main, in: .common).autoconnect()

            /*

            // The file URL where the app has stored its resources.
            print ("Resources URL", resources_url())
            
            // Any iOS app gets a slice of storage just for itself.
            // This is called the documents directory.
            // It is read-write storage.
            print ("Documents URL", documents_url())
            
            print ("Webroot URL", webroot_url())

            print ("Bibledit kernel version", kernel_software_version())
            print ("Installed webroot version", get_installed_webroot_version())
            if (kernel_software_version() != get_installed_webroot_version()) { // Todo: !=
                print ("Copy the resources to the webroot")
                // Run a task that may take long as a background thread.
                DispatchQueue.global(qos: .background).async {
                    // Copy the relevant sources to the writable webroot.
                    copy_resources_to_webroot()
                    // Update installed version number.
                    set_installed_webroot_version(version: kernel_software_version())

                    // Once done, update the UI on the main thread.
//                    DispatchQueue.main.async {
//                        web_view.loadURL(urlString: get_server_url_string())
//                    }
                    // Do not backup the Documents directory to iCloud.
                    disable_backup_to_icloud ()
                }
            } else {
                print ("before sleep")
                sleep (2)
                print ("after sleep") // Todo use system to see if background thread is ready.

            }
            

            // Let the Bibledit kernel initialize its structures.
            bibledit_initialize_library (resources_url().path(), webroot_url().path());
            
            // This thread sleeps for a second.
            // This overcomes a situation where the internal webserver does not start right away
            // right after the app completed installation,
            // and consequently the app's screen was completely blank.
            // This delay fixes that.
            // It enabled the webserver to start.
            print ("before sleep")
            sleep (1)
            print ("after sleep")

            // Things are ready, show the UI.
            // Todo web_view.loadURL(urlString: get_server_url_string())
             */

        }
        .onDisappear(){
            print ("on disappear")
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                print("Change scene phase to active")
            }
            if phase == .inactive {
                print("Change scene phase to inactive")
            }
            if phase == .background {
                print("Change scene phase to background")
            }
        }
        // iOS 17++ :
        // .onChange(of: scenePhase) { oldPhase, newPhase in
        //     if newPhase == .active {
        //         print("Active")
        //     } else if newPhase == .inactive {
        //         print("Inactive")
        //     } else if newPhase == .background {
        //         print("Background")
        //     }
        // }
        .onReceive(startup_timer) { time in

            print ("Resources URL", resources_url())
            
            print ("Documents URL", documents_url())
            
            print ("Webroot URL", webroot_url())
            
            print ("Bibledit kernel version", kernel_software_version())
            print ("Installed webroot version", get_installed_webroot_version())
            if (kernel_software_version() != get_installed_webroot_version()) { // Todo: !=
                // Copy the relevant sources to the writable webroot.
                print ("Copy the resources to the webroot")
                copy_resources_to_webroot()
                // Update installed version number.
                set_installed_webroot_version(version: kernel_software_version())
                // Do not backup the Documents directory to iCloud.
                disable_backup_to_icloud ()
            }
            
            // Let the Bibledit kernel initialize its structures.
            bibledit_initialize_library (resources_url().path(), webroot_url().path());
            
            // This thread sleeps for a second.
            // This overcomes a situation where the internal webserver does not start right away
            // right after the app completed installation,
            // and consequently the app's screen would be completely blank.
            // This delay works around that.
            // It gives sufficient time to the webserver to start.
            sleep (1)

            bibledit_set_touch_enabled (true);
            
            bibledit_start_library ();

            sleep (2) // Todo
            // Things are ready, show the UI.
            web_view.loadURL(urlString: get_server_url_string())

            // Invalidate the timer.
            startup_timer.upstream.connect().cancel()
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

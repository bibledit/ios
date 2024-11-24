import SwiftUI
import WebKit
import Combine
import Foundation


var first_active_scene_phase_done = false
var first_webview_appear_done = false

let about_blank : String = "about:blank"

let webview_advanced : WebView = WebView()
let webview_translate : WebView = WebView()
let webview_resources : WebView = WebView()
let webview_notes : WebView = WebView()
let webview_settings : WebView = WebView()

var previous_tabs_state : String = ""

let json_decoder = JSONDecoder()

struct TabState: Codable {
    var label: String
    var url: String
}

struct ContentView: View {

    @Environment(\.scenePhase) var scenePhase

    // This timer fires long enough in the future that the .onAppear() call comes before it fires, see below.
    @State var startup_timer = Timer.publish(every: 5, tolerance: 0.5, on: .main, in: .common).autoconnect()

    // This timer fires long enough in the future that the installation routine will have been completed before it fires.
    @State var repetitive_timer = Timer.publish(every: 60, tolerance: 0.5, on: .main, in: .common).autoconnect()

    @State var enable_basic_view: Bool = false
    
    // The labels for the four or five tabs of the basic mode.
    @State var basic_mode_translate_label : String = "Translate"
    @State var basic_mode_resources_label : String = "Resources"
    @State var basic_mode_notes_label     : String = "Notes"
    @State var basic_mode_settings_label  : String = "Settings"

    var body: some View {
        NavigationStack {
            webview_advanced
                .navigationDestination(isPresented: $enable_basic_view) {
                    TabView {
                        webview_translate
                            .tabItem {
                                Label(basic_mode_translate_label, systemImage: "doc")
                            }
                        webview_resources
                            .tabItem {
                                Label(basic_mode_resources_label, systemImage: "book")
                            }
                        webview_notes
                            .tabItem {
                                Label(basic_mode_notes_label, systemImage: "note")
                            }
                        webview_settings
                            .tabItem {
                                Label(basic_mode_settings_label, systemImage: "gear")
                            }
                            .onAppear() {
                                // If the Settings tab appears, reset the loaded page to its default settings.
                                // This is needed because if on another page currently,
                                // since there's no menu, the user cannot return to the main settings page.
                                // Reloading the default page resolves this.
                                webview_settings.loadURL(urlString: get_basic_mode_settings_url_string())
                            }
                    }
                    .navigationBarBackButtonHidden(true)
                    .onAppear() {
                        print ("TabView.onAppear")
                        webview_advanced.loadURL(urlString: about_blank)
                        webview_translate.loadURL(urlString: get_basic_mode_translate_url_string())
                        webview_resources.loadURL(urlString: get_basic_mode_resources_url_string())
                        webview_notes.loadURL(urlString: get_basic_mode_notes_url_string())
                        webview_settings.loadURL(urlString: get_basic_mode_settings_url_string())
                    }
                }
                .onAppear() {
                    print ("WebView.onAppear")
                    if first_webview_appear_done {
                        webview_translate.loadURL(urlString: about_blank)
                        webview_resources.loadURL(urlString: about_blank)
                        webview_notes.loadURL(urlString: about_blank)
                        webview_settings.loadURL(urlString: about_blank)
                        webview_advanced.loadURL(urlString: get_advanced_mode_url_string())
                    } else {

                        // When the advanced webview appears, it shows a "loading" splash screen.
                        let index_html : URL = URL(fileURLWithPath: Bundle.main.path(forResource: "loading", ofType: "html")!)
                        webview_advanced.loadURL(urlString: String(describing: index_html))
                        
                        // Shortly after displaying the splash screen, the install and startup routine will begin,
                        // triggered by this timer.
                        startup_timer = Timer.publish(every: 1, tolerance: 0.5, on: .main, in: .common).autoconnect()
                    }

                    first_webview_appear_done = true
                }
        }

        .onAppear(){
            print ("NavigationStack.onAppear")
        }
        .onDisappear(){
            print ("NavigationStack.onDisappear")
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                print("Change scene phase to active")
                if first_active_scene_phase_done {
                    bibledit_start_library ();
                    
                    let web_url : String = webview_advanced.webView.url?.absoluteString ?? ""
                    //                let index = web_url.index(web_url.startIndex, offsetBy: 21)
                    //                let bit : String = web_url.substring(to: index)
                    //                print (web_url)
                    //                print (index)
                    //                print (bit)
                    //
                    //                let bit2 : String = String(web_url.prefix(21))
                    //                print (bit2)
                    // Reload the loaded page, just to be sure that everything works.
                    webview_advanced.loadURL(urlString: web_url)
                    
                    // Previous, Objective-C, app had this:
                    //BOOL equal = [bit isEqualToString:homeUrl];
                    //if (!equal) {
                    //    // Reload home page.
                    //    [BibleditController bibleditBrowseTo:homeUrl]; // Check on this one in tabbed view.
                    //} else {
                    //    // Reload the loaded page, just to be sure that everything works.
                    //    [BibleditController bibleditBrowseTo:path];
                    //}
                }
                first_active_scene_phase_done = true
            }
            if phase == .inactive {
                print("Change scene phase to inactive")
            }
            if phase == .background {
                print("Change scene phase to background")
                // Before the app enters the background, suspend the library, and wait till done.
                bibledit_stop_library ();
                while (bibledit_is_running ()) { };
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
            print ("Webroot version", get_installed_webroot_version())
            if (kernel_software_version() != get_installed_webroot_version()) {
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

            bibledit_set_touch_enabled (true);

            // Start the embedded webserver and its structure.
            bibledit_start_library ();

            // This thread sleeps for a second.
            // This overcomes a situation where the internal webserver does not start right away
            // right after the app completed installation,
            // and consequently the app's screen would be completely blank.
            // This delay works around that.
            // It gives sufficient time to the webserver to start.
            sleep (1)

            // Things are ready, show the UI.
            webview_advanced.loadURL(urlString: get_advanced_mode_url_string())

            // Invalidate the timer.
            startup_timer.upstream.connect().cancel()
            
            // Reinitialize the repetitive timer.
            repetitive_timer = Timer.publish(every: 1, tolerance: 0.25, on: .main, in: .common).autoconnect()
        }

        .onReceive(repetitive_timer) { time in
            let tabs_state : String = String(cString: bibledit_get_pages_to_open ())
            //print ("tabs state length:", tabs_state.count)
            if (tabs_state != previous_tabs_state) {
                previous_tabs_state = tabs_state
                //print ("tabs state:", tabs_state)
                let json = tabs_state.data(using: .utf8)!
                do {
                    // If the JSON array contains an element that isn't a TabState instance,
                    // the entire decoding fails.
                    let tabs = try json_decoder.decode([TabState].self, from: json)
                    print("tabs count: ", tabs.count)
                    //for tab in tabs {
                    //    print(tab.label, tab.url)
                    //}
                    basic_mode_translate_label        = tabs[0].label
                    basic_mode_translate_url_fragment = tabs[0].url
                    basic_mode_resources_label        = tabs[1].label
                    basic_mode_resources_url_fragment = tabs[1].url
                    basic_mode_notes_label            = tabs[2].label
                    basic_mode_notes_url_fragment     = tabs[2].url
                    basic_mode_settings_label         = tabs[3].label
                    basic_mode_settings_url_fragment  = tabs[3].url
                    enable_basic_view = true
                } catch {
                    enable_basic_view = false
                }
                print (enable_basic_view ? "enable basic view" : "enabling advanced view")
            }
        }
        
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification), perform: { output in
            bibledit_shutdown_library ()
        })

        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification), perform: { output in
            bibledit_log ("The device runs low on memory.");
            let task_vm_ino_count = MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<natural_t>.size
            var vm_info = task_vm_info_data_t()
            var vm_info_size = mach_msg_type_number_t(task_vm_ino_count)
            let kern: kern_return_t = withUnsafeMutablePointer(to: &vm_info) {
                $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                    task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &vm_info_size)
                }
            }
            if kern == KERN_SUCCESS {
                let used_size = Int(vm_info.internal + vm_info.compressed)
                let msg : String = "Memory in use is \(used_size/1024/1024) megabytes"
                bibledit_log(msg)
            } else {
                let error_string = String(cString: mach_error_string(kern), encoding: .ascii) ?? "unknown error"
                let msg : String = "Error with task_info(): \(error_string)"
                bibledit_log(msg)
            }
        })

    }
    
    init() {
        // Get the port number once before the embedded webserver runs.
        _ = get_port_number()
    }
}


struct BasicView: View {
    var body: some View {
        TabView {
            webview_translate
                .tabItem {
                    Label("Translate", systemImage: "doc")
                }
            webview_resources
                .tabItem {
                    Label("Resources", systemImage: "book")
                }
            webview_notes
                .tabItem {
                    Label("Notes", systemImage: "note")
                }
            webview_settings
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .onAppear() {
                    print ("the settings tab appears")
                }
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

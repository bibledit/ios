import SwiftUI
import WebKit
import Combine
import Foundation


// Keep the previous tabs state.
// Ensure the next tabs obtained from the Bibledit kernel will trigger a view switch.
// Do that by initializing it with a value that differs from any possible tabs state.
var previous_tabs_state : String = "init"

var first_active_scene_phase_done = false

let about_blank : String = "about:blank"

let single_webview : WebView = WebView()
let tabs_webview_1 : WebView = WebView()
let tabs_webview_2 : WebView = WebView()
let tabs_webview_3 : WebView = WebView()
let tabs_webview_4 : WebView = WebView()
let tabs_webview_5 : WebView = WebView()

enum ViewState {
    case splash
    case tabs
    case single
}

let json_decoder = JSONDecoder()

struct TabState: Decodable {
    var label: String
    var url: String
}

var previous_tab_count : Int = 0

var previous_sync_state : String = "false"

struct ContentView: View {

    @Environment(\.scenePhase) var scene_phase

    @State var view_state : ViewState = ViewState.splash

    // This timer fires long enough in the future that the .onAppear() call comes before it fires, see below.
    @State var startup_timer = Timer.publish(every: 60, tolerance: 0.5, on: .main, in: .common).autoconnect()

    // This timer fires long enough in the future that the installation routine will have been completed before it fires.
    @State var repetitive_timer = Timer.publish(every: 60, tolerance: 0.5, on: .main, in: .common).autoconnect()

    // The labels for the tabs of the basic mode.
    @State var basic_mode_label_1 : String = "Translate"
    @State var basic_mode_label_2 : String = "Resources"
    @State var basic_mode_label_3 : String = "Notes"
    @State var basic_mode_label_4 : String = "Settings"
    @State var basic_mode_label_5 : String = ""

    // The images for the tabs of the basic mode.
    @State var basic_mode_image_1 : String = "doc"
    @State var basic_mode_image_2 : String = "book"
    @State var basic_mode_image_3 : String = "note"
    @State var basic_mode_image_4 : String = "gear"
    @State var basic_mode_image_5 : String = "gear"
    
    @State var basic_mode_enable_tab_5 : Bool = false
    
    @State var basic_mode_tab_number : Int = 1
    
    var body: some View {
        VStack {
            
            // Splash screen.
            if view_state == ViewState.splash {
                GeometryReader { geometry in
                    VStack {
                        Spacer()
                        Text("Bibledit")
                            .font(.largeTitle)
                        Spacer()
                        Text("loading")
                        ProgressView()
                            .dynamicTypeSize(.xxxLarge)
                        Spacer()
                        Image(systemName: "book")
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width / 20, height: geometry.size.height / 20, alignment: .center)
                        Spacer()
                    }
                    .frame(width: geometry.size.width)
                    .frame(height: geometry.size.height)
                }
                .onAppear(){
                    // Shortly after displaying the splash screen, the install and startup routine will begin,
                    // triggered by this timer.
                    startup_timer = Timer.publish(every: 1, tolerance: 0.5, on: .main, in: .common).autoconnect()
                }
            }
            
            // Basic mode.
            if view_state == ViewState.tabs {
                TabView (selection: $basic_mode_tab_number) {
                    tabs_webview_1
                        .tabItem {
                            Label(basic_mode_label_1, systemImage: basic_mode_image_1)
                        }
                        .tag(1)
                        .onAppear() {
                            if tabs_webview_1.web_view.url?.absoluteString != get_basic_mode_url_1() {
                                tabs_webview_1.loadURL(urlString: get_basic_mode_url_1())
                            }
                        }
                    tabs_webview_2
                        .tabItem {
                            Label(basic_mode_label_2, systemImage: basic_mode_image_2)
                        }
                        .tag(2)
                        .onAppear() {
                            if tabs_webview_2.web_view.url?.absoluteString != get_basic_mode_url_2() {
                                tabs_webview_2.loadURL(urlString: get_basic_mode_url_2())
                            }
                        }
                    tabs_webview_3
                        .tabItem {
                            Label(basic_mode_label_3, systemImage: basic_mode_image_3)
                        }
                        .tag(3)
                        .onAppear() {
                            if tabs_webview_3.web_view.url?.absoluteString != get_basic_mode_url_3() {
                                tabs_webview_3.loadURL(urlString: get_basic_mode_url_3())
                            }
                        }
                    tabs_webview_4
                        .tabItem {
                            Label(basic_mode_label_4, systemImage: basic_mode_image_4)
                        }
                        .tag(4)
                        .onAppear() {
                            // If the Settings tab appears, reset the loaded page to its default settings.
                            // This is needed because if on another page currently,
                            // since there's no menu, the user cannot return to the main settings page.
                            // Reloading the default page resolves this.
                            if tabs_webview_4.web_view.url?.absoluteString != get_basic_mode_url_4() || is_settings_url(url: get_basic_mode_url_4()) {
                                tabs_webview_4.loadURL(urlString: get_basic_mode_url_4())
                            }
                        }
                    if basic_mode_enable_tab_5 {
                        tabs_webview_5
                            .tabItem {
                                Label(basic_mode_label_5, systemImage: basic_mode_image_5)
                            }
                            .tag(5)
                            .onAppear() {
                                // See comment on the above tab: Reload it this tab shows the Settings page.
                                if tabs_webview_5.web_view.url?.absoluteString != get_basic_mode_url_5() || is_settings_url(url: get_basic_mode_url_5()) {
                                    tabs_webview_5.loadURL(urlString: get_basic_mode_url_5())
                                }
                            }
                    }
                }
                .onAppear() {
                    single_webview.loadURL(urlString: about_blank)
                }
            }
            
            // Advanced model.
            if view_state == ViewState.single {
                single_webview
                    .onAppear() {
                        tabs_webview_1.loadURL(urlString: about_blank)
                        tabs_webview_2.loadURL(urlString: about_blank)
                        tabs_webview_3.loadURL(urlString: about_blank)
                        tabs_webview_4.loadURL(urlString: about_blank)
                        tabs_webview_5.loadURL(urlString: about_blank)
                        single_webview.loadURL(urlString: get_advanced_mode_url_string())
                    }
            }
        }

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
            single_webview.loadURL(urlString: get_advanced_mode_url_string())
            
            // Invalidate the timer.
            startup_timer.upstream.connect().cancel()
            
            // Reinitialize the repetitive timer.
            repetitive_timer = Timer.publish(every: 1, tolerance: 0.25, on: .main, in: .common).autoconnect()
        }
        
        .onReceive(repetitive_timer) { time in
            
            // Handle the desired mode of the app, whether basic mode with tabs, or advanced mode.
            let tabs_state : String = String(cString: bibledit_get_pages_to_open ())
            if (tabs_state != previous_tabs_state) {
                previous_tabs_state = tabs_state
                let json = tabs_state.data(using: .utf8)!
                do {
                    // If the JSON array contains an element that isn't a TabState instance,
                    // the entire decoding fails.
                    let tabs = try json_decoder.decode([TabState].self, from: json)
                    basic_mode_label_1        = tabs[0].label
                    basic_mode_url_fragment_1 = tabs[0].url
                    basic_mode_label_2        = tabs[1].label
                    basic_mode_url_fragment_2 = tabs[1].url
                    basic_mode_label_3        = tabs[2].label
                    basic_mode_url_fragment_3 = tabs[2].url
                    basic_mode_label_4        = tabs[3].label
                    basic_mode_url_fragment_4 = tabs[3].url
                    if tabs.count >= 5 {
                        basic_mode_label_5        = tabs[4].label
                        basic_mode_url_fragment_5 = tabs[4].url
                        basic_mode_enable_tab_5 = true
                    } else {
                        basic_mode_label_5 = ""
                        basic_mode_url_fragment_5 = ""
                        basic_mode_enable_tab_5 = false
                    }
                    print ("Switch to tabs view")
                    view_state = ViewState.tabs
                    // The fourth tab or the fifth tab is the Settings tab.
                    // The code below ensures that if the number of tabs changes due to changing a setting,
                    // the Settings tab remains the active tab.
                    if tabs.count == 4 {
                        if previous_tab_count == 5 {
                            basic_mode_tab_number = 4
                        }
                    }
                    if tabs.count == 5 {
                        if previous_tab_count == 4 {
                            basic_mode_tab_number = 5
                        }
                    }
                    previous_tab_count = tabs.count
                    // Set the images for each tab.
                    basic_mode_image_1 = get_tab_image (url: basic_mode_url_fragment_1)
                    basic_mode_image_2 = get_tab_image (url: basic_mode_url_fragment_2)
                    basic_mode_image_3 = get_tab_image (url: basic_mode_url_fragment_3)
                    basic_mode_image_4 = get_tab_image (url: basic_mode_url_fragment_4)
                    basic_mode_image_5 = get_tab_image (url: basic_mode_url_fragment_5)
                } catch {
                    view_state = ViewState.single
                    print ("Switch to single view")
                }
            }
            
            // Todo
            // Handle the situation to leave the screen on during send/receive.
            // This ensures that the send/receive action is completed properly,
            // and is normally not interrupted by iOS putting the application to sleep.
            let sync_state : String = String(cString: bibledit_is_synchronizing ())
            if sync_state == "true" {
                //print ("keep screen on")
                UIApplication.shared.isIdleTimerDisabled = true
            }
            if sync_state == "false" {
                if sync_state == previous_sync_state {
                    //print ("do not keep screen on")
                    UIApplication.shared.isIdleTimerDisabled = false
                }
            }
            previous_sync_state = sync_state
            
        }

        .onChange(of: scene_phase) { phase in
            if phase == .active {
                print("Change scene phase to active")
                if first_active_scene_phase_done {
                    bibledit_start_library ();
                    // Reload the loaded page(s), just to be sure that everything works.
                    if view_state == ViewState.tabs {
                        switch basic_mode_tab_number {
                        case 1:
                            if tabs_webview_1.web_view.url?.absoluteString != get_basic_mode_url_1() {
                                tabs_webview_1.loadURL(urlString: get_basic_mode_url_1())
                            }
                        case 2:
                            if tabs_webview_2.web_view.url?.absoluteString != get_basic_mode_url_2() {
                                tabs_webview_2.loadURL(urlString: get_basic_mode_url_2())
                            }
                        case 3:
                            if tabs_webview_3.web_view.url?.absoluteString != get_basic_mode_url_3() {
                                tabs_webview_3.loadURL(urlString: get_basic_mode_url_3())
                            }
                        case 4:
                            if tabs_webview_4.web_view.url?.absoluteString != get_basic_mode_url_4() {
                                tabs_webview_4.loadURL(urlString: get_basic_mode_url_4())
                            }
                        case 5:
                            if tabs_webview_5.web_view.url?.absoluteString != get_basic_mode_url_5() {
                                tabs_webview_5.loadURL(urlString: get_basic_mode_url_5())
                            }
                        default:
                            print ("Unknown basic mode tab number")
                        }
                    }
                    if view_state == ViewState.single {
                        let url = single_webview.web_view.url
                        if (url != nil) {
                            let address : String = url!.absoluteString
                            single_webview.loadURL(urlString: address)
                        }
                    }
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
        // Get the port number once, before the embedded webserver runs, and store it for later use.
        _ = get_port_number()
    }
}


struct WebView: UIViewRepresentable {
    
    let web_view: WKWebView
    
    init() {
        self.web_view = WKWebView()
    }
    
    func makeUIView(context: Context) -> WKWebView {
        web_view.allowsBackForwardNavigationGestures = true
        return web_view
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
    
    func goBack(){
        web_view.goBack()
    }
    
    func goForward(){
        web_view.goForward()
    }
    
    func loadURL(urlString: String) {
        web_view.load(URLRequest(url: URL(string: urlString)!))
    }
}


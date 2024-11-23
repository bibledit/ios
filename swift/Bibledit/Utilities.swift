/*
 Copyright (©) 2003-2024 Teus Benschop.
 
 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */


import Foundation


// Get the URL where the app has installed its resources.
// On the simulator this is something like:
// file:///<home>/Library/Developer/CoreSimulator/Devices/<uri>/data/Containers/Bundle/Application/<uri>/Bibledit.app/
func resources_url() -> URL
{
    return URL (fileURLWithPath: Bundle.main.resourcePath!)
}


// Get the URL to the Documents directory.
// This is a writable area specifically for this app only.
// Example:
// file:///<home>/Library/Developer/CoreSimulator/Devices/<uri>/data/Containers/Data/Application/<uri>/Documents/
func documents_url() -> URL
{
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
}


// The embedded web server's web root directory.
func webroot_url() -> URL
{
    return documents_url().appendingPathComponent("webroot")
}


// The version number of the Bibledit kernel software.
func kernel_software_version() -> String
{
    return String(cString: bibledit_get_version_number())
}


// Key used for getting and setting the version number of the installed webroot,
// as stored in the Swift user data area.
let version_key = "bibledit-version"

func get_installed_webroot_version() -> String
{
    return UserDefaults.standard.object(forKey: version_key) as? String ?? String()
}

func set_installed_webroot_version(version : String) -> Void
{
    UserDefaults.standard.set(version, forKey: version_key)
}


// Putting the Bibledit kernel's data into the resources for this app is not handled perfectly in Xcode.
// It sees most kernel data as resources, which is the right thing to do.
// But it also omits some kernel data, or sees them as code that should be compiled.
// To overcome this, the refresh.sh script has encoded all kernel data
// into specially crafted files with the encoding in their name,
// resemdling the original files and directory structures.
// This function decodes them all and results in a webroot data structure
// the same as the original one before the refresh.sh script encoded that data structure.
func copy_resources_to_webroot() -> Void
{
    let dir_hash = "dir#"
    let file_hash = "file#"
    let dot_res = ".res"
    let hash = "#"
    let slash = "/"
    let file_manager = FileManager.default
    do {
        let filenames = try file_manager.contentsOfDirectory(atPath: resources_url().path())
        // Decode the desired directories, and create them all in the webroot.
        var created_directory_count = 0
        var existing_directory_count = 0
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
                    let webroot_filename_url = webroot_url().appendingPathComponent(webroot_filename)
                    // Create this directory if it does not exist yet.
                    if (file_manager.fileExists(atPath: webroot_filename_url.path())) {
                        existing_directory_count += 1
                    }
                    else {
                        do {
                            try file_manager.createDirectory(at: webroot_filename_url, withIntermediateDirectories: true)
                            created_directory_count += 1
                        }
                        catch {
                            // If a catch clause does not specify a pattern,
                            // the clause will match and bind any error to a local constant named error.
                            print (error)
                        }
                    }
                }
            }
        }
        print ("Created", created_directory_count, "directories in the webroot and", existing_directory_count, "directories already existed")
        
        // Once the directories have been created first, now go on with the files in those directories.
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
                    let webroot_filename_url = webroot_url().appendingPathComponent(webroot_filename)
                    // The full original resource path.
                    let resource_path = resources_url().appendingPathComponent(resource_filename)
                    // Copy the resource to this full file path.
                    // It overwrites any existing file of the same name,
                    // because the newer file could be different from the existing one.
                    do {
                        if file_manager.fileExists(atPath: webroot_filename_url.path()) {
                            try file_manager.removeItem(at: webroot_filename_url)
                        }
                        try file_manager.copyItem(at: resource_path, to: webroot_filename_url)
                        file_count += 1
                    }
                    catch {
                        print (error)
                    }
                }
            }
        }
        print ("Created", file_count, "files in the webroot")
    }
    catch {
        print (error)
    }
}


var port_number : String = ""
func get_port_number() -> String
{
    if port_number.isEmpty {
        // Get the port number that the Bibledit kernel will now negotiate to use.
        // Be sure to get this before the embedded web server runs, to get the right result.
        port_number = String(cString: bibledit_get_network_port ())
    }
    return port_number
}


func get_advanced_mode_url_string() -> String
{
    return "http://localhost:" + get_port_number() + "/index/index?mode=advanced" // Todo fix this later: Switch to advanced mode, can be fixed after tabbed mode works again.
}


func get_basic_mode_translate_url_string() -> String
{
    return "http://localhost:" + get_port_number() + "/editone2/index"
}


func get_basic_mode_resources_url_string() -> String
{
    return "http://localhost:" + get_port_number() + "/resource/index"
}


func get_basic_mode_notes_url_string() -> String
{
    return "http://localhost:" + get_port_number() + "/notes/index"
}


func get_basic_mode_settings_url_string() -> String
{
    return "http://localhost:" + get_port_number() + "/personalize/index"
}


func disable_backup_to_icloud() -> Void // Todo write it, call it, test it?
{
    // Disable the entire Documents folder from being backed up to iCloud.
    // The reason is that if it were included,
    // the size of the backup would be larger than what Apple allows.
    
    /*
     2.23 - Apps must follow the iOS Data Storage Guidelines or they will be rejected
     Hello,
     
     We are writing to let you know about new information regarding your app, Bibledit, version 1.0.377, currently live on the App Store.
     
     Upon re-evaluation, we found that your app is not in compliance with the App Store Review Guidelines. Specifically, we found:
     
     2.23
     On launch and content download, your app stores 89.43 MB on the user's iCloud, which does not comply with the iOS Data Storage Guidelines.
     
     Please verify that only the content that the user creates using your app, e.g., documents, new files, edits, etc. is backed up by iCloud as required by the iOS Data Storage Guidelines. Also, check that any temporary files used by your app are only stored in the /tmp directory; please remember to remove or delete the files stored in this location when it is determined they are no longer needed.
     
     Data that can be recreated but must persist for proper functioning of your app - or because users expect it to be available for offline use - should be marked with the "do not back up" attribute. For NSURL objects, add the NSURLIsExcludedFromBackupKey attribute to prevent the corresponding file from being backed up. For CFURLRef objects, use the corresponding kCRUFLIsExcludedFromBackupKey attribute.
     
     To check how much data your app is storing:
     
     - Install and launch your app
     - Go to Settings > iCloud > Storage > Manage Storage
     - Select your device
     - If necessary, tap "Show all apps"
     - Check your app's storage
     
     For additional information on preventing files from being backed up to iCloud and iTunes, see Technical Q&A 1719: How do I prevent files from being backed up to iCloud and iTunes.
     
     To ensure there is no interruption of the availability of your app on the App Store, please submit an update within two weeks of the date of this message. If we do not receive an update within two weeks, your app may be removed from sale.
     
     If you have any questions about this information, please reply to this message to let us know.
     
     Best regards,
     
     App Store Review
     */
    
    var documents_url = documents_url ()
    do {
        var res = URLResourceValues()
        res.isExcludedFromBackup = true
        try documents_url.setResourceValues(res)
    } catch {
        print(error)
    }
}

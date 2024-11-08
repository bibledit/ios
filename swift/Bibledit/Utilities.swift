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

func resources_url() -> URL
{
    return URL (fileURLWithPath: Bundle.main.resourcePath!)
}

func documents_url() -> URL
{
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
}

func webroot_url() -> URL
{
    return documents_url().appendingPathComponent("webroot")

}

func kernel_software_version() -> String
{
    return String(cString: bibledit_get_version_number())
}

let version_key = "VersionKey"

func get_installed_webroot_version() -> String
{
    return UserDefaults.standard.object(forKey: version_key) as? String ?? String()
}

func set_installed_webroot_version(version : String) -> Void
{
    UserDefaults.standard.set(version, forKey: version_key)
}

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
        // The refresh.sh script has encoded all directories in the source webroot
        // to specially crafted files encoding the original directory structure.
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

func get_server_url_string() -> String
{
    "https://bibledit.org:8091" // Todo fix this.
}

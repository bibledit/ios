/*
 Copyright (©) 2003-2017 Teus Benschop.
 
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


#import "BibleditInstallation.h"
#import "BibleditPaths.h"
#import "bibledit.h"


@implementation BibleditInstallation


+ (void) run
{
    // Disable the entire webroot folder from being backed up to iCloud.
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
    
    [NSThread sleepForTimeInterval:2];
    NSString * webroot = [BibleditPaths documents];
    //NSLog(@"%@", webroot);
    NSURL* URL= [NSURL fileURLWithPath: webroot];
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        //NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    //NSLog (@"%d", success);
}


+ (NSString *) libraryVersion
{
    // Retieve the version of the Bibledit library.
    NSString *version = [NSString stringWithFormat:@"%s", bibledit_get_version_number ()];
    return version;
}


+ (NSString *) installedVersion
{
    // Retieve the version of Bibledit-Web that has been installed.
    NSString * version = [[NSUserDefaults standardUserDefaults] stringForKey:@"bibledit-version"];
    return version;
}


+ (void) installedVersion:(NSString *)version
{
    // Store the Bibledit-Web verion in the preferences.
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:version forKey:@"bibledit-version"];
    [userDefaults synchronize];
}


@end

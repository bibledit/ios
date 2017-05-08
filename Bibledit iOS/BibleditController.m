//
//  BibleditPaths.m
//  Bibledit
//
//  Created by Mini on 13-09-14.
//  Copyright (c) 2014 Teus Benshop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "BibleditController.h"
#import "BibleditPaths.h"
#import "BibleditInstallation.h"
#import "bibledit.h"
#import <mach/mach.h>
#import "Variables.h"


@implementation BibleditController


NSString * homeUrl = @"http://localhost:8765";
NSMutableString * previousSyncState;
NSString * previousTabsState;


+ (void) bibleditAppLaunched
{
    // Directory where the Bibledit resources reside.
    NSString * resources = [BibleditPaths resources];
    const char * resources_path = [resources UTF8String];
    // NSLog(@"Resources %@", resources);

    // Directory where the Bibledit web app's webroot resides.
    NSString * webroot = [BibleditPaths documents];
    const char * webroot_path = [webroot UTF8String];
    // NSLog(@"Webroot %@", webroot);

    bibledit_initialize_library (resources_path, webroot_path);
    
    bibledit_set_touch_enabled (true);
    
    bibledit_start_library ();
    
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(bibleditRunRepetitiveTimer:) userInfo:nil repeats:YES];
}


+ (void) bibleditViewHasLoaded:(UIView *)uiview
{
    ui_view = uiview;
    WKWebViewConfiguration *theConfiguration = [[WKWebViewConfiguration alloc] init];
    wk_web_view = [[WKWebView alloc] initWithFrame:ui_view.frame configuration:theConfiguration];
    [ui_view addSubview:wk_web_view];
    [BibleditController bibleditBrowseTo:homeUrl];
}


+ (void) tabBarControllerViewDidLoad:(UITabBarController *)tabbarcontroller
{
    /*
    uitabbarcontroller = tabbarcontroller;
    NSArray * urls = @[@"", @"editone/index", @"notes/index", @"resource/index"];
    NSArray * labels = @[@"Home", @"Translate", @"Notes", @"Resources"];
    NSInteger active = 1;
    [self startTabbedView:urls labels:labels active:active];
     */
}


+ (void) bibleditInstallResources
{
    // Run the installation.
    [BibleditInstallation run];
}


+ (void) bibleditEnteredForeground
{
    bibledit_start_library ();
    NSURL *url = [wk_web_view URL];
    NSString *path = [url absoluteString];
    NSString *bit = [path substringToIndex:21];
    BOOL equal = [bit isEqualToString:homeUrl];
    if (!equal) {
        // Reload home page.
        [BibleditController bibleditBrowseTo:homeUrl];
    } else {
        // Reload the loaded page, just to be sure that everything works.
        [BibleditController bibleditBrowseTo:path];
    }
}


+ (void) bibleditBrowseTo:(NSString*)urlString
{
    // NSLog(@"To URL %@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [wk_web_view loadRequest:urlRequest];
}


+ (void) bibleditReceivedMemoryWarning
{
    // There are huge memory leaks in UIWebView.
    // The memory usage keeps creeping up over time when it displays dynamic pages.
    // iOS sends a few memory warnings after an hour or so, then iOS kills the app.
    // WKWeb​View is new on iOS 8 and uses and leaks far less memory.
    // It uses the webkit rendering engine, and a faster javascript engine.
    // The best solution to the above memory problems is to use WKWebView.
    // That has been implemented.

    bibledit_log ("The device runs low on memory.");
    
    struct mach_task_basic_info info;
    mach_msg_type_number_t size = MACH_TASK_BASIC_INFO_COUNT;
    kern_return_t kerr = task_info (mach_task_self(), MACH_TASK_BASIC_INFO, (task_info_t)&info, &size);
    if (kerr == KERN_SUCCESS) {
        NSString *string = [NSString stringWithFormat:@"Memory in use: %lld Mb", info.resident_size / 1024 / 1024];
        const char * message = [string UTF8String];
        bibledit_log (message);
    }
}


+ (void) bibleditWillEnterBackground
{
    // Before the app enters the background, suspend the library, and wait till done.
    bibledit_stop_library ();
    while (bibledit_is_running ()) { };
}


+ (void) bibleditWillTerminate
{
    bibledit_shutdown_library ();
}


+ (void) bibleditRunRepetitiveTimer:(NSTimer *)timer
{
    NSString * syncState = [NSString stringWithUTF8String:bibledit_is_synchronizing ()];
    if ([syncState isEqualToString:@"true"]) {
        // NSLog(@"keep screen on");
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
    if ([syncState isEqualToString:@"false"]) {
        if ([syncState isEqualToString:previousSyncState]) {
            // NSLog(@"do not keep screen on");
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        }
    }
    previousSyncState = [[NSMutableString alloc] initWithString:syncState];

    NSString * url = [NSString stringWithUTF8String:bibledit_get_external_url ()];
    if (url.length != 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: url]];
    }
    
    NSString * tabsState = [NSString stringWithUTF8String:bibledit_get_pages_to_open ()];
    if (![tabsState isEqualToString:previousTabsState]) {
        previousTabsState = tabsState;
        NSData *jsonData = [tabsState dataUsingEncoding:NSUTF8StringEncoding];
        NSError *jsonError;
        id jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];
        if (!jsonError) {
            NSMutableArray * labels = [[NSMutableArray alloc] init];
            NSMutableArray * urls = [[NSMutableArray alloc] init];
            for (int i = 0; i < [jsonArray count]; i++) {
                NSDictionary *arrayResult = [jsonArray objectAtIndex:i];
                NSString * label = [arrayResult objectForKey:@"label"];
                NSString * url = [arrayResult objectForKey:@"url"];
                [labels addObject:label];
                [urls addObject:url];
            }
            NSLog(@"%@", labels);
            NSLog(@"%@", urls);
        }
    }
}


@end

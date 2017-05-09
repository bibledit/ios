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
#import "AppDelegate.h"


@implementation BibleditController


NSString * homeUrl = @"http://localhost:8765/";
NSMutableString * previousSyncState;
NSString * previousTabsState = @"";
UITabBarController * uitabbarcontroller;
NSMutableArray * tabLabels;
NSMutableArray * tabUrls;


+ (void) appDelegateDidFinishLaunchingWithOptions
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
    
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(runRepetitiveTimer:) userInfo:nil repeats:YES];
}


+ (void) viewControllerViewDidLoad:(UIView *)uiview
{
    ui_view = uiview;
    [self startPlainView:homeUrl];
}


+ (void) tabBarControllerViewDidLoad:(UITabBarController *)tabbarcontroller
{
    uitabbarcontroller = tabbarcontroller;
    [self startTabbedView:tabUrls labels:tabLabels];
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
        [BibleditController bibleditBrowseTo:homeUrl]; // Todo check on this one in tabbed view.
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


+ (void) receivedMemoryWarning
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


+ (void) runRepetitiveTimer:(NSTimer *)timer
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
            // Valid JSON: Tabbed view.
            tabLabels = [[NSMutableArray alloc] init];
            tabUrls = [[NSMutableArray alloc] init];
            for (int i = 0; i < [jsonArray count]; i++) {
                NSDictionary *arrayResult = [jsonArray objectAtIndex:i];
                NSString * label = [arrayResult objectForKey:@"label"];
                NSString * url = [arrayResult objectForKey:@"url"];
                [tabLabels addObject:label];
                [tabUrls addObject:url];
            }
            [self loadStoryBoard:@"Tabbed"];
        } else {
            // Invalid JSON: Plain view.
            [self loadStoryBoard:@"Plain"];
        }
    }
}


+ (void) loadStoryBoard:(NSString *)name
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:name bundle:nil];
    UIViewController *initialViewController = [storyBoard instantiateInitialViewController];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.window.rootViewController = initialViewController;
    [appDelegate.window makeKeyAndVisible];
}


+ (void) startPlainView:(NSString *)url
{
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    wk_web_view = [[WKWebView alloc] initWithFrame:ui_view.frame configuration:configuration];
    [ui_view addSubview:wk_web_view];
    
    NSURL *nsurl = [NSURL URLWithString:url];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:nsurl];
    [wk_web_view loadRequest:urlRequest];
}


+ (void) startTabbedView:(NSArray *)urls labels:(NSArray *)labels
{
    NSMutableArray * controllers = [[NSMutableArray alloc] init];
    
    NSInteger active = 0;
    
    for (int i = 0; i < [urls count]; i++) {
        
        NSString * url = [urls objectAtIndex:i];
        NSString * label = [labels objectAtIndex:i];
        
        UIViewController* viewController = [[UIViewController alloc] init];
        UIImage* image = [UIImage imageNamed:@"home.png"];
        UITabBarItem* tarBarItem = [[UITabBarItem alloc] initWithTitle:label image:image tag:0];
        viewController.tabBarItem = tarBarItem;
        
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        WKWebView * webview = [[WKWebView alloc] initWithFrame:viewController.view.frame configuration:configuration];
        [viewController.view addSubview:webview];
        
        NSMutableString* fullUrl = [[NSMutableString alloc] init];
        [fullUrl appendString:homeUrl];
        [fullUrl appendString:url];
        NSURL *nsurl = [NSURL URLWithString:fullUrl];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:nsurl];
        [webview loadRequest:urlRequest];
        
        [controllers addObject:viewController];
        
        // If this tab displays the resources, it is going to be the active tab.
        if ([url rangeOfString:@"resource"].location != NSNotFound) {
            active = i;
        }
    }
    
    uitabbarcontroller.viewControllers = controllers;
    
    uitabbarcontroller.selectedIndex = active;
}


@end


/*
 IconBeast Lite | 300 Free iOS Tab Bar Icons for iPhone and iPad
 ---------------------------------------------------------------
 
 Thank you for downloading IconBeast Lite.
 
 IconBeast Lite is a strip-down version of IconBeast Pro ($75). This 300 icons is free for download and is published under Creative Commons Attribution license. You can use these icons in your all your projects, but we required you to credit us by including a http link back to IconBeast website.
 
 You are also allowed to distribute IconBeast Lite to your website, but you must mentioned that this icon set came from IconBeast. You must also put a link back to us in your website.
 
 You are not allowed to sell these icons.
 */

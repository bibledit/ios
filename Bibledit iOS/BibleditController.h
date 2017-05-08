//
//  BibleditPaths.h
//  Bibledit
//
//  Created by Mini on 13-09-14.
//  Copyright (c) 2014 Teus Benshop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BibleditController : NSObject

+ (void) appDelegateDidFinishLaunchingWithOptions;
+ (void) viewControllerViewDidLoad:(UIView *)uiview;
+ (void) tabBarControllerViewDidLoad:(UITabBarController *)tabbarcontroller;
+ (void) bibleditInstallResources;
+ (void) bibleditEnteredForeground;
+ (void) bibleditBrowseTo:(NSString*)urlString;
+ (void) receivedMemoryWarning;
+ (void) bibleditWillEnterBackground;
+ (void) bibleditWillTerminate;
+ (void) runRepetitiveTimer:(NSTimer *)timer;
+ (void) startPlainView:(NSString *)url;
+ (void) startTabbedView:(NSArray *)urls labels:(NSArray *)labels active:(NSInteger)active;


@end

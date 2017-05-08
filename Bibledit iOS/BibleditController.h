//
//  BibleditPaths.h
//  Bibledit
//
//  Created by Mini on 13-09-14.
//  Copyright (c) 2014 Teus Benshop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BibleditController : NSObject

+ (void) bibleditAppLaunched;
+ (void) bibleditViewHasLoaded:(UIView *)uiview;
+ (void) tabBarControllerViewDidLoad:(UITabBarController *)tabbarcontroller;
+ (void) bibleditInstallResources;
+ (void) bibleditEnteredForeground;
+ (void) bibleditBrowseTo:(NSString*)urlString;
+ (void) bibleditReceivedMemoryWarning;
+ (void) bibleditWillEnterBackground;
+ (void) bibleditWillTerminate;
+ (void) bibleditRunRepetitiveTimer:(NSTimer *)timer;
// Todo + (void) startPlainView:(NSString *)url;
// Todo + (void) startTabbedView:(NSArray *)urls labels:(NSArray *)labels active:(NSInteger)active;


@end

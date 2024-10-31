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


#import "ViewController.h"
#import "BibleditPaths.h"
#import "BibleditInstallation.h"
#import "BibleditController.h"
#import "Variables.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>


@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad
{
  [super viewDidLoad];

  [BibleditController viewControllerViewDidLoad:self.view];

  [wk_web_view setNavigationDelegate:self];

  [self performSelectorInBackground:@selector(installResources) withObject:nil];
}


- (void)installResources
{
  [BibleditController bibleditInstallResources];
}


- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  [BibleditController receivedMemoryWarning];
}


- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
  if (navigationResponse.canShowMIMEType) {
    decisionHandler(WKNavigationResponsePolicyAllow);
  } else {
    [[UIApplication sharedApplication] openURL:navigationResponse.response.URL];
    decisionHandler(WKNavigationResponsePolicyCancel);
  }
}


@end

//
//  AppDelegate.m
//  GithubClient
//
//  Created by Lin Cheng Lung on 30/04/2017.
//  Copyright © 2017 Lin Cheng Lung. All rights reserved.
//

#import "AppDelegate.h"

#import "GCAccountService.h"

// ViewControllers
#import "GCMainViewController.h"
#import "GCLoginViewController.h"

@interface AppDelegate () <GCAccountServiceLoginDelegate>

@property GCAccountService *accountService;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.accountService = [GCAccountService new];
    self.accountService.delegate = self;

    if ([self.accountService hasAuthorizedWithScope:AccountAutorizationScopeNone]) {
        [self presentMainViewController];
    } else {
        [self presentLoginViewControllerWithAccountService:self.accountService];
    }

    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [self.accountService application:app openURL:url options:options];
}

#pragma mark - GCAccountServiceLoginDelegate Methods

- (void)userDidLoginSuccess {
    [self presentMainViewController];
}

- (void)userDidLoginFailedWithError:(NSError *)error {
    [self presentLoginViewControllerWithAccountService:self.accountService];
}

#pragma mark - Private Methods

- (void)presentLoginViewControllerWithAccountService:(GCAccountService *)accountService {
    if ([self.window.rootViewController isKindOfClass:[GCLoginViewController class]]) {
        return;
    }

    [self presentRootViewController:[[GCLoginViewController alloc] initWithAccountService:accountService]];
}

- (void)presentMainViewController {
    if ([self.window.rootViewController isKindOfClass:[GCMainViewController class]]) {
        return;
    }

    [self presentRootViewController:[[GCMainViewController alloc] init]];
}

- (void)presentRootViewController:(UIViewController *)rootViewController {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = rootViewController;
    [self.window makeKeyAndVisible];
}

@end

//
//  GCAccountService.h
//  GithubClient
//
//  Created by Lin Cheng Lung on 30/04/2017.
//  Copyright © 2017 Lin Cheng Lung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AFOAuth2Manager.h>

typedef NS_OPTIONS(NSInteger, AccountAutorizationScope) {
    AccountAutorizationScopeNone
};

@interface GCAccountService : NSObject

@property (nonatomic) AFOAuth2Manager *oauth2Manager;

- (BOOL)hasAuthorizedWithScope:(AccountAutorizationScope)authorizationScope;
- (void)authorizeWithScope:(AccountAutorizationScope)authorizationScope;
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options;

@end

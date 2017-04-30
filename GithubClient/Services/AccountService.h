//
//  AccountService.h
//  GithubClient
//
//  Created by Lin Cheng Lung on 30/04/2017.
//  Copyright © 2017 Lin Cheng Lung. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSInteger, AccountAutorizationScope) {
    AccountAutorizationScopeNone
};

@interface AccountService : NSObject

- (BOOL)hasAuthorizedWithScope:(AccountAutorizationScope)authorizationScope;
- (void)authorizeWithScope:(AccountAutorizationScope)authorizationScope;

@end

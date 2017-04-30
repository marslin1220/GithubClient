//
//  AccountService.m
//  GithubClient
//
//  Created by Lin Cheng Lung on 30/04/2017.
//  Copyright © 2017 Lin Cheng Lung. All rights reserved.
//

#import <SafariServices/SafariServices.h>

#import "AccountService.h"

// Constants
#import "GCGithubConstant.h"

@implementation AccountService

- (BOOL)hasAuthorizedWithScope:(AccountAutorizationScope)authorizationScope {
    return NO;
}

- (void)authorizeWithScope:(AccountAutorizationScope)authorizationScope {

    NSURL *baseURL = [NSURL URLWithString:kGithubAuthorizeBaseURI];
    int randomState = arc4random_uniform(RAND_MAX);
    NSString *queryString = [NSString stringWithFormat:@"?client_id=%@&redirect_uri=%@&state=%d&allow_signup=%@", kGithubClientID, kGithubRedirectURI, randomState, @"false"];
    NSURL *oauthURL = [NSURL URLWithString:queryString relativeToURL:baseURL];

    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:oauthURL];

    id<UIApplicationDelegate> appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate.window.rootViewController presentViewController:safariVC animated:YES completion:nil];

}

@end

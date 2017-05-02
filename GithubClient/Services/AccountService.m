//
//  AccountService.m
//  GithubClient
//
//  Created by Lin Cheng Lung on 30/04/2017.
//  Copyright © 2017 Lin Cheng Lung. All rights reserved.
//

#import <SafariServices/SafariServices.h>

#import "AccountService.h"
#import <AFOAuthCredential.h>

// Constants
#import "GCGithubConstant.h"

@interface AccountService ()

@property int oauthState;

@end

@implementation AccountService

- (BOOL)hasAuthorizedWithScope:(AccountAutorizationScope)authorizationScope {
    return NO;
}

- (void)authorizeWithScope:(AccountAutorizationScope)authorizationScope {

    NSURL *baseURL = [NSURL URLWithString:kGithubAuthorizeBaseURI];
    self.oauthState = arc4random_uniform(RAND_MAX);
    NSString *queryString = [NSString stringWithFormat:@"/login/oauth/authorize?client_id=%@&redirect_uri=%@&state=%d&allow_signup=%@", kGithubClientID, kGithubRedirectURI, self.oauthState, @"false"];
    NSURL *oauthURL = [NSURL URLWithString:queryString relativeToURL:baseURL];

    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:oauthURL];

    id<UIApplicationDelegate> appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate.window.rootViewController presentViewController:safariVC animated:YES completion:nil];

}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {

    NSString *sourceApplication = options[UIApplicationOpenURLOptionsSourceApplicationKey];

    if ([sourceApplication isEqualToString:@"com.apple.mobilesafari"] ||
        [sourceApplication isEqualToString:@"com.apple.SafariViewService"]) {

        NSURL *redirectURI = [NSURL URLWithString:kGithubRedirectURI];

        if ([url.host isEqualToString:redirectURI.host]) {
            NSError *error = nil;
            NSString *authorizationCode = [self authorizationCodeWithRedirectURI:url error:&error];
            
            if (error) {
                return NO;
            }
            
            [self authentcateWithAuthorizationCode:authorizationCode];
            
            return YES;
        }
    }
    
    return YES;
}

#pragma mark - Private Methods

- (NSString *)authorizationCodeWithRedirectURI:(NSURL *)redirectURI error:(NSError **)error {
    //TODO: check redirect URI pattern
    //TODO: handling error
    
    NSString *authorizationCode = @"";
    
    NSArray *queryStrings = [redirectURI.query componentsSeparatedByString:@"&"];
    
    for (NSString *queryString in queryStrings) {
        NSArray *keyAndValue = [queryString componentsSeparatedByString:@"="];

        if ([keyAndValue[0] isEqualToString:@"code"]) {
            authorizationCode = keyAndValue[1];
        } else if ([keyAndValue[0] isEqualToString:@"state"]) {
            int fetchedState = [keyAndValue[1] intValue];

            NSAssert(fetchedState == self.oauthState, @"The fetched state should be equal to the previous state.");
        }
    }
    
    return authorizationCode;
}

- (void)authentcateWithAuthorizationCode:(NSString *)authorizationCode {
    
    NSURLSessionTask *sesstionTask =
    [self.oauth2Manager authenticateUsingOAuthWithURLString:@"/login/oauth/access_token"
                                                       code:authorizationCode
                                                redirectURI:kGithubRedirectURI
                                                    success:^(AFOAuthCredential * _Nonnull credential) {
                                                        BOOL saveResult = [AFOAuthCredential storeCredential:credential
                                                                                              withIdentifier:@"githubclient.marstudio.com"];
                                                    } failure:^(NSError * _Nonnull error) {
                                                        //TODO failure
                                                    }];
    [sesstionTask resume];
    
}

#pragma mark - Assessors

- (AFOAuth2Manager *)oauth2Manager {
    if (nil == _oauth2Manager) {
        _oauth2Manager = [AFOAuth2Manager managerWithBaseURL:[NSURL URLWithString:kGithubAuthorizeBaseURI]
                                                    clientID:kGithubClientID
                                                      secret:kGithubClientSecret];
    }
    
    return _oauth2Manager;
}

@end

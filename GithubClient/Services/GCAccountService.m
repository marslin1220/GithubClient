//
//  GCAccountService.m
//  GithubClient
//
//  Created by Lin Cheng Lung on 30/04/2017.
//  Copyright © 2017 Lin Cheng Lung. All rights reserved.
//

#import <SafariServices/SafariServices.h>

#import "GCAccountService.h"
#import <AFOAuthCredential.h>

// Constants
#import "GCGithubConstant.h"

static NSString *const kOAuthCredentialStorageID = @"githubclient.marstudio.com";

@interface GCAccountService ()

@property int oauthState;
@property SFSafariViewController *safariViewController;

@end

@implementation GCAccountService

- (BOOL)hasAuthorizedWithScope:(AccountAutorizationScope)authorizationScope {
    AFOAuthCredential * credential = [AFOAuthCredential retrieveCredentialWithIdentifier:kOAuthCredentialStorageID];
    
    return credential ? YES : NO;
}

- (void)authorizeWithScope:(AccountAutorizationScope)authorizationScope {

    NSURL *baseURL = [NSURL URLWithString:kGithubAuthorizeBaseURI];
    self.oauthState = arc4random_uniform(RAND_MAX);
    NSString *queryString = [NSString stringWithFormat:@"/login/oauth/authorize?client_id=%@&redirect_uri=%@&state=%d&allow_signup=%@", kGithubClientID, kGithubRedirectURI, self.oauthState, @"false"];
    NSURL *oauthURL = [NSURL URLWithString:queryString relativeToURL:baseURL];

    self.safariViewController = [[SFSafariViewController alloc] initWithURL:oauthURL];

    id<UIApplicationDelegate> appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate.window.rootViewController presentViewController:self.safariViewController animated:YES completion:nil];

}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {

    NSString *sourceApplication = options[UIApplicationOpenURLOptionsSourceApplicationKey];

    if ([sourceApplication isEqualToString:@"com.apple.mobilesafari"] ||
        [sourceApplication isEqualToString:@"com.apple.SafariViewService"]) {

        NSURL *redirectURI = [NSURL URLWithString:kGithubRedirectURI];

        if ([url.host isEqualToString:redirectURI.host]) {
            NSString *authorizationCode = [self authorizationCodeWithRedirectURI:url];
            
            if (nil == authorizationCode) {
                return NO;
            }
            
            [self authentcateWithAuthorizationCode:authorizationCode];
            
            return YES;
        }
    }
    
    return YES;
}

#pragma mark - Private Methods

- (NSString *)authorizationCodeWithRedirectURI:(NSURL *)redirectURI {
    //TODO: check redirect URI pattern
    
    NSString *authorizationCode = nil;
    
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
    
    if (nil == authorizationCode) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Get authorization code failed with URI: %@.", redirectURI],
                                   NSLocalizedRecoverySuggestionErrorKey:@"Try again.",
                                   NSLocalizedFailureReasonErrorKey: @"Parse redirect URI failed"};
        NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                             code:4002
                                         userInfo:userInfo];
        [self. delegate userDidLoginFailedWithError:error];
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
                                                                                              withIdentifier:kOAuthCredentialStorageID];
                                                        if (saveResult) {
                                                            [self.safariViewController dismissViewControllerAnimated:YES
                                                                                                          completion:nil];
                                                            [self.delegate userDidLoginSuccess];
                                                        } else {
                                                            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Save credential failed.",
                                                                                       NSLocalizedRecoverySuggestionErrorKey: @"Try again.",
                                                                                       NSLocalizedFailureReasonErrorKey: @"No idea."};
                                                            
                                                            NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                                                                 code:4001
                                                                                             userInfo:userInfo];
                                                            
                                                            [self.delegate userDidLoginFailedWithError:error];
                                                        }
                                                    } failure:^(NSError * _Nonnull error) {
                                                        [self.delegate userDidLoginFailedWithError:error];
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

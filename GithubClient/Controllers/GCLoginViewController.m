//
//  GCLoginViewController.m
//  GithubClient
//
//  Created by Lin Cheng Lung on 30/04/2017.
//  Copyright © 2017 Lin Cheng Lung. All rights reserved.
//

#import "AccountService.h"

#import "GCLoginViewController.h"

@interface GCLoginViewController ()

@end

@implementation GCLoginViewController

- (void)loadView {
    [super loadView];
    
    // Init Main View
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [view setBackgroundColor:[UIColor whiteColor]];
    NSMutableArray *allConstraints = [NSMutableArray array];

    UIButton *loginButton = [[UIButton alloc] init];
    [loginButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [loginButton setTitle:@"Log in" forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [loginButton setBackgroundColor:[UIColor lightGrayColor]];
    [loginButton addTarget:self
                    action:@selector(didPressLoginButton)
          forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:loginButton];
    
    [allConstraints addObject:
     [NSLayoutConstraint constraintWithItem:loginButton
                                  attribute:NSLayoutAttributeCenterX
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:view
                                  attribute:NSLayoutAttributeCenterX
                                 multiplier:1.0
                                   constant:0.0]];
    
    [allConstraints addObject:
     [NSLayoutConstraint constraintWithItem:loginButton
                                  attribute:NSLayoutAttributeCenterY
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:view
                                  attribute:NSLayoutAttributeCenterY
                                 multiplier:1.0
                                   constant:0.0]];
    
    [view addConstraints:allConstraints];
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didPressLoginButton {
    AccountService *accountService = [AccountService new];
    [accountService authorizeWithScope:AccountAutorizationScopeNone];
}

@end

//
//  GCMainViewController.m
//  GithubClient
//
//  Created by Lin Cheng Lung on 30/04/2017.
//  Copyright © 2017 Lin Cheng Lung. All rights reserved.
//

#import "GCMainViewController.h"

#import "GCStarsTableViewController.h"

@interface GCMainViewController ()

@end

@implementation GCMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Add child VCs
    [self addChildViewControllers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addChildViewControllers {
    
    // Stars VC
    GCStarsTableViewController *starsTVC = [[GCStarsTableViewController alloc] init];
    UINavigationController *starsNC = [[UINavigationController alloc] initWithRootViewController:starsTVC];
    starsNC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Stars" image:nil tag:0];
    [self addChildViewController:starsNC];
    
}

@end

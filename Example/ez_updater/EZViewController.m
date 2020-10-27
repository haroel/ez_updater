//
//  EZViewController.m
//  ez_updater
//
//  Created by whzsgame@gmail.com on 10/27/2020.
//  Copyright (c) 2020 whzsgame@gmail.com. All rights reserved.
//

#import "EZViewController.h"
#import "EZUpdater.h"

@interface EZViewController ()

@end

@implementation EZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // use TestFlight for test!
    [EZUpdater Instance].bundleID = @"com.apple.TestFlight";
    [[EZUpdater Instance] checkAppStoreVersion];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  ViewController.m
//  ARSolarPlay
//
//  Created by Jaspal Sawhney on 8/31/17.
//  Copyright © 2017 Jaspal Sawhney. All rights reserved.
//


#import "ViewController.h"
#import "SCNViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}
- (IBAction)btnClicked:(id)sender {
    
    SCNViewController *scnVC = [[SCNViewController alloc]init];
    [self presentViewController:scnVC animated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


@end

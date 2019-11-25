//
//  ViewController.m
//  ContactManager
//
//  Created by shiyu Sun on 2019/11/22.
//  Copyright © 2019 shiyu Sun. All rights reserved.
//

#import "ViewController.h"
#import "NextViewController.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NextViewController *vc = [[NextViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


@end

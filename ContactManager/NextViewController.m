//
//  NextViewController.m
//  ContactManager
//
//  Created by shiyu Sun on 2019/11/22.
//  Copyright © 2019 shiyu Sun. All rights reserved.
//

#import "NextViewController.h"
#import "ContactManager.h"

@interface NextViewController ()
@property (nonatomic, strong) ContactManager *contactManager; //强引用，否则对象会提前释放后，block也会释放，导致无法回调
@end

@implementation NextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setBackgroundColor:[UIColor yellowColor]];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(selectContact:) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(100, 100, 200, 50);
    btn.center = self.view.center;
    [self.view addSubview:btn];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn2 setBackgroundColor:[UIColor yellowColor]];
    [btn2 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(selectContact2:) forControlEvents:UIControlEventTouchUpInside];
    btn2.frame = CGRectMake(CGRectGetMinX(btn.frame), CGRectGetMaxY(btn.frame) + 40, CGRectGetWidth(btn.frame), CGRectGetHeight(btn.frame));
    [self.view addSubview:btn2];
    
    self.contactManager = [[ContactManager alloc] init];
}

- (void)selectContact:(UIButton *)button
{
    [self.contactManager presentAddressBookViewControllerWithPhoneNumber:^(NSString * _Nonnull phoneNumber) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [button setTitle:phoneNumber forState:UIControlStateNormal];
        });
    }];
    
    //单例写法
//    [[ContactManager shareAddressBook] presentAddressBookViewControllerWithPhoneNumber:^(NSString * _Nonnull phoneNumber) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSLog(@"%@",phoneNumber);
//            [button setTitle:phoneNumber forState:UIControlStateNormal];
//        });
//    }];
    
}

- (void)selectContact2:(UIButton *)button
{
    [self.contactManager presentAddressBookViewControllerWithPhoneNumber:^(NSString * _Nonnull phoneNumber) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [button setTitle:phoneNumber forState:UIControlStateNormal];
        });
    }];
}

@end

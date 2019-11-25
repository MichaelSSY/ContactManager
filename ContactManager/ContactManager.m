//
//  ContactManager.m
//  ContactManager
//
//  Created by shiyu Sun on 2019/11/22.
//  Copyright © 2019 shiyu Sun. All rights reserved.
//

#import "ContactManager.h"
#import <AddressBookUI/AddressBookUI.h>
#import <ContactsUI/ContactsUI.h>

#define KeyWidow [UIApplication sharedApplication].keyWindow

@interface ContactManager ()<ABPeoplePickerNavigationControllerDelegate,CNContactPickerDelegate>

@property (nonatomic, copy) AddressBookOfPhoneNumberBlock phoneNumberBlock;

@end

@implementation ContactManager

#pragma mark - public method

static ContactManager *_addressBook = nil;

+ (instancetype)shareAddressBook
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _addressBook = [[ContactManager alloc] init];
    });
    return _addressBook;
}

- (void)presentAddressBookViewControllerWithPhoneNumber:(AddressBookOfPhoneNumberBlock)addressBookOfPhoneNumber
{
    [self getAddressBookAuthorization:^(BOOL isAuthorization) {
        if (isAuthorization) {
            [self presentABPeoplePickerOrCNContactPickerControllerWithPhoneNumber:addressBookOfPhoneNumber];
        } else {
            [self setContactAuthorization];
        }
    }];
}

- (void)getAddressBookAuthorization:(AddressBookAuthorization)contactAuthorization
{
    NSString *version = [UIDevice currentDevice].systemVersion;
    if (version.doubleValue >= 9.0) {
        CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        if (status == CNAuthorizationStatusNotDetermined) {
            CNContactStore *store = [[CNContactStore alloc] init];
            [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                //第一次获取权限判断，点击 “不允许” 则 granted = NO；点击 “好” 则 granted = YES；
                if (contactAuthorization) {
                    contactAuthorization(granted);
                }
            }];
        } else if (status == CNAuthorizationStatusAuthorized) {//有权限
            if (contactAuthorization) {
                contactAuthorization(YES);
            }
        } else {//无权限
            //NSLog(@"iOS 9 later 您未开启通讯录权限,请前往设置中心开启");
            if (contactAuthorization) {
                contactAuthorization(NO);
            }
        }
    } else {
        ABAddressBookRef bookref = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
        if (status == kABAuthorizationStatusNotDetermined) {
            ABAddressBookRequestAccessWithCompletion(bookref, ^(bool granted, CFErrorRef error) {
                if (contactAuthorization) {
                    contactAuthorization(granted);
                }
            });
        }
        if (status == kABAuthorizationStatusAuthorized) {
            if (contactAuthorization) {
                contactAuthorization(YES);
            }
        }else{
            //NSLog(@"iOS 9 before 您未开启通讯录权限,请前往设置中心开启");
            if (contactAuthorization) {
                contactAuthorization(NO);
            }
        }
    }
}

- (void)presentABPeoplePickerOrCNContactPickerControllerWithPhoneNumber:(AddressBookOfPhoneNumberBlock)phoneNumberBlock
{
    NSString *version = [UIDevice currentDevice].systemVersion;
    //主线程刷新UI
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.phoneNumberBlock = phoneNumberBlock;
        
        if (version.doubleValue >= 9.0) {
            //iOS 9 之后
            CNContactPickerViewController *picker = [[CNContactPickerViewController alloc] init];
            picker.delegate = self;
            //picker.predicateForSelectionOfContact = [NSPredicate predicateWithFormat:@"emailAddresses.@count == 1"];
            //picker.predicateForEnablingContact = [NSPredicate predicateWithFormat:@"emailAddresses.@count > 0"];
            //picker.predicateForSelectionOfProperty = [NSPredicate predicateWithFormat:@"(key == 'emailAddresses') AND (value LIKE '*@mac.com')"];
            picker.displayedPropertyKeys = @[CNContactPhoneNumbersKey];//只显示手机号
            [KeyWidow.rootViewController presentViewController:picker animated:YES completion:nil];
        } else {
            //iOS 9 之前
            ABPeoplePickerNavigationController *picker = [ABPeoplePickerNavigationController new];
            picker.peoplePickerDelegate = self;
            picker.displayedProperties = @[[NSNumber numberWithInt:kABPersonPhoneProperty]];
            [KeyWidow.rootViewController presentViewController:picker animated:YES completion:nil];
        }
        
    });
}

#pragma mark - CNContactPickerDelegate

- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//根据需求选择不同的代理方法

/**
 * 选择单个联系人
 */
//- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact
//{
//    //联系人的信息
//    for (CNLabeledValue *labeledValue in contact.phoneNumbers) {
//        CNPhoneNumber *phoneNumber = labeledValue.value;
//        NSLog(@"%@",phoneNumber.stringValue);
//    }
//}

//只实现该方法时，可以进入到联系人详情页面（如果predicateForSelectionOfProperty属性没被设置或符合筛选条件，如不符合会触发默认操作，即打电话，发邮件等）。
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty;
{
    //CNContact *contact = contactProperty.contact;
    //CNPhoneNumber *phoneNumber = contactProperty.value;
    //NSString *Str = phoneNumber.stringValue;
    //是否把数字都过滤出来
    //NSCharacterSet *setToRemove = [[ NSCharacterSet characterSetWithCharactersInString:@"0123456789"]invertedSet];
    //NSString *phoneStr = [[Str componentsSeparatedByCharactersInSet:setToRemove] componentsJoinedByString:@""];

    //注意：这里和displayedPropertyKeys属性设置相对应；只有 CNPhoneNumber 类型，如果添加别的类型，需要加类型判断，否则可能crash；例如：通讯录中的日期、邮箱...
    CNPhoneNumber *phoneNumber = contactProperty.value;
    NSString *phoneStr = phoneNumber.stringValue;

    //回调block，把号码带回去
    if (self.phoneNumberBlock) {
        self.phoneNumberBlock(phoneStr);
    }
}

//- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContacts:(NSArray<CNContact*> *)contacts
//{
//    for (CNContact *contact in contacts) {
//        for (CNLabeledValue *labeledValue in contact.phoneNumbers) {
//            CNPhoneNumber *phoneNumber = labeledValue.value;
//            NSLog(@"%@%@ --- %@",contact.familyName,contact.givenName,phoneNumber.stringValue);
//        }
//    }
//}

//- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperties:(NSArray<CNContactProperty*> *)contactProperties
//{
//    for (CNContactProperty *contactProperty in contactProperties) {
//        CNPhoneNumber *phoneNumber = contactProperty.value;
//        NSLog(@"%@",phoneNumber.stringValue);
//    }
//}

#pragma mark - ABPeoplePickerNavigationControllerDelegate

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
}

// 当用户选中某一个联系人时会执行该方法,并且选中联系人后会直接退出控制器
//- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person{
//
//}
// 当用户选中某一个联系人的某一个属性时会执行该方法,并且选中属性后会退出控制器
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
    [self peoplePickerNavigationControllerDidCancel:peoplePicker];
    
    // 1.获取选中联系人的姓名
    //CFStringRef lastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
    //CFStringRef firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
    
    // (__bridge NSString *) : 将对象交给Foundation框架的引用来使用,但是内存不交给它来管理
    // (__bridge_transfer NSString *) : 将对象所有权直接交给Foundation框架的应用,并且内存也交给它来管理
    //NSString *lastname = (__bridge_transfer NSString *)(lastName);
    //NSString *firstname = (__bridge_transfer NSString *)(firstName);
    
    //NSLog(@"%@ %@", lastname, firstname);
    
    // 2.获取选中联系人的电话号码
    // 2.1.获取所有的电话号码
    ABMultiValueRef phones = ABRecordCopyValue(person, property);
    CFIndex phoneCount = ABMultiValueGetCount(phones);
    NSString *phoneValue = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phones, identifier);
    // 2.2.遍历拿到每一个电话号码
    //    for (int i = 0; i < phoneCount; i++) {
    //        // 2.2.1.获取电话对应的key
    //        NSString *phoneLabel = (__bridge_transfer NSString *)ABMultiValueCopyLabelAtIndex(phones, i);
    //
    //        // 2.2.2.获取电话号码
    //        NSString *phoneValue = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phones, i);
    //
    //        NSLog(@"%@ %@", phoneLabel, phoneValue);
    //    }
    
    //回调block，把号码带回去
    if (self.phoneNumberBlock) {
        self.phoneNumberBlock(phoneValue);
    }
    
    //注意：管理内存
    CFRelease(phones);
}


#pragma mark - private method

/**
 * 这里只是一个alertView弹框，可以根据需求自定义开通权限View。
 */
- (void)setContactAuthorization
{
    //主线程刷新UI
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您没有开启通讯录权限，去开通权限！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"不了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"这就去" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
                }];
            } else {
                // Fallback on earlier versions
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
        }];

        [alert addAction:action1];
        [alert addAction:action2];
        [KeyWidow.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}

- (void)dealloc
{
    NSLog(@"%@ 释放了",NSStringFromClass([self class]));
}

@end

//
//  ContactManager.h
//  ContactManager
//
//  Created by shiyu Sun on 2019/11/22.
//  Copyright © 2019 shiyu Sun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 通讯录权限Block
 *
 * @param isAuthorization 是否有权限；  YES：有权限；   NO：无权限
 */
typedef void(^AddressBookAuthorization)(BOOL isAuthorization);

/**
 * 通讯录号码Block

 @param phoneNumber 号码
 */
typedef void(^AddressBookOfPhoneNumberBlock)(NSString *phoneNumber);


@interface ContactManager : NSObject

//也可以使用单例模式
//+ (instancetype)shareAddressBook;

/**
 * 模态弹出通讯录列表页
 *
 * @param addressBookOfPhoneNumber block
 */
- (void)presentAddressBookViewControllerWithPhoneNumber:(AddressBookOfPhoneNumberBlock)addressBookOfPhoneNumber;
//- (void)presentContactPickerWithPhone:(void(^)(NSString *phone))addressBookOfPhoneNumber;

/**
 * 获取通讯录权限方法，可以单独使用
 *
 * @param contactAuthorization block
 */
- (void)getAddressBookAuthorization:(AddressBookAuthorization)contactAuthorization;
//- (void)getContactAuthorization:(void(^)(BOOL isAuthorization))contactAuthorization;

@end

NS_ASSUME_NONNULL_END



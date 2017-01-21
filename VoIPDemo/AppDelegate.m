//
//  AppDelegate.m
//  VoIPDemo
//
//  Created by chenjiangchuan on 2017/1/21.
//  Copyright © 2017年 Sayee Intelligent Technology. All rights reserved.
//

#import "AppDelegate.h"
#import <PushKit/PushKit.h>

@interface AppDelegate () <PKPushRegistryDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self registerVoipNotifications];
    
    return YES;
}

/**
 *  注册VoIP
 */
- (void)registerVoipNotifications {
    PKPushRegistry *voipRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
    voipRegistry.delegate = self;
    voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
    NSLog(@"VoIP registered");
    
    UIUserNotificationSettings *userNotifySetting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:userNotifySetting];
}

#pragma mark - PKPushRegistryDelegate

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(PKPushType)type {
    
    NSString *str = [NSString stringWithFormat:@"%@",credentials.token];
    NSString *_tokenStr = [[[str stringByReplacingOccurrencesOfString:@"<" withString:@""]
                            stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"device_token is %@" , str);
}

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type {
    
    UIUserNotificationType theType = [UIApplication sharedApplication].currentUserNotificationSettings.types;
    if (theType == UIUserNotificationTypeNone)
    {
        UIUserNotificationSettings *userNotifySetting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:userNotifySetting];
    }
    
    NSDictionary * dic = payload.dictionaryPayload;
    
    NSLog(@"dic  %@",dic);
    
    if ([dic[@"aps"][@"alert"] isEqualToString:@"call"]) {
        UILocalNotification *backgroudMsg = [[UILocalNotification alloc] init];
        backgroudMsg.alertBody= @"You receive a new call";
        backgroudMsg.soundName = @"ring.caf";
        backgroudMsg.applicationIconBadgeNumber = [[UIApplication sharedApplication]applicationIconBadgeNumber] + 1;
        [[UIApplication sharedApplication] presentLocalNotificationNow:backgroudMsg];
    } else if ([dic[@"aps"][@"alert"] isEqualToString:@"cancel"]) {
        
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
        UILocalNotification * wei = [[UILocalNotification alloc] init];
        wei.alertBody= [NSString stringWithFormat:@"%ld 个未接来电",[[UIApplication sharedApplication]applicationIconBadgeNumber]];
        wei.applicationIconBadgeNumber = [[UIApplication sharedApplication]applicationIconBadgeNumber];
        [[UIApplication sharedApplication] presentLocalNotificationNow:wei];
    }
}

@end

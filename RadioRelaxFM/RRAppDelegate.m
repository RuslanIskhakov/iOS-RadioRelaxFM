//
//  RRAppDelegate.m
//  RadioRelaxFM
//
//  Created by Ruslan Iskhakov on 17.03.14.
//

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "RRAppDelegate.h"
#import "RRAudioPlayer.h"

@interface RRAppDelegate()
@end

@implementation RRAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"Background!");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"Did become Active");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    if(event.type == UIEventTypeRemoteControl)
    {
        switch(event.subtype)
        {
            case UIEventSubtypeRemoteControlPause:
                NSLog(@"ControlPause");
                break;
            case UIEventSubtypeRemoteControlStop:
                NSLog(@"ControlStop");
                break;
            case UIEventSubtypeRemoteControlPlay:
                NSLog(@"ControlPlay");
                break;
            case UIEventSubtypeRemoteControlTogglePlayPause:
                NSLog(@"TogglePlayPause");
                break;
            default:
                NSLog(@"default");
                break;
        }
    }
}

@end

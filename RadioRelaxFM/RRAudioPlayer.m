//
//  RMAudioPlayer.m
//  Radio Manhattan
//
//  Created by Deltasoft on 13.09.14.
//  Copyright (c) 2014 Deltasoft. All rights reserved.
//

#import "RRAudioPlayer.h"

@interface RMAudioPlayer()
@property (strong, nonatomic) AVPlayer *audioPlayer;
@property (atomic) BOOL isPlaying;
@end

NSObject *mSyncObject;

@implementation RMAudioPlayer

//http://stackoverflow.com/questions/9276546/can-not-restart-an-interrupted-audio-input-queue-in-background-mode-on-ios

- (AVPlayer *)audioPlayer
{
    if (!_audioPlayer) {
        NSString *urlString = @"http://101.ru/m101.php?uid=200";
        NSURL *url = [NSURL URLWithString:urlString];
        _audioPlayer = [[AVPlayer alloc] initWithURL:url];
        if (!_audioPlayer) NSLog(@"NULL!!!");
        _audioPlayer.volume=1.0;
    }
    
    return _audioPlayer;
}

- (instancetype) init
{
    NSLog(@"RMAudioPlayer Init");
    self.isPlaying = NO;
    mSyncObject = [[NSObject alloc] init];
    return [super init];
}

- (void) onPlayButtonTapUp
{
    if (self.isPlaying){
        self.isPlaying = NO;
        NSLog(@"Cmd Stop");
    } else {
        self.isPlaying = YES;
        [NSThread detachNewThreadSelector:@selector(audioThreadMethod)
                                 toTarget:self
                               withObject:nil];
        
        NSLog(@"Cmd Play");
    }
}

- (void) audioThreadMethod
{
    
    
    @autoreleasepool {
        
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        NSLog(@"Audio Thread is starting");
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        
        NSError *setCategoryError = nil;
        BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback
                                     withOptions:AVAudioSessionCategoryOptionMixWithOthers
                                           error:&setCategoryError];
        if (!success) { return; }
        
        success = [audioSession setMode:AVAudioSessionModeDefault error:&setCategoryError];
        if (!success) { return; }
        
        NSError *activationError = nil;
        success = [audioSession setActive:YES error:&activationError];
        if (!success) { return; }
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(audioSessionInterruptionNotificationReceived:)
                   name:AVAudioSessionInterruptionNotification
                 object:nil];
        
        [self.audioPlayer play];
        
        do {
            @autoreleasepool {
                NSLog(@"Audio Thread loop");
                [runLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:10]];
            }
        } while (self.isPlaying);
        
        
        [self.audioPlayer pause];
        //audioSession = [AVAudioSession sharedInstance];
        NSError *deactivationError = nil;
        success = [audioSession setActive:NO error:&deactivationError];
        if (!success) {
            NSLog(@"@Audio Session deactivation error: %@",deactivationError.debugDescription);
        }
        
        //NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self];
        
        NSLog(@"Audio Thread is stopping");
    }
}

- (void)audioSessionInterruptionNotificationReceived:(NSNotification *)notification
{
    NSNumber *interruptionType = [[notification userInfo] objectForKey:AVAudioSessionInterruptionTypeKey];
    NSNumber *interruptionOption = [[notification userInfo] objectForKey:AVAudioSessionInterruptionOptionKey];
    
    switch (interruptionType.unsignedIntegerValue) {
        case AVAudioSessionInterruptionTypeBegan:{
            NSLog(@"Audio Interruption Begin");
            if (self.isPlaying){
                [self.audioPlayer pause];
            }
        } break;
        case AVAudioSessionInterruptionTypeEnded:{
            // • Make session active
            // • Update user interface
            // • AVAudioSessionInterruptionOptionShouldResume option
            if (interruptionOption.unsignedIntegerValue == AVAudioSessionInterruptionOptionShouldResume) {
                NSLog(@"Audio Interruption End");
                if (self.isPlaying){
                    
                    int status = self.audioPlayer.status;
                    if (AVPlayerStatusFailed==status) {
                        NSLog(@"Status: Failed");
                    } else if (AVPlayerStatusReadyToPlay==status) {
                        NSLog(@"Status: Ready To Play");
                    } else if (AVPlayerStatusUnknown==status) {
                        NSLog(@"Status: Uknown");
                    }
                    
                    [self.audioPlayer play];
                }
            }
        } break;
        default:
            break;
    }
}

@end

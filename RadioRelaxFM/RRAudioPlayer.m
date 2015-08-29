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
@property (nonatomic) BOOL isPlaying;
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
        [self.audioPlayer pause];
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        NSError *activationError = nil;
        BOOL success = [audioSession setActive:NO error:&activationError];
        if (!success) {
            NSLog(@"@Audio Session deactivation error: %@",activationError.debugDescription);
        }
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self];
        
    } else {
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
        NSLog(@"Play");
    }
    self.isPlaying = !self.isPlaying;
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
                self.isPlaying = NO;
            }
        } break;
        case AVAudioSessionInterruptionTypeEnded:{
            // • Make session active
            // • Update user interface
            // • AVAudioSessionInterruptionOptionShouldResume option
            if (interruptionOption.unsignedIntegerValue == AVAudioSessionInterruptionOptionShouldResume) {
                NSLog(@"Audio Interruption End");
                if (!self.isPlaying){
                    
                    int status = self.audioPlayer.status;
                    if (AVPlayerStatusFailed==status) {
                        NSLog(@"Status: Failed");
                    } else if (AVPlayerStatusReadyToPlay==status) {
                        NSLog(@"Status: Ready To Play");
                    } else if (AVPlayerStatusUnknown==status) {
                        NSLog(@"Status: Uknown");
                    }
                    
                    [self.audioPlayer play];
                    self.isPlaying = YES;
                }
            }
        } break;
        default:
            break;
    }
}

@end

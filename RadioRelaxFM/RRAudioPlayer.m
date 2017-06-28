//
//  RRAudioPlayer.m
//  Radio Relax FM
//
//  Created by Deltasoft on 13.09.14.
//  Copyright (c) 2014 Deltasoft. All rights reserved.
//

#import "RRAudioPlayer.h"

@interface RRAudioPlayer()
@property (strong, nonatomic) AVPlayer *audioPlayer;
@property (atomic) BOOL isPlaying;
@end

static RRAudioPlayer *instance=nil;

@implementation RRAudioPlayer

//http://stackoverflow.com/questions/9276546/can-not-restart-an-interrupted-audio-input-queue-in-background-mode-on-ios

+ (RRAudioPlayer*)getInstance
{
    @synchronized(self)
    {
        if(instance==nil)
        {
            instance= [[RRAudioPlayer alloc] init];
        }
    }
    return instance;
}

- (AVPlayer *)audioPlayer
{
    if (!_audioPlayer) {
        NSString *urlString = @"http://101.ru/api/channel/getServers/200/channel/MP3/128/dataFormat/mobile";
        NSURL *url = [NSURL URLWithString:urlString];
        _audioPlayer = [[AVPlayer alloc] initWithURL:url];
        if (!_audioPlayer) NSLog(@"NULL!!!");
        _audioPlayer.volume=1.0;
    }
    
    return _audioPlayer;
}

- (instancetype) init
{
    NSLog(@"RRAudioPlayer Init");
    self.isPlaying = NO;
    return [super init];
}

- (BOOL) onPlayButtonTapUp
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
        
        //[self configureRemoteControl];
    }
    return self.isPlaying;
}

- (void) configureRemoteControl
{
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    
    commandCenter.playCommand.enabled = YES;
    commandCenter.pauseCommand.enabled = YES;
    
    [commandCenter.playCommand addTarget:self action:@selector(onRemotePlayCmd)];
    [commandCenter.pauseCommand addTarget:self action:@selector(onRemotePauseCmd)];
}

- (void)configureNowPlayingInfo:(MPMediaItem*)item
{
    MPNowPlayingInfoCenter* info = [MPNowPlayingInfoCenter defaultCenter];
    NSMutableDictionary* newInfo = [NSMutableDictionary dictionary];
    NSSet* itemProperties = [NSSet setWithObjects:MPMediaItemPropertyTitle,
                             MPMediaItemPropertyArtist,
                             MPMediaItemPropertyPlaybackDuration,
                             MPNowPlayingInfoPropertyElapsedPlaybackTime,
                             nil];
    
    [item enumerateValuesForProperties:itemProperties
                            usingBlock:^(NSString *property, id value, BOOL *stop) {
                                NSLog(@"Requesting info: %@",property);
                                [newInfo setObject:value forKey:property];
                            }];
    
    info.nowPlayingInfo = newInfo;
}

- (void) onRemotePlayCmd
{
    NSLog(@"onRemotePlayCmd");
}

- (void) onRemotePauseCmd
{
    NSLog(@"onRemoteStopCmd");
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
        
        //[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        
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
                [runLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:10]];
                [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
            }
        } while (self.isPlaying);
        
        
        [self.audioPlayer pause];
        self.audioPlayer = nil;
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

//
//  RRAudioPlayer.h
//  Radio Relax FM
//
//  Created by Deltasoft on 13.09.14.
//  Copyright (c) 2014 Deltasoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface RRAudioPlayer : NSObject

+ (RRAudioPlayer*) sharedInstance;
- (BOOL) onPlayButtonTapUp;
@property (atomic, readonly) BOOL isPlaying;

@end

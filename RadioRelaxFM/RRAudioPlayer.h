//
//  RRAudioPlayer.h
//  RadioRelaxFM
//
//  Created by Ruslan Iskhakov on 13.09.14.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface RRAudioPlayer : NSObject

+ (RRAudioPlayer*) sharedInstance;
- (BOOL) onPlayButtonTapUp;
@property (atomic, readonly) BOOL isPlaying;

@end

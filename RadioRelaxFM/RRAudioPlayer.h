//
//  RRAudioPlayer.h
//  Radio Relax FM
//
//  Created by Deltasoft on 13.09.14.
//  Copyright (c) 2014 Deltasoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface RRAudioPlayer : NSObject

+ (RRAudioPlayer*) getInstance;
- (BOOL) onPlayButtonTapUp;

@end

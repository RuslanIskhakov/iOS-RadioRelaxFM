//
//  RRFirstViewController.h
//  Radio Relax FM
//
//  Created by Deltasoft on 17.03.14.
//  Copyright (c) 2014 Deltasoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RRAudioTrackInfo.h"

@interface RRFirstViewController : UIViewController<OnAudioTrackInfoUpdatedProtocol>
@property (atomic, readonly) BOOL isPlaying;
- (void)onAudioTrackTitleUpdate:(NSString*)title;
- (void)onAudioAlbumCoverUpdated:(UIImage*) cover;
@end

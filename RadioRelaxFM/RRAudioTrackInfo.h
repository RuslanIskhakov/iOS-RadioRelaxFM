//
//  RRAudioTrackInfo.h
//  RadioRelaxFM
//
//  Created by Ruslan Iskhakov on 02.09.15.
//  Copyright (c) 2015 Deltasoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OnAudioTrackInfoUpdatedProtocol
- (void)onAudioTrackTitleUpdate:(NSString*)title;
- (void)onAudioAlbumCoverUpdated: (UIImage*) cover;
@end

@interface RRAudioTrackInfo : NSObject <NSURLConnectionDelegate,NSURLConnectionDataDelegate>

+ (RRAudioTrackInfo*) sharedInstance: (id<OnAudioTrackInfoUpdatedProtocol>) delegate;
- (void) onPlayButtonTapUp: (BOOL) isPlaying;

@end

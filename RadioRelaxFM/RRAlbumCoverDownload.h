//
//  RRAlbumCoverDownload.h
//  RadioRelaxFM
//
//  Created by Ruslan Iskhakov on 04.09.15.
//

#import <Foundation/Foundation.h>
#import "RRAudioTrackInfo.h"

@interface RRAlbumCoverDownload : NSObject <NSURLConnectionDelegate,NSURLConnectionDataDelegate>
-(instancetype) initWithDelegate:(id<OnAudioTrackInfoUpdatedProtocol>) delegate andTrackTitle:(NSString*) title;
-(void)cancel;
@end

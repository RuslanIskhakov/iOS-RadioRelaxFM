//
//  RRFirstViewController.h
//  RadioRelaxFM
//
//  Created by Ruslan Iskhakov on 17.03.14.
//

#import <UIKit/UIKit.h>
#import "RRAudioTrackInfo.h"

@interface RRFirstViewController : UIViewController<OnAudioTrackInfoUpdatedProtocol>
- (void)onAudioTrackTitleUpdate:(NSString*)title;
- (void)onAudioAlbumCoverUpdated:(UIImage*) cover;
@end

//
//  RRAlbumCoverDownload.m
//  RadioRelaxFM
//
//  Created by Ruslan Iskhakov on 04.09.15.
//

#import "RRAlbumCoverDownload.h"

#define COVER_INFO_URL @"https://itunes.apple.com/search?term="
#define ARTWORK_KEY @"artworkUrl100"
#define RESULTSCOUNT_KEY @"resultsCount"
#define RESULTS_KEY @"results"
#define SIZE100_SUFFIX @"100x100"
#define SIZE600_SUFFIX @"600x600"

@interface RRAlbumCoverDownload()

@property (weak, nonatomic) id<OnAudioTrackInfoUpdatedProtocol> delegate;
@property (strong, nonatomic) NSMutableData *bytesData;
@property (atomic) BOOL isRunning;

@end

@implementation RRAlbumCoverDownload

-(instancetype) initWithDelegate:(id<OnAudioTrackInfoUpdatedProtocol>) delegate andTrackTitle:(NSString*) title
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.isRunning = YES;
        [NSThread detachNewThreadSelector:@selector(downloadAlbumCover:)
                                 toTarget:self
                               withObject:title];
    }
    return self;
}

-(void) cancel {
    self.isRunning = NO;
}

-(void) downloadAlbumCover:(NSString*) title
{
    @autoreleasepool {
        
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        //NSLog(@"Album Cover Download Thread is starting");
        
        self.bytesData = [[NSMutableData alloc] initWithCapacity:0];

        @try {
            NSString *encodedTitle = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                       NULL,
                                                                                                       (CFStringRef)title,
                                                                                                       NULL,
                                                                                                       (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                       kCFStringEncodingUTF8 ));
        
            NSString *requestUrl = [COVER_INFO_URL stringByAppendingString:encodedTitle];
            //NSLog(@"Cover request URL: %@",requestUrl);
 
            NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]
                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                           timeoutInterval:15.0];
        
            NSError *error;
            NSURLResponse *response = [[NSURLResponse alloc] init];
        
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            if (error) {
                //NSLog(@"Cover URL request ERROR: %@",error.debugDescription);
                self.isRunning = NO;
                @throw [[NSException alloc] init];
            } else {
                NSMutableDictionary *returnedDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                id results = [returnedDict objectForKey:RESULTS_KEY];
                if ([results isKindOfClass:[NSArray class]]) {
                    NSString *coverUrl = [[results[0] objectForKey:ARTWORK_KEY] stringByReplacingOccurrencesOfString:SIZE100_SUFFIX withString:SIZE600_SUFFIX];
                    //NSLog(@"Cover URL: %@",coverUrl);
                
                    NSURLRequest *coverRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:coverUrl]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:15.0];

                    NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:coverRequest delegate:self startImmediately:NO];
                    @try {
                        if (!connection) {
                            //NSLog(@"Can't connect");
                            self.isRunning = NO;
                            @throw [[NSException alloc] init];
                        } else {
                    
                            [connection scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                                  forMode:NSDefaultRunLoopMode];
                            [connection start];
                        }
                    } @catch (NSException *e) {
                        @try {
                            [connection cancel];
                        }
                        @catch (NSException *e1) {}
                        @throw [[NSException alloc] init];
                    }
                } else {
                    @throw [[NSException alloc] init];
                }
            }
        }@catch (NSException *e) {
            [self displayDefaultCoverArt];
            //NSLog(@"Exception on downloadAlbumCover: %@", e.description);
        }
        do {
            @autoreleasepool {
                [runLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];
                [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
            }
        } while (self.isRunning);
        
        //NSLog(@"Album Cover Download is stopping");
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.bytesData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    self.isRunning = NO;
    [self displayDefaultCoverArt];
    //NSLog(@"RRAlbumCoverDownload::Connection failed! Error - %@ %@",
    //      [error localizedDescription],
    //      [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //NSLog(@"RRAlbumCoverDownload::Loading is finished");
    //NSLog(@"Cover data length: %lu",(unsigned long)self.bytesData.length);
    UIImage *coverImage = [[UIImage alloc ] initWithData:self.bytesData];
    //NSLog(@"Cover size: %f, %f", coverImage.size.width, coverImage.size.height);
    if (self.delegate) {
        [self.delegate onAudioAlbumCoverUpdated:coverImage];
    }

}

- (void) displayDefaultCoverArt
{
    if (self.delegate) {
        [self.delegate onAudioAlbumCoverUpdated:[UIImage imageNamed:@"music_disc"]];
    }
}

@end

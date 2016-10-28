//
//  RRAudioTrackInfo.m
//  RadioRelaxFM
//
//  Created by Ruslan Iskhakov on 02.09.15.
//  Copyright (c) 2015 Deltasoft. All rights reserved.
//

#import "RRAudioTrackInfo.h"
#import "RRAlbumCoverDownload.h"

#define TRACK_INFO_URL @"http://relax-fm.ru/api/getplayingtrackinfo.php?station_id=100&_=%ld"
#define STATUS_KEY @"status"
#define ERROR_CODE_KEY @"errorCode"
#define RESULT_KEY @"result"
#define EXECUTOR_TITLE_KEY @"executor_title"
#define TITLE_KEY @"title"

@interface RRAudioTrackInfo()
@property (atomic) BOOL isRunning;
@property (strong) NSMutableData *bytesData;
@property (strong, atomic) id<OnAudioTrackInfoUpdatedProtocol> delegate;
@property (strong, nonatomic) NSString *prevTrackTitle;
@property (strong) RRAlbumCoverDownload *coverDownloader;
@end

static RRAudioTrackInfo *instance=nil;

@implementation RRAudioTrackInfo

+ (RRAudioTrackInfo*)getInstance: (id<OnAudioTrackInfoUpdatedProtocol>) delegate
{
    @synchronized(self)
    {
        if(instance==nil)
        {
            instance= [[RRAudioTrackInfo alloc] init];
        }
    }
    instance.delegate = delegate;
    return instance;
}

-(instancetype) init
{
    self.isRunning = NO;
    return [super init];
}

- (NSString*)prevTrackTitle
{
    if (!_prevTrackTitle) {
        _prevTrackTitle = @"";
    }
    return _prevTrackTitle;
}

- (void) onPlayButtonTapUp: (BOOL) isPlaying
{
    self.isRunning = isPlaying;
    if (self.isRunning) {
        [NSThread detachNewThreadSelector:@selector(audioTrackInfoThreadMethod)
                                 toTarget:self
                               withObject:nil];
    }
}

- (void) audioTrackInfoThreadMethod
{
    @autoreleasepool {
        
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        NSLog(@"Audio Track Info Thread is starting");
        
        [self requestAudioTrackInfo];
        
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:20
                                         target:self
                                       selector:@selector(timerMethod)
                                       userInfo:nil
                                        repeats:YES];
        
        do {
            @autoreleasepool {
                [runLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:10]];
            }
        } while (self.isRunning);
        
        [timer invalidate];
        
        NSLog(@"Audio Track Info Thread is stopping");
    }
}

- (void) timerMethod
{
    if (self.isRunning) {
        [self requestAudioTrackInfo];
    }
}


- (void) requestAudioTrackInfo
{
    self.bytesData = [[NSMutableData alloc] initWithCapacity:0];
    long ts = [[NSDate date] timeIntervalSince1970];
    NSURLConnection *connection = nil;
    @try{
        NSString *requestUrl = [NSString stringWithFormat:TRACK_INFO_URL,ts];
        NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]
                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                       timeoutInterval:15.0];
    
        connection=[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        if (!connection) {
            NSLog(@"Can't connect");
            @throw [[NSException alloc] init];
        }

        [connection scheduleInRunLoop:[NSRunLoop currentRunLoop]
                          forMode:NSDefaultRunLoopMode];
        [connection start];
    } @catch (NSException *e) {
        @try {
            [connection cancel];
        } @catch (NSException *e){}
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"Bytes: %lu",(unsigned long)data.length);
    [self.bytesData appendData:data];

}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    self.isRunning = NO;
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Loading is finished");
    
    @try{
        NSError *error;
        NSMutableDictionary *returnedDict = [NSJSONSerialization JSONObjectWithData:self.bytesData options:kNilOptions error:&error];
        
        if (error != nil) {
            NSLog(@"Error: %@", [error localizedDescription]);
        }else{
            if (0==[[returnedDict objectForKey:STATUS_KEY] intValue] && 0==[[returnedDict objectForKey:ERROR_CODE_KEY] intValue]){
                id result = [returnedDict objectForKey:RESULT_KEY];
                if ([result isKindOfClass:[NSDictionary class]]) {
                    NSString *audioTrackTitle = [NSString stringWithFormat:@"%@ - %@",[result objectForKey:EXECUTOR_TITLE_KEY],[result objectForKey:TITLE_KEY]];
                    if (self.delegate) {
                        [self.delegate onAudioTrackTitleUpdate:audioTrackTitle];
                    }
                
                    if (![self.prevTrackTitle isEqualToString:audioTrackTitle]) {
                        self.prevTrackTitle = audioTrackTitle;
                        self.coverDownloader = [[RRAlbumCoverDownload alloc] initWithDelegate:self.delegate andTrackTitle:self.prevTrackTitle];
                    }
                } else {
                    NSLog(@"actually is a class: %@", [result class]);
                }
            } else {
                NSLog(@"Status: %d, Error: %d", [[returnedDict objectForKey:STATUS_KEY] intValue], [[returnedDict objectForKey:ERROR_CODE_KEY] intValue]);
            }
        }
    }@catch(NSException *e) {
        NSLog(@"Exception: %@", [e description]);
    }
}
@end

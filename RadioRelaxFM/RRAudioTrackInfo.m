//
//  RRAudioTrackInfo.m
//  RadioRelaxFM
//
//  Created by Ruslan Iskhakov on 02.09.15.
//  Copyright (c) 2015 Deltasoft. All rights reserved.
//

#import "RRAudioTrackInfo.h"

#define TRACK_INFO_URL @"http://relax-fm.ru/api/getplayingtrackinfo.php?station_id=100&_=%ld"
#define STATUS_KEY @"status"
#define ERROR_CODE_KEY @"errorCode"
#define RESULT_KEY @"result"
#define EXECUTOR_TITLE_KEY @"executor_title"
#define TITLE_KEY @"title"

@interface RRAudioTrackInfo()
@property (atomic) BOOL isPlaying;
@property int bytes;
@property (strong) NSMutableData *bytesData;
@property (strong, atomic) id<OnAudioTrackInfoUpdatedProtocol> delegate;
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
    self.isPlaying = NO;
    return [super init];
}

- (void) onPlayButtonTapUp: (BOOL) isPlaying
{
    self.isPlaying = isPlaying;
    if (self.isPlaying) {
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
        } while (self.isPlaying);
        
        [timer invalidate];
        
        NSLog(@"Audio Track Info Thread is stopping");
    }
}

- (void) timerMethod
{
    if (self.isPlaying) {
        [self requestAudioTrackInfo];
    }
}


- (void) requestAudioTrackInfo
{
    self.bytes = 0;
    self.bytesData = [[NSMutableData alloc] initWithCapacity:0];
    long ts = [[NSDate date] timeIntervalSince1970];
    NSString *requestUrl = [NSString stringWithFormat:TRACK_INFO_URL,ts];
    
    NSLog(@"Timer tick: %@",requestUrl);
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]
                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                       timeoutInterval:15.0];
    
    NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    if (!connection) {
        NSLog(@"Can't connect");
    }

    [connection scheduleInRunLoop:[NSRunLoop currentRunLoop]
                          forMode:NSDefaultRunLoopMode];
    [connection start];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"Response is received");
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"Bytes: %lu",(unsigned long)data.length);
    self.bytes += data.length;
    [self.bytesData appendData:data];

}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Loading is finished");
    
    NSError *error;
    NSMutableDictionary *returnedDict = [NSJSONSerialization JSONObjectWithData:self.bytesData options:kNilOptions error:&error];
    
    if (error != nil) {
        NSLog(@"1: %@", [error localizedDescription]);
    }
    else{
        if (0==[[returnedDict objectForKey:STATUS_KEY] intValue] && 0==[[returnedDict objectForKey:ERROR_CODE_KEY] intValue]){
            id result = [returnedDict objectForKey:RESULT_KEY];
            if ([result isKindOfClass:[NSMutableDictionary class]]) {
                NSString *audioTrackTitle = [NSString stringWithFormat:@"%@ - %@",[result objectForKey:EXECUTOR_TITLE_KEY],[result objectForKey:TITLE_KEY]];
                if (self.delegate) {
                    [self.delegate onAudioTrackTitleUpdate:audioTrackTitle];
                }
            }
        } else {
            NSLog(@"Status: %d, Error: %d", [[returnedDict objectForKey:STATUS_KEY] intValue], [[returnedDict objectForKey:ERROR_CODE_KEY] intValue]);
        }
    }

}
@end

//
//  MMSyncThread.m
//  momo
//
//  Created by houxh on 11-7-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MMSyncThread.h"
#import "MMContactSync.h"
#import "MMServerContactManager.h"
#import "DbStruct.h"
#import "MMContact.h"
#import "MMLogger.h"

@interface MMSyncThread()

@property(nonatomic, assign)BOOL isChanged;

-(BOOL)sync;
-(void)wakeUpRunLoop:(CFRunLoopRef)runLoop;

@end

@implementation MMSyncThread
@synthesize isSyncing = isSyncing_;
@synthesize isChanged;

-(BOOL)beginSync {
    if (isSyncing_) {
        return NO;
    }
    
    pthread_mutex_lock(&mutex_);
    if (nil == runLoop_) {
        pthread_mutex_unlock(&mutex_);
        return NO;
    }
    CFRunLoopPerformBlock(runLoop_, kCFRunLoopDefaultMode, ^(void){
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kMMBeginSync object:nil];
        });
        self.isSyncing = YES;
        
        lastSyncResult_ = [self sync];
        if (!lastSyncResult_) {
            MLOG(@"同步失败");
        }
        
        self.isSyncing = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            [userInfo setObject:BOOL_NUMBER(lastSyncResult_) forKey:@"result"];
            [userInfo setObject:BOOL_NUMBER(self.isChanged) forKey:@"changed"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kMMEndSync object:userInfo];
        });
    } );
    [self wakeUpRunLoop:runLoop_];
    pthread_mutex_unlock(&mutex_);
	return YES;
}



void timerCallback(CFRunLoopTimerRef timer, void *info) {
}

-(void)wakeUpRunLoop:(CFRunLoopRef)runLoop {
	//wakeup sync thread!!!!!!!!
	CFRunLoopTimerContext context1 = {0, (void*)NULL, NULL, NULL, NULL};
	CFRunLoopTimerRef timer = CFRunLoopTimerCreate(NULL, 0, 0, 0, 0, (CFRunLoopTimerCallBack)timerCallback, (CFRunLoopTimerContext*)&context1);
	CFRunLoopAddTimer(runLoop, timer, kCFRunLoopDefaultMode);
	CFRelease(timer);
	CFRunLoopWakeUp(runLoop);
}

-(void)cancel {
	[super cancel];
    pthread_mutex_lock(&mutex_);
    while (nil == runLoop_) {
        pthread_cond_wait(&condition_, &mutex_);
    }
    assert(runLoop_);
    CFRunLoopPerformBlock(runLoop_, kCFRunLoopDefaultMode, ^(void){
        //在CFRunloop过程中此函数才有效
        CFRunLoopStop(CFRunLoopGetCurrent());
    } );
    [self wakeUpRunLoop:runLoop_];
    pthread_mutex_unlock(&mutex_);
}


+ (MMSyncThread*)shareInstance {
	static MMSyncThread* instance = nil;
	if(!instance) {
		@synchronized(self) {
			if(!instance) {
				instance = [[[MMSyncThread alloc] init] autorelease];
			}
		}
	}
	return instance;
}

-(id)init {
	self = [super initWithTarget:nil selector:nil object:nil];
	if (self) {
        int result = pthread_mutex_init(&mutex_, 0);
        assert(0 == result);
        result = pthread_cond_init(&condition_, 0);
        assert(0 == result);
	}
	return self;
}

-(void)dealloc {
    pthread_mutex_destroy(&mutex_);
    pthread_cond_destroy(&condition_);
	[super dealloc];
}

-(BOOL)remoteSync {
    
	MMContactSync *syncer = [[[MMContactSync alloc] init] autorelease];

    BEGIN_TICKET(downcontacttomomo);
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if (![syncer downloadContactToMomo]) {
        [pool release];
		return NO;
	}
    [pool release];
    END_TICKET(downcontacttomomo);
    
    if (syncer.addedCount > 0 || syncer.updatedCount > 0 || syncer.deletedCout > 0) {
        self.isChanged = YES;
    } else {
        self.isChanged = NO;
    }
    
	return YES;
}

-(BOOL)sync {
    return [self remoteSync];
}


- (void)main {
    pthread_mutex_lock(&mutex_);
	runLoop_ = CFRunLoopGetCurrent();
    pthread_cond_signal(&condition_);
    pthread_mutex_unlock(&mutex_);

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	CFRunLoopSourceContext context = {0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL};
	CFRunLoopSourceRef source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
	CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);

    CFRunLoopRun();
    
	// Should never be called, but anyway
	CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
	CFRelease(source);

    
	[pool release];
    
	pthread_mutex_lock(&mutex_);
    runLoop_ = nil;
	pthread_mutex_unlock(&mutex_);
}

@end

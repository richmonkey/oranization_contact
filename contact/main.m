//
//  main.m
//  contact
//
//  Created by houxh on 14-11-4.
//  Copyright (c) 2014年 momo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        //保证多线程模式
        NSObject* tmpObject = [[NSObject alloc] init];
        [tmpObject performSelectorInBackground:@selector(release) withObject:nil];
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}

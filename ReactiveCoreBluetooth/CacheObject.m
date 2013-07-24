//
//  CacheObject.m
//  ReactiveCoreBluetooth
//
//  Created by Matt Bowman on 7/23/13.
//  Copyright (c) 2013 Citrrus, LLC. All rights reserved.
//

#import "CacheObject.h"

@implementation CacheObject

-(id) initWithObject:(id) obj andLifespan:(NSTimeInterval)lifespan
{
    self = [super init];
    
    if (self)
    {
        self.expirationDate = [NSDate dateWithTimeIntervalSinceNow:lifespan];
        self.object = obj;
    }
    
    return self;
}

-(BOOL) isExpired
{
    NSDate* now = [NSDate date];
    if ([now compare:self.expirationDate] == NSOrderedDescending)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

@end

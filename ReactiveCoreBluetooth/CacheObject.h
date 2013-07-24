//
//  CacheObject.h
//  ReactiveCoreBluetooth
//
//  Created by Matt Bowman on 7/23/13.
//  Copyright (c) 2013 Citrrus, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheObject : NSObject

@property (nonatomic) NSDate* expirationDate;
@property (nonatomic) id object;

-(id) initWithObject:(id) obj andLifespan:(NSTimeInterval)lifespan;

-(BOOL)isExpired;

@end

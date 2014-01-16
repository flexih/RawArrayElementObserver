//
//  NSObject+RawRawArrayElementObserver.h
//  RawArrayElementObserver
//
//  Created by flexih on 1/16/14.
//  Copyright (c) 2014 flexih. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (RawRawArrayElementObserver)

/**
 keyPath format:
 ivar[index]
 */
- (NSString *)keyPathForIvar:(NSString *)ivar index:(NSUInteger)index;

@end

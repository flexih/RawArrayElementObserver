//
//  RawArrayElementObserver.h
//  RawArrayElementObserver
//
//  Created by flexih on 1/9/14.
//  Copyright (c) 2014 flexih. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 what:
    add observer for array element, element setter wrappered by NSValue
 how:
    inherite(recommended) or copy the methods to your class
 */

@interface RawArrayElementObserver : NSObject

/**
 keyPath format:
    ivar[index]
 */
- (NSString *)keyPathForIvar:(NSString *)ivar index:(NSInteger)index;

@end

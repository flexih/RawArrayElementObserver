//
//  RawArrayElementObserver.m
//  RawArrayElementObserver
//
//  Created by flexih on 1/9/14.
//  Copyright (c) 2014 flexih. All rights reserved.
//

#import "RawArrayElementObserver.h"
#import <objc/runtime.h>

/**
 only support basic types, extendable
 */
static size_t
encoding_type_length(const char *p, size_t len)
{
    switch (p[0]) {
        case 'c':
        case 'C':
        case 'b':
            return sizeof(char);
        case 'i':
        case 'I':
            return sizeof(int);
        case 's':
        case 'S':
            return sizeof(short);
        case 'l':
        case 'L':
            return sizeof(long);
        case 'q':
        case 'Q':
            return sizeof(long long);
        case 'f':
            return sizeof(float);
        case 'd':
            return sizeof(double);
        case '*':
        case ':':
        case '^':
            return sizeof(void *);
        case '@':
        case '#':
            return sizeof(id);
        default:
            assert(!"only basic types");
            return 0;
    }
}

/**
 @param ivararr
        array ivar name
 @param pbase
        out array base pointer
 @param carr
        out array count
 @param esz
        out array element size
 @prama et
        out array element encoding type, caller responsible to free. NULL allowed.
 */

static BOOL
instance_variable(NSObject *obj, const char *ivararr, void **pbase, size_t *carr, size_t *esz, char **et)
{
    Ivar ivar = class_getInstanceVariable(obj.class, ivararr);
    if (ivar != NULL) {
        const char *type = ivar_getTypeEncoding(ivar);
        char encoding[strlen(type) - 2];
        int count;
        
        if (sscanf(type, "[%d%s]", &count, encoding) == 2) {
            encoding[strlen(encoding) - 1] = '\0';
            void *p = (char *)(__bridge void *)obj + ivar_getOffset(ivar);
            
            *pbase = p;
            *carr = count;
            *esz = encoding_type_length(encoding, strlen(encoding));
            
            if (et != NULL) {
                *et = strdup(encoding);
            }
            
            return YES;
        }
    }
    
    return NO;
}

@implementation RawArrayElementObserver

- (NSString *)keyPathForIvar:(NSString *)ivar index:(NSUInteger)index
{
    return [NSString stringWithFormat:@"%@[%lu]", ivar, (unsigned long)index];
}

- (BOOL)validateKey:(NSString *)key ivar:(NSString * __autoreleasing *)ivar index:(NSUInteger *)index
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF LIKE %@", @"*[?*]"];
    
    if ([predicate evaluateWithObject:key]) {
        NSUInteger location = [key rangeOfString:@"["].location;
        NSScanner *scanner = [NSScanner scannerWithString:key];
        [scanner setScanLocation:location + 1];
        
        if ([scanner scanInteger:index]) {
            NSString *var = [key substringToIndex:location];
            if (ivar != nil) {
                *ivar = var;
            }
            return YES;
        }
    }
    
    return NO;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSString *var;
    NSUInteger index;
    
    if ([self validateKey:key ivar:&var index:&index]) {
        size_t carr, esz;
        void *p, *r;
        char *et;
        
        if (instance_variable(self, [var UTF8String], &p, &carr, &esz, &et)) {
            if (index < carr) {
                r = (char *)p + index * esz;
                if (strcmp([(NSValue *)value objCType], et) == 0) {
                    [(NSValue *)value getValue:r];
                    free(et);
                    return;
                }
            }

            free(et);
        }
    }
    
    return [super setValue:value forUndefinedKey:key];
}

- (id)valueForUndefinedKey:(NSString *)key
{
    NSString *var;
    NSUInteger index;
    
    if ([self validateKey:key ivar:&var index:&index]) {
        size_t carr, esz;
        void *p, *r;
        char *et;
        
        if (instance_variable(self, [var UTF8String], &p, &carr, &esz, &et)) {
            if (index < carr) {
                r = (char *)p + index * esz;
                NSValue *value = [NSValue value:r withObjCType:et];
                free(et);
                return value;
            }

            free(et);
        }
    }
    
    return [super valueForUndefinedKey:key];
}

@end

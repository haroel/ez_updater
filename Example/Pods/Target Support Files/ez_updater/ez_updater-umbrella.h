#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "EZUpdater.h"

FOUNDATION_EXPORT double ez_updaterVersionNumber;
FOUNDATION_EXPORT const unsigned char ez_updaterVersionString[];


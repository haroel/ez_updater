//
//  EZUpdater.h
//  ez_updater
//
//  Created by howe on 2020/10/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
enum EZUpdater_STRATEGY{
    // compare local version and appstore version , check which is newer;
    // etc. 1.11.0 > 1.2.8;
    UPDATER_VERSION_DIFF = 0,
    
    // if local version is equal to appstore version, if not, show the tips;
    UPDATER_VERSION_EQUAL = 1,

};

@interface EZUpdater : NSObject

+ (EZUpdater*)Instance;


@property(nonatomic,copy ) NSString * bundleID;
/**
 * default : UPDATER_VERSION_DIFF
 */
@property enum EZUpdater_STRATEGY updateStrategy;

- (void) checkAppStoreVersion;

- (void) checkAppStoreInfoWithHandler: (void (^)(NSError* error,NSString *appstoreVersion, NSDictionary*appstoreInfo)) appstoreHandler ;


@end

NS_ASSUME_NONNULL_END

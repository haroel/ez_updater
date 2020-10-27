//
//  EZUpdater.m
//  ez_updater
//
//  Created by howe on 2020/10/27.
//

#import "EZUpdater.h"

static EZUpdater *_shareUpdater = nil;

@implementation EZUpdater

+(EZUpdater*)Instance{
    if (_shareUpdater == nil){
        _shareUpdater = [[EZUpdater alloc] init];
        [_shareUpdater initUpdater];
    }
    return _shareUpdater;
}

-(void) initUpdater{
    NSDictionary *infoPlistDict = [[NSBundle mainBundle] infoDictionary];
    self.bundleID = infoPlistDict[@"CFBundleIdentifier"];
    self.updateStrategy = UPDATER_VERSION_DIFF;
}

- (void)checkAppStoreVersion{
    [self checkAppStoreInfoWithHandler:^(NSError * error,NSString *appstoreVersion, NSDictionary * appInfo) {
        if (error){
            NSLog(@"-----[EZUpdater] 发生错误，无法检测版本！");
            return;
        }
        if (appInfo == nil){
            NSLog(@"-----[EZUpdater] appInfo == nil！");
            return;
        }
        NSDictionary *infoPlistDict = [[NSBundle mainBundle] infoDictionary];
        NSString *currentVersion = infoPlistDict[@"CFBundleShortVersionString"];
        NSString * title = @"New Version Available";
        if (self.updateStrategy == UPDATER_VERSION_DIFF){
            int compareRet = [self _compareLocalVersion:currentVersion andAppstoreVersion:appstoreVersion];
            switch (compareRet) {
                case 0:
                {
                    NSLog(@"-----[EZUpdater] 版本一致，不做处理");
                    break;
                }
                case 1:
                {
                    NSLog(@"-----[EZUpdater] 当前版本号较高，不需要做任何处理");
                    break;
                }
                default:
                {
                    [self _showUpdateAlert:title andAppStoreInfo:appInfo];
                    break;
                }
            }
        }else if (self.updateStrategy == UPDATER_VERSION_EQUAL) {
            if ( ![appstoreVersion isEqual:currentVersion] ){
                [self _showUpdateAlert:title andAppStoreInfo:appInfo];
            }
        }
    }];
}

- (void) checkAppStoreInfoWithHandler: (void (^)(NSError* error,NSString *appstoreVersion,NSDictionary*response)) handler{
    NSString *appstoreurl = [NSString stringWithFormat:@"https://itunes.apple.com/lookup?bundleId=%@",self.bundleID];
    NSURL *storeURL = [NSURL URLWithString:appstoreurl];
    [self _checkInfoFromAppstore:storeURL retry:3 andBlock:^(NSError *error, NSDictionary *response) {
        if (error){
            NSLog(@"-----[EZUpdater] 发生错误，无法检测版本！");
            handler(error,nil,nil);
            return;
        }
        NSLog(@"-----[EZUpdater] get response %@",response);
        NSDictionary *appInfo = nil;
        NSString * appstoreVersion = @"";
        NSInteger resultCount = [response[@"resultCount"] integerValue];
        if(resultCount>0){
            NSArray *resultArray = response[@"results"];
            appInfo = resultArray.firstObject;
            appstoreVersion = appInfo[@"version"];
        }else{
            NSLog(@"-----[EZUpdater] cannot found the appstoreinfo , please check the app bundleid! %@",self.bundleID);
        }
        handler(nil,appstoreVersion,appInfo);
    }];
}


-(void) _showUpdateAlert:(NSString*)title andAppStoreInfo:(NSDictionary*)appInfo{
    dispatch_block_t block =  ^{
        NSString * appstoreID = appInfo[@"trackId"];
        NSString *releaseNotes = appInfo[@"releaseNotes"];
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:title message:releaseNotes preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *closeAct = [UIAlertAction actionWithTitle:@"NotNow" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertController addAction:closeAct];
        
        UIAlertAction *updateAct = [UIAlertAction actionWithTitle:@"Update" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *storeURL = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@?mt=8",appstoreID];
            NSLog(@"-----[EZUpdater] openURL %@",storeURL);
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:storeURL] options:@{} completionHandler:nil];
            } else {
                // Fallback on earlier versions
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:storeURL]];
            }
        }];
        [alertController addAction:updateAct];
        UIWindow * window = [[UIApplication sharedApplication] keyWindow];
        [window.rootViewController presentViewController:alertController animated:YES completion:^{
        }];
    };
    if ([NSThread isMainThread]){
        block();
    }else{
        dispatch_sync(dispatch_get_main_queue(),block );
    }
}

/**
 * 0 :  currentVersion is Equal appstoreVersion;
 * 1:  currentVersion is bigger then appstoreVersion;
 * 2:  need update
 */
-(int) _compareLocalVersion:(NSString*)currentVersion andAppstoreVersion:(NSString*)appstoreVersion{
    if ([currentVersion isEqual:appstoreVersion]){
        return 0;
    }
    NSArray * arr1 = [currentVersion componentsSeparatedByString:@"."];
    NSArray * arr2 = [appstoreVersion componentsSeparatedByString:@"."];
    if (arr1.count != arr2.count){
        return 2;
    }
    for (int i=0; i<arr1.count; i++) {
        int localV = [arr1[i] intValue];
        int appV =[arr2[i] intValue];
        if (localV > appV){
            // 1.11.1 > 1.10.2
            return 1;
        }
        if (localV < appV){
            // 1.1.1 < 1.2.0
            return 2;
        }
    }
    return 0;
}

-(void) _checkInfoFromAppstore:(NSURL*)storeURL retry:(int)retry andBlock:(void (^)(NSError* error,NSDictionary*response)) appstoreHandler{
    
    NSURLRequest *storeRequest = [NSURLRequest requestWithURL:storeURL ];
    // Make a connection to the iTunes Store on a background queue.
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:storeRequest
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      // ...
                                      if (error) {
                                          if (retry > 0 ){
                                              [self _checkInfoFromAppstore:storeURL retry:(retry-1) andBlock:appstoreHandler];
                                              return;
                                          }
                                          /* ... Handle error ... */
                                          NSLog(@"-----[EZUpdater]  error = %@",error);
                                          appstoreHandler(error,nil);
                                      } else {
                                          NSString * str  =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                          NSLog(@"-----[EZUpdater]  response = %@",str);
                                          NSError *error;
                                          NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                          if (!jsonResponse) {
                                              /* ... Handle error ...*/
                                              NSLog(@"-----[EZUpdater] result parse error = %@",error);
                                              appstoreHandler(error,nil);
                                              return;
                                          }
                                          appstoreHandler(nil,jsonResponse);
                                      }
                                  }];
    
    [task resume];
}

@end

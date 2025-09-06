#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(HubspotModule, NSObject)

RCT_EXTERN_METHOD(initSDK:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(openChat:(NSString *)tag
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

// Match Swift: func identifyVisitor(_ identityToken: String, email: String?, resolver: ..., rejecter: ...)
RCT_EXTERN_METHOD(identifyVisitor:(NSString *)identityToken
                  email:(NSString *_Nullable)email
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
                  
RCT_EXTERN_METHOD(setChatProperties:(NSArray *)properties
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(endSession:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

@end
//
//  Collectables.h
//  ZDetection
//
//  Created by Scott Andrew on 10/22/21.
//  Copyright © 2021 Zimperium Inc. All rights reserved.
//

@interface Collectables: NSObject

@property (nonatomic, readonly) BOOL isCarrierInformation;
@property (nonatomic, readonly) BOOL isOperatingSystem;
@property (nonatomic, readonly) BOOL isModel;
@property (nonatomic, readonly) BOOL isIPAddress;
@property (nonatomic, readonly) BOOL isIMEI;
@property (nonatomic, readonly) BOOL isSSID;
@property (nonatomic, readonly) BOOL isBSSID;
@property (nonatomic, readonly) BOOL areSiteInsightURLs;
@property (nonatomic, readonly) BOOL isNetwork;
@property (nonatomic, readonly) BOOL isDevice;

-(id) initWithCollectables:(unsigned int)collectables;

@end

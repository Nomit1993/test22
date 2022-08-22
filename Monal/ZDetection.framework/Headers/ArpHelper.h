//
//  ArpHelper.h
//  zIPS
//
//  Created by Ryan Chazen on 2/14/14.
//  Copyright (c) 2014 Zimperium LTD All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArpHelper : NSObject

+ (NSString *)hostnamesForIPv4Address:(NSString *)address;

+ (NSString *)currentWifiSSID;


+ (NSString *)currentWifiBSSID;


+ (NSString *)currentIP;

+ (NSString *)currentSubnet;

+ (NSString *)currentMAC;


// Get Current IP Address
+ (NSString *)currentIPAddress;

// Get Current MAC Address
+ (NSString *)currentMACAddress;

// Get Cell IP Address
+ (NSString *)cellIPAddress;

// Get Cell MAC Address
+ (NSString *)cellMACAddress;

// Get Cell Netmask Address
+ (NSString *)cellNetmaskAddress;

// Get Cell Broadcast Address
+ (NSString *)cellBroadcastAddress;

// Get WiFi IP Address
+ (NSString *)wiFiIPAddress;

//Get BSSID/SSID/etc...
+ (NSDictionary* ) WifiNetworkInfo;

// Get WiFi MAC Address
+ (NSString *)wiFiMACAddress;

// Get WiFi Netmask Address
+ (NSString *)wiFiNetmaskAddress;

// Get WiFi Broadcast Address
+ (NSString *)wiFiBroadcastAddress;

// Connected to WiFi?
+ (BOOL)connectedToWiFi;

// Connected to Cellular Network?
+ (BOOL)connectedToCellNetwork;

// Connected wifi info. May not correct always. 
+ (NSDictionary*)connectedWifi;

@end



@interface NSNetworkSettings : NSObject
+ (NSNetworkSettings *)sharedNetworkSettings;
- (void)setProxyDictionary:(NSDictionary *)dictionary;
- (BOOL)connectedToInternet:(BOOL)unknown;
- (void)setProxyPropertiesForURL:(NSURL *)url onStream:(CFReadStreamRef)stream;
- (BOOL)isProxyNeededForURL:(NSURL *)url;
- (NSDictionary *)proxyPropertiesForURL:(NSURL *)url;
- (NSDictionary *)proxyDictionary;
- (void)_listenForProxySettingChanges;
- (void)_updateProxySettings;
@end



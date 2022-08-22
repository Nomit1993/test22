//
//  ZThreat.h
//  ZDetection
//
//  Created by Ryan Chazen on 2021/05/25.
//  Copyright © 2021 Zimperium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum {
    HIDDEN,
    LOW,
    IMPORTANT,
    CRITICAL
} ZThreatSeverity;

typedef enum {
    TCP_SCAN = 0,
    UDP_SCAN = 1,
    IP_SCAN = 2,
    ARP_SCAN = 3,
    ARP_MITM = 4,
    SYN_SCAN = 5,
    EMAIL_SUSPECTED = 6,
    FILE_SUSPECTED = 7,
    UNKNOWN = 8,
    MALICIOUS_WEBSITE = 9,
    ABNORMAL_PROCESS_ACTIVITY = 10,
    ICMP_REDIR_MITM = 11,
    RUNNING_AS_ROOT = 12,
    APK_SUSPECTED = 13,
    SSL_STRIP = 14,
    PROXY_CHANGE = 15,
    GATEWAY_CHANGE = 16,
    DNS_CHANGE = 17,
    TCP_SCAN6 = 18,
    UDP_SCAN6 = 19,
    IP_SCAN6 = 20,
    ACCESS_POINT_CHANGE = 21,
    SUSPICIOUS_SMS = 22,
    FILES_SYSTEM_CHANGED = 23,
    UNTRUSTED_PROFILE = 24,
    UNKNOWN_SOURCES_ON = 25,
    SUSPICIOUS_CELLULAR_TOWER_CHANGE = 26,
    TRAFFIC_TAMPERING = 27,
    BENEVOLENT_PENTESTING_APP = 28,
    SMS_CONFIG_CHANGED = 29,
    ROGUE_CELLULAR_TOWER_MITM = 30,
    DORMANT = 100,
    APPLICATION_CLOSED_BY_USER = 31,
    STAGEFRIGHT_ANOMALY = 32,
    MEDIASERVER_ANOMALY = 33,
    STAGEFRIGHT_EXPLOIT = 34,
    SSL_MITM = 35,
    NETWORK_HANDOFF = 36,
    SYSTEM_TAMPERING = 37,
    ROGUE_ACCESS_POINT = 38,
    DEVICE_ROOTED = 39,
    STAGEFRIGHT_VULNERABLE = 40,
    VULNERABILITY_MITIGATION = 41,
    SUSPICIOUS_IPA = 42,
    DAEMON_ANOMALY = 43,
    USB_DEBUGGING_ON = 44,
    SUSPICIOUS_PROFILE = 45,
    UNCLASSIFIED_CERTIFICATE = 46,
    DEVELOPER_OPTIONS_ON = 47,
    INTERNAL_NETWORK_ACCESS = 48,
    ENCRYPTION_NOT_ENABLED = 49,
    PASSCODE_NOT_ENABLED = 50,
    ANDROID_NOT_UPDATED = 51,
    IOS_NOT_UPDATED = 52,
    WINDOWS_NOT_UPDATED = 53,
    KERNEL_ANOMALY = 54,
    TEST_THREAT_ROGUE_SSL = 55,
    TEST_THREAT_ROGUE_NETWORK = 56,
    TEST_THREAT_DEVICE_COMPROMISED = 57,
    TEST_THREAT_MALICIOUS_APP = 58,
    DYNAMIC_LIBRARY_INJECTION = 59,
    COGITO_APK_DETECTION = 60,
    SELINUX_DISABLED = 61,
    SUSPICIOUS_ROOT_PROCESS = 62,
    SUSPICIOUS_NETWORK_CONNECTION = 63,
    FINGERPRINT_MISMATCH = 64,
    ROGUE_ACCESS_POINT_NEARBY = 65,
    UNSECURED_WIFI_NETWORK = 66,
    CAPTIVE_PORTAL = 67,
    TRACEROUTE_MITM = 68,
    BLUEBORNE_VULNERABLE = 69,
    ANDROID_COMPATIBILITY_TESTING = 70,
    ANDROID_BASIC_INTEGRITY = 71,
    MALICIOUS_WEBSITE_OPENED = 72,
    ACCESSED_BLOCKED_DOMAIN = 73,
    DEVICE_SERVICE_COMPROMISED = 74,
    APP_COMPROMISED = 75,
    SIDELOADED_APP = 76,
    TLS_DOWNGRADE = 77,
    ZIPS_NOT_RUNNING_ON_CONTAINER = 78,
    DANGERZONE_CONNECTED = 79,
    DANGERZONE_NEARBY = 80,
    DYNAMIC_CODE_LOADING = 81,
    SILENT_APP_INSTALLATION = 82,
    SUSPICIOUS_FILE = 83,
    GOOGLE_PLAY_PROTECT_DISABLED = 84,
    ANDROID_DEBUG_BRIDGE_APPS_NOT_VERIFIED = 85,
    OVER_THE_AIR_UPDATES_DISABLED = 86,
    ALWAYS_ON_VPN_APP_SET = 87,
    VULNERABLE_NON_UPGRADEABLE_IOS_VERSION = 88,
    VULNERABLE_NON_UPGRADEABLE_ANDROID_VERSION = 89,
    DYNAMIC_CODE_LOADING_NATIVE = 90,
    DYNAMIC_CODE_LOADING_JAVA = 91,
    FILE_TYPE_MISMATCH = 92,
    OUT_OF_COMPLIANCE_APP = 93,
    WIFI_SYNC_ENABLED = 94,
    ZTHREAT_END = 95    // IF we add more threat type, we need to increase this number.
} ZThreatType;

typedef enum
{
    IOS_AUDIO_VIDEO_AUDIO_RECORD=1001,
    IOS_AUDIO_VIDEO_CAMERA=1002,
    IOS_AUDIO_VIDEO_CAMERA_ROLL_READ=1003,
    IOS_AUDIO_VIDEO_CAMERA_ROLL_WRITE=1004,
    IOS_AUDIO_VIDEO_MIC=1005,
    IOS_AUDIO_VIDEO_SCREENSHOT=1006,
    IOS_AUDIO_VIDEO_VIDEO_RECORD=1007,
    IOS_CLOUD_SERVICES_AWS_S3=1008,
    IOS_CLOUD_SERVICES_AWS_S3_WRITE=1009,
    IOS_CLOUD_SERVICES_BOX_READ=1010,
    IOS_CLOUD_SERVICES_BOX_WRITE=1011,
    IOS_CLOUD_SERVICES_DROPBOX_READ=1012,
    IOS_CLOUD_SERVICES_DROPBOX_WRITE=1013,
    IOS_CLOUD_SERVICES_FB_READ=1014,
    IOS_CLOUD_SERVICES_FB_WRITE=1015,
    IOS_CLOUD_SERVICES_GOOGLE_STORAGE_READ=1016,
    IOS_CLOUD_SERVICES_GOOGLE_STORAGE_WRITE=1017,
    IOS_CLOUD_SERVICES_GOOGLE_DRIVE_READ=1018,
    IOS_CLOUD_SERVICES_GOOGLE_DRIVE_WRITE=1019,
    IOS_CLOUD_SERVICES_INSTAGRAM_READ=1020,
    IOS_CLOUD_SERVICES_LINKEDIN_READ=1021,
    IOS_CLOUD_SERVICES_OFFICE365_WRITE=1022,
    IOS_CLOUD_SERVICES_ONEDRIVE_READ=1023,
    IOS_CLOUD_SERVICES_ONEDRIVE_WRITE=1024,
    IOS_CLOUD_SERVICES_SALESFORCE_READ=1025,
    IOS_CLOUD_SERVICES_TWITTER_READ=1026,
    IOS_CLOUD_SERVICES_TWITTER_WRITE=1027,
    IOS_CLOUD_SERVICES_WEIBO_READ=1028,
    IOS_CLOUD_SERVICES_WEIBO_WRITE=1029,
    IOS_COMMUNICATIONS_EMAIL_READ=1030,
    IOS_COMMUNICATIONS_EMAIL_SEND=1031,
    IOS_COMMUNICATIONS_EMAIL_WRITE=1032,
    IOS_COMMUNICATIONS_SMS_READ=1033,
    IOS_COMMUNICATIONS_SMS_SEND=1034,
    IOS_COMMUNICATIONS_SMS_WRITE=1035,
    IOS_COMMUNICATIONS_VOIP=1036,
    IOS_COMMUNICATIONS_VPN=1037,
    IOS_LOCATION_ACCESS=1038,
    IOS_LOCATION_FINE=1039,
    IOS_PRIVACY_CALL_HISTORY=1040,
    IOS_PRIVACY_CLIPBOARD_READ=1041,
    IOS_PRIVACY_CLIPBOARD_WRITE=1042,
    IOS_PRIVACY_ENDPOINTS_REPUTATION=1043,
    IOS_PRIVACY_ENDPOINTS_SENSITIVE_DATA=1044,
    IOS_PRIVACY_IMEI=1045,
    IOS_PRIVACY_LOCAL_DEVICE_WRITE=1046,
    IOS_PRIVACY_OVERLAY=1047,
    IOS_PRIVACY_SERIAL=1048,
    IOS_PRIVACY_UDID=1049,
    IOS_SECURITY_EXTERNAL_SERVERS=1050,
    IOS_SECURITY_INTERNAL_IPS=1051,
    IOS_SECURITY_MALWARE=1052,
    IOS_SECURITY_PRIVATE_FRAMEWORKS=1053,
    IOS_SECURITY_SSL_PROBLEM=1054,
    IOS_SECURITY_SSL_SELF_SIGNED=1055,
    IOS_SECURITY_SSL_VULN_WEAKNESS=1056,
    IOS_SECURITY_UNENCRYPTED=1057,
    IOS_PRIVACY_USER_INTERACT = 1058,
    IOS_RISKY_APP = 1059,
    IOS_CVE_VULNERABILITY_PRIVACY = 1060,
    IOS_CVE_VULNERABILITY_SECURITY = 1061,
    IOS_EXPOSED_PARAMETER = 1062,
    IOS_FACEBOOK_SDK = 1063,
    IOS_FILESYSTEM_PROTECTION = 1064,
    IOS_GLOBALAD_IDENTIFIER = 1065,
    IOS_HEALTH_DATA = 1066,
    IOS_KEYBOARD_EXTENSION = 1067,
    IOS_LOGGING = 1068,
    IOS_PROXY_CAPABILITY = 1069,
    IOS_REMOTE_UPDATE = 1070,
    IOS_SEND_DATA_OFF_DEVICE = 1071,
    IOS_SWIZZLING = 1072,
    IOS_ADVERTISER_ADMOB=1073,
    IOS_ADVERTISER_GREYSTRIPE=1074,
    IOS_ADVERTISER_IAD=1075,
    IOS_ADVERTISER_MOBCLIX=1076,
    IOS_CLOUD_SERVICES_EVERNOTE=1077,
    IOS_CLOUD_SERVICES_FLURRY=1078,
    IOS_CLOUD_SERVICES_ICLOUD=1079,
    IOS_CLOUD_SERVICES_SUGARSYNC=1080,
    IOS_CLOUD_SERVICES_VULNERABLE_AZURE=1081,
    IOS_CLOUD_SERVICES_VULNERABLE_ELASTICSEARCH=1082,
    IOS_CLOUD_SERVICES_VULNERABLE_FIREBASE=1083,
    IOS_CRASH_REPORTING_BUGSENSE=1084,
    IOS_CRASH_REPORTING_CRASHLYTICS=1085,
    IOS_CRASH_REPORTING_CRITTERISM=1086,
    IOS_PRIVACY_GLASSBOX=1087,
    IOS_PRIVACY_MOBISAGE_SDK=1088,
    IOS_PRIVACY_YOUMI_SDK=1089,
    IOS_SECURITY_HARD_CODED_CREDENTIALS=1090,
    IOS_SECURITY_JSPATCH=1091,
    IOS_ADVERTISER_APPERIAN=1092,
    IOS_ADVERTISER_APPSEE=1093,
    IOS_ADVERTISER_KAKOA=1094,
    IOS_CLOUD_SERVICES_GOOGLE_FIREBASE=1095,
    IOS_COMMUNICATION_BLUETOOTH_SHARING=1096,
    IOS_COMMUNICATION_BONJOUR_SERVICE=1097,
    IOS_COMMUNICATION_LOCAL_IP_ADDRESS=1098,
    IOS_COMMUNICATION_NOT_COMPILED_PIE=1099,
    IOS_COMMUNICATION_SSL_PINNING=1100,
    IOS_COMMUNICATION_WIFI_INFO=1101,
    IOS_PRIVACY_ACCESS_ADDRESSBOOK=1102,
    IOS_PRIVACY_ACCESS_CALENDAR=1103,
    IOS_PRIVACY_GOOGLE_CONSENT=1104,
    IOS_PRIVACY_TELEPHONY_SERVICE=1105,
    IOS_PRIVACY_TESTFAIRY_SDK=1106,
    IOS_PRIVACY_TWILO_API=1107,
    IOS_PRIVACY_UBER_API=1108,
    IOS_PRIVACY_USES_DATABASE=1109,
    IOS_SECURITY_AZURE_CREDENTIALS=1110,
    IOS_SECURITY_COMMON_CRYPTO_LIBRARY=1111,
    IOS_SECURITY_DEVICE_JAILBREAKROOT=1112,
    IOS_SECURITY_GET_TASK_ALLOW=1113,
    IOS_SECURITY_KEYBOARD_EXTENSION=1114,
    IOS_SECURITY_KEYCHAIN=1115,
    IOS_SECURITY_KEYCHAIN_ACCESS_GROUPS=1116,
    IOS_SECURITY_MONO_TOUCH=1117,
    IOS_SECURITY_PHONEGAP=1118,
    IOS_SECURITY_PRIVATE_ENTITLEMENTS=1119,
    IOS_SECURITY_SIGNAL_SDK=1120,
    IOS_CLOUD_SERVICES_VULNERABLE_AWS=1121,
    IOS_CLOUD_SERVICES_VULNERABLE_GOOGLE=1122,
    IOS_SERVER_LOCATION_AE=1123,
    IOS_SERVER_LOCATION_AF=1124,
    IOS_SERVER_LOCATION_AG=1125,
    IOS_SERVER_LOCATION_AM=1126,
    IOS_SERVER_LOCATION_AR=1127,
    IOS_SERVER_LOCATION_AT=1128,
    IOS_SERVER_LOCATION_AU=1129,
    IOS_SERVER_LOCATION_AX=1130,
    IOS_SERVER_LOCATION_AZ=1131,
    IOS_SERVER_LOCATION_BA=1132,
    IOS_SERVER_LOCATION_BD=1133,
    IOS_SERVER_LOCATION_BE=1134,
    IOS_SERVER_LOCATION_BG=1135,
    IOS_SERVER_LOCATION_BI=1136,
    IOS_SERVER_LOCATION_BN=1137,
    IOS_SERVER_LOCATION_BO=1138,
    IOS_SERVER_LOCATION_BR=1139,
    IOS_SERVER_LOCATION_BS=1140,
    IOS_SERVER_LOCATION_BT=1141,
    IOS_SERVER_LOCATION_BY=1142,
    IOS_SERVER_LOCATION_CA=1143,
    IOS_SERVER_LOCATION_CD=1144,
    IOS_SERVER_LOCATION_CH=1145,
    IOS_SERVER_LOCATION_CI=1146,
    IOS_SERVER_LOCATION_CL=1147,
    IOS_SERVER_LOCATION_CN=1148,
    IOS_SERVER_LOCATION_CO=1149,
    IOS_SERVER_LOCATION_CR=1150,
    IOS_SERVER_LOCATION_CW=1151,
    IOS_SERVER_LOCATION_CY=1152,
    IOS_SERVER_LOCATION_CZ=1153,
    IOS_SERVER_LOCATION_DE=1154,
    IOS_SERVER_LOCATION_DK=1155,
    IOS_SERVER_LOCATION_DO=1156,
    IOS_SERVER_LOCATION_DZ=1157,
    IOS_SERVER_LOCATION_EC=1158,
    IOS_SERVER_LOCATION_EE=1159,
    IOS_SERVER_LOCATION_EG=1160,
    IOS_SERVER_LOCATION_ES=1161,
    IOS_SERVER_LOCATION_FI=1162,
    IOS_SERVER_LOCATION_FJ=1163,
    IOS_SERVER_LOCATION_FO=1164,
    IOS_SERVER_LOCATION_FR=1165,
    IOS_SERVER_LOCATION_GB=1166,
    IOS_SERVER_LOCATION_GE=1167,
    IOS_SERVER_LOCATION_GG=1168,
    IOS_SERVER_LOCATION_GH=1169,
    IOS_SERVER_LOCATION_GL=1170,
    IOS_SERVER_LOCATION_GR=1171,
    IOS_SERVER_LOCATION_GT=1172,
    IOS_SERVER_LOCATION_GU=1173,
    IOS_SERVER_LOCATION_HK=1174,
    IOS_SERVER_LOCATION_HR=1175,
    IOS_SERVER_LOCATION_HU=1176,
    IOS_SERVER_LOCATION_ID=1177,
    IOS_SERVER_LOCATION_IE=1178,
    IOS_SERVER_LOCATION_IL=1179,
    IOS_SERVER_LOCATION_IM=1180,
    IOS_SERVER_LOCATION_IN=1181,
    IOS_SERVER_LOCATION_IR=1182,
    IOS_SERVER_LOCATION_IS=1183,
    IOS_SERVER_LOCATION_IT=1184,
    IOS_SERVER_LOCATION_JO=1185,
    IOS_SERVER_LOCATION_JP=1186,
    IOS_SERVER_LOCATION_KE=1187,
    IOS_SERVER_LOCATION_KG=1188,
    IOS_SERVER_LOCATION_KH=1189,
    IOS_SERVER_LOCATION_KM=1190,
    IOS_SERVER_LOCATION_KR=1191,
    IOS_SERVER_LOCATION_KW=1192,
    IOS_SERVER_LOCATION_KY=1193,
    IOS_SERVER_LOCATION_KZ=1194,
    IOS_SERVER_LOCATION_LC=1195,
    IOS_SERVER_LOCATION_LK=1196,
    IOS_SERVER_LOCATION_LT=1197,
    IOS_SERVER_LOCATION_LU=1198,
    IOS_SERVER_LOCATION_LV=1199,
    IOS_SERVER_LOCATION_LY=1200,
    IOS_SERVER_LOCATION_MA=1201,
    IOS_SERVER_LOCATION_MC=1202,
    IOS_SERVER_LOCATION_MG=1203,
    IOS_SERVER_LOCATION_MK=1204,
    IOS_SERVER_LOCATION_MN=1205,
    IOS_SERVER_LOCATION_MO=1206,
    IOS_SERVER_LOCATION_MP=1207,
    IOS_SERVER_LOCATION_MT=1208,
    IOS_SERVER_LOCATION_MW=1209,
    IOS_SERVER_LOCATION_MX=1210,
    IOS_SERVER_LOCATION_MY=1211,
    IOS_SERVER_LOCATION_MZ=1212,
    IOS_SERVER_LOCATION_NA=1213,
    IOS_SERVER_LOCATION_NC=1214,
    IOS_SERVER_LOCATION_NG=1215,
    IOS_SERVER_LOCATION_NI=1216,
    IOS_SERVER_LOCATION_NL=1217,
    IOS_SERVER_LOCATION_NO=1218,
    IOS_SERVER_LOCATION_NP=1219,
    IOS_SERVER_LOCATION_NR=1220,
    IOS_SERVER_LOCATION_NZ=1221,
    IOS_SERVER_LOCATION_PA=1222,
    IOS_SERVER_LOCATION_PE=1223,
    IOS_SERVER_LOCATION_PH=1224,
    IOS_SERVER_LOCATION_PK=1225,
    IOS_SERVER_LOCATION_PL=1226,
    IOS_SERVER_LOCATION_PS=1227,
    IOS_SERVER_LOCATION_PT=1228,
    IOS_SERVER_LOCATION_PY=1229,
    IOS_SERVER_LOCATION_QA=1230,
    IOS_SERVER_LOCATION_RO=1231,
    IOS_SERVER_LOCATION_RS=1232,
    IOS_SERVER_LOCATION_RU=1233,
    IOS_SERVER_LOCATION_RW=1234,
    IOS_SERVER_LOCATION_SA=1235,
    IOS_SERVER_LOCATION_SE=1236,
    IOS_SERVER_LOCATION_SG=1237,
    IOS_SERVER_LOCATION_SI=1238,
    IOS_SERVER_LOCATION_SK=1239,
    IOS_SERVER_LOCATION_SM=1240,
    IOS_SERVER_LOCATION_SZ=1241,
    IOS_SERVER_LOCATION_TH=1242,
    IOS_SERVER_LOCATION_TJ=1243,
    IOS_SERVER_LOCATION_TN=1244,
    IOS_SERVER_LOCATION_TR=1245,
    IOS_SERVER_LOCATION_TW=1246,
    IOS_SERVER_LOCATION_TZ=1247,
    IOS_SERVER_LOCATION_UA=1248,
    IOS_SERVER_LOCATION_US=1249,
    IOS_SERVER_LOCATION_UY=1250,
    IOS_SERVER_LOCATION_UZ=1251,
    IOS_SERVER_LOCATION_VE=1252,
    IOS_SERVER_LOCATION_VG=1253,
    IOS_SERVER_LOCATION_VN=1254,
    IOS_SERVER_LOCATION_VU=1255,
    IOS_SERVER_LOCATION_WS=1256,
    IOS_SERVER_LOCATION_YE=1257,
    IOS_SERVER_LOCATION_ZA=1258,
    IOS_SERVER_LOCATION_ZW=1259,
    IOS_ADVERTISER_ANY=1260,
    IOS_ADVERTISER_MALICIOUS_SOURMINT=1261,
    IOS_APP_STORE_ACTION=1262,
    IOS_APP_STORE_ADVENTURE=1263,
    IOS_APP_STORE_ARCADE=1264,
    IOS_APP_STORE_ARTS_PHOTOGRAPHY=1265,
    IOS_APP_STORE_AUTOMOTIVE=1266,
    IOS_APP_STORE_BOARD=1267,
    IOS_APP_STORE_BOOK=1268,
    IOS_APP_STORE_BRIDES_WEDDINGS=1269,
    IOS_APP_STORE_BUSINESS=1270,
    IOS_APP_STORE_BUSINESS_INVESTING=1271,
    IOS_APP_STORE_CARD=1272,
    IOS_APP_STORE_CASINO=1273,
    IOS_APP_STORE_CATALOGS=1274,
    IOS_APP_STORE_CHILDRENS_MAGAZINES=1275,
    IOS_APP_STORE_COMPUTER_INTERNET=1276,
    IOS_APP_STORE_CRAFTS_HOBBIES=1277,
    IOS_APP_STORE_DEVELOPER_TOOLS=1278,
    IOS_APP_STORE_DICE=1279,
    IOS_APP_STORE_EDUCATION=1280,
    IOS_APP_STORE_EDUCATIONAL=1281,
    IOS_APP_STORE_ELECTRONICS_AUDIO=1282,
    IOS_APP_STORE_ENTERTAINMENT_APP=1283,
    IOS_APP_STORE_ENTERTAINMENT_MAGAZINE=1284,
    IOS_APP_STORE_FAMILY=1285,
    IOS_APP_STORE_FASHION_STYLE=1286,
    IOS_APP_STORE_FINANCE=1287,
    IOS_APP_STORE_FOOD_DRINK=1288,
    IOS_APP_STORE_GRAPHICS_DESIGN=1289,
    IOS_APP_STORE_HEALTH_FITNESS=1290,
    IOS_APP_STORE_HEALTH_MIND_BODY=1291,
    IOS_APP_STORE_HISTORY=1292,
    IOS_APP_STORE_HOME_GARDEN=1293,
    IOS_APP_STORE_LIFESTYLE=1294,
    IOS_APP_STORE_LITERAY_MAGAINZES_JOURNALS=1295,
    IOS_APP_STORE_MEDICAL=1296,
    IOS_APP_STORE_MENS_INTEREST=1297,
    IOS_APP_STORE_MOVIES_MUSIC=1298,
    IOS_APP_STORE_MUSIC_APP=1299,
    IOS_APP_STORE_MUSIC_GAME=1300,
    IOS_APP_STORE_NAVIGATION=1301,
    IOS_APP_STORE_NEWS=1302,
    IOS_APP_STORE_NEWS_POLITICS=1303,
    IOS_APP_STORE_OUTDOOR_NATURE=1304,
    IOS_APP_STORE_PARENTING_FAMILY=1305,
    IOS_APP_STORE_PETS=1306,
    IOS_APP_STORE_PHOTO_VIDEO=1307,
    IOS_APP_STORE_PRODUCTIVITY=1308,
    IOS_APP_STORE_PROFESSIONAL_TRADE=1309,
    IOS_APP_STORE_PUZZLE=1310,
    IOS_APP_STORE_RACING=1311,
    IOS_APP_STORE_REFERENCE=1312,
    IOS_APP_STORE_REGIONAL_NEWS=1313,
    IOS_APP_STORE_ROLE_PLAYING=1314,
    IOS_APP_STORE_SCIENCE=1315,
    IOS_APP_STORE_SHOPPING=1316,
    IOS_APP_STORE_SIMLUATION=1317,
    IOS_APP_STORE_SOCIAL_NETWORKING=1318,
    IOS_APP_STORE_SPORTS_APP=1319,
    IOS_APP_STORE_SPORTS_GAME=1320,
    IOS_APP_STORE_SPORTS_LEISURE=1321,
    IOS_APP_STORE_STICKERS=1322,
    IOS_APP_STORE_STRATEDGY=1323,
    IOS_APP_STORE_TEENS=1324,
    IOS_APP_STORE_TRAVEL=1325,
    IOS_APP_STORE_TRAVEL_REGIONAL=1326,
    IOS_APP_STORE_TRIVIA=1327,
    IOS_APP_STORE_UTILITIES=1328,
    IOS_APP_STORE_WEATHER=1329,
    IOS_APP_STORE_WOMENS_INTEREST=1330,
    IOS_APP_STORE_WORD=1331,
    IOS_PROVISIONING_PROFILE_APN_CELLTOWER=1332,
    IOS_PROVISIONING_PROFILE_APN_INTERNET=1333,
    IOS_PROVISIONING_PROFILE_CARDAV=1334,
    IOS_PROVISIONING_PROFILE_EMAIL=1335,
    IOS_PROVISIONING_PROFILE_ENTERPRISE_DOMAINS=1336,
    IOS_PROVISIONING_PROFILE_ETHERNET=1337,
    IOS_PROVISIONING_PROFILE_EXCHANGE=1338,
    IOS_PROVISIONING_PROFILE_IDENTIFY_PREFERENCE=1339,
    IOS_PROVISIONING_PROFILE_LDAP=1340,
    IOS_PROVISIONING_PROFILE_MANAGED=1341,
    IOS_PROVISIONING_PROFILE_MDM=1342,
    IOS_PROVISIONING_PROFILE_PASSWORD_POLICY=1343,
    IOS_PROVISIONING_PROFILE_PASSWORD_REMOVAL=1344,
    IOS_PROVISIONING_PROFILE_PROXY=1345,
    IOS_PROVISIONING_PROFILE_RESTRICTIONS=1346,
    IOS_PROVISIONING_PROFILE_SCEP=1347,
    IOS_PROVISIONING_PROFILE_SINGLE_SIGNON=1348,
    IOS_PROVISIONING_PROFILE_TRUSTED_CERTIFICATE=1349,
    IOS_PROVISIONING_PROFILE_VPN=1350,
    IOS_PROVISIONING_PROFILE_VPN_SOFTWARE=1351,
    IOS_PROVISIONING_PROFILE_WEBCLIP=1352,
    IOS_PROVISIONING_PROFILE_WIFI=1353,
} zOutOfComplianceCharacteristics;

typedef enum {
    UNSUPPORTED = 0,
    UNKNOWN_CATEGORY,
    DEVICE,
    NETWORK,
    APPLICATION
} ZThreatCategory;

NS_ASSUME_NONNULL_BEGIN

@interface ZThreatMeta : NSObject

- (NSString *) uuid;
- (BOOL) mitigated;
- (int) legacyThreatId;
- (NSString *) internalName;
- (NSString *) triggerValue;
- (NSTimeInterval) threatTime;
- (BOOL) needToSend;
- (BOOL) needToSendMitigation;

- (void) sendThreatToServer;

/**
 ZThreatCategory associated with the threat.
 */
- (ZThreatCategory) getThreatCategory;

@end

typedef BOOL (^ZThreatResultsFilter)(ZThreatMeta* meta);

@interface ZThreatResultsController : NSObject

- (instancetype)initWithFilter:(ZThreatResultsFilter) filter;
- (instancetype)initWithFilter:(ZThreatResultsFilter) filter Comparator:(NSComparator)comparator;
- (NSArray<ZThreatMeta*>*) listThreatMeta;
- (void) recalc;

+ (NSComparator) MitigatedGroupingComparator;

@end

@interface ZThreat : NSObject

+ (NSArray<ZThreatMeta*>*) listThreatMeta;
+ (ZThreat*) getThreatDetails:(NSString *) uuid;
+ (Boolean) threatExists:(NSString *)internalName legacyThreatId:(int) legacyThreatId uuid:(NSString*)uuid trigger:(NSString *)triggerValue;

- (NSTimeInterval) threatTime;
- (int32_t) threatInternalId;
- (NSDictionary*) threatData;
- (NSString*) threatUUID;
- (BOOL) isAcknowledged;
- (BOOL) isSimulated;

- (void) mitigateThreat;
- (void) unmitigateThreat;
- (void) deleteThreat;
- (BOOL) mitigateOnAcknowledge;
+ (ZThreatSeverity) getDevicePosture;

/**
 Internal system threat name string (example, “ARP_MITM”, “SSL_STRIP”, “TCP_SCAN”, etc). Matches Android threatType.name() call.
 */
+ (NSString *) nameForThreatType:(ZThreatType)typ;

/**
 Severity of the threat reported (“CRITICAL”, “IMPORTANT”, “LOW”)
 */
- (ZThreatSeverity) threatSeverity;

// As per API

/**
 Internal system threat name string (example, “ARP_MITM”, “SSL_STRIP”, “TCP_SCAN”, etc). Matches Android threatType.name() call.
 */
- (NSString *) name;

/**
 Human readable and translated name of the threat reported (example, “ARP MITM”, “SSL STRIP”, “TCP SCAN”, etc)
 */
- (NSString *) humanThreatName;

/**
 Human readable name in English of the threat reported (example, “ARP MITM”, “SSL STRIP”, “TCP SCAN”, etc)
 */
- (NSString *) rawHumanThreatName;

/**
 ZThreatType associated with the threat.
 */
- (ZThreatType) getThreatType;

/**
 Human readable and translated type of the threat reported
 */
- (NSString *) humanThreatType;

/**
 Severity of the threat reported (“CRITICAL”, “IMPORTANT”, “LOW”)
 */
- (NSString *) severity;

/**
 Human friendly configurable description of the attack
 */
- (NSAttributedString *) humanThreatSummary;

/**
 SSID of the access point when the attack was detected. Only present when the device was connected to a wifi network.
 */
- (NSString *) SSID;

/**
 The malware name of the the detected threat. Only applies to malware threats.
 */
- (NSString *) malwareName;

/**
 The os Version at the time of the the detected threat.
 */
- (NSString *) osVersion;

/**
 Get the user configured alert string. The alert string can be configured in zConsole.
 
 @return return localzied alert string.
 */
- (NSAttributedString *) alertText;


/**
 Return boolean variable indicating whether an alert can be shown.
 This needs to be configured in zConsole.
 
 @return return true when it is visible.
 */
- (BOOL)isAlertVisible;

/**
 Return context aware string from a string with replace-able template. The string template is surrounded with []
 and the following strings are available for the template.
 [wifi_ssid], [date], [ip], [app_name], [host_app_name], [profile_name], [os_version],[blocked_domain],
 [sideloaded_developer], [nearby_ssids]
 
 @return formatted string.
 */
- (NSString*)formattedString:(NSString*)orig;

/**
 Represent whether the threat is for out of app compliance or not
 
 @return true if the threat is for out of compliance app.
 */
- (BOOL) isAppOutOfCompliance;

/**
 Return the policy names for the out of compliance app.
 
 @return array of NSString contains policy names.
 */
- (NSArray*) getOocPolicyNames;

/**
 Return the out of compliance characteristics.
 The characteristics is arry of NSNumber which should be zOutOfComplianceCharacteristics type.
 
 @param name policy name
 @return array of characteristics for the policy.
 */
- (NSArray*) getOocPolicyCharacteristics:(NSString*)name;

/**
 Human readable and translated Out of Compliance App characteristic name.
 @param characteristicID ooc app characteristic ID
 @return string ooc app characteristic name.
 */
- (NSString *) getHumanOOCCharacteristicNameFrom: (zOutOfComplianceCharacteristics) characteristicID;

/**
 Helper method to retrieve Out of Compliance App characteristic localization key.
 @param characteristicID ooc app characteristic ID
 @return string ooc app characteristic localization key.
 */
- (NSString *) getOOCCharacteristicLocalizationKeyFrom: (zOutOfComplianceCharacteristics) characteristicID;

/**
 ZThreatCategory associated with the threat.
 */
- (ZThreatCategory) getThreatCategory;

@end

@interface ZThreatMeta ()

- (ZThreat *) threatDetails;

@end

NS_ASSUME_NONNULL_END

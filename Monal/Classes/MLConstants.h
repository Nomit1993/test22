//
//  MLConstants.h
//  Monal
//
//  Created by Anurodh Pokharel on 7/13/13.
//
//

#import <Foundation/Foundation.h>
#import <TargetConditionals.h>
#import "MLHandler.h"

@import CocoaLumberjack;
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
#import "MLLogFileManager.h"
#import "MLLogFormatter.h"


//configure app group constants
#define kAppGroup @"group.in.signals.SAI-Secure"
#define kMonalKeychainName @"SAI-Secure"

//this is in seconds
//#if TARGET_OS_MACCATALYST
//	#define SHORT_PING 16.0
//	#define LONG_PING 32.0
//#else
//	#define SHORT_PING 4.0
//	#define LONG_PING 16.0
//#endif

#if TARGET_OS_MACCATALYST
    #define SHORT_PING 16.0
    #define LONG_PING 32.0
    #define MUC_PING 600
    #define BGFETCH_DEFAULT_INTERVAL 3600*1
#else
    #define SHORT_PING 4.0
    #define LONG_PING 16.0
    #define MUC_PING 3600
    #define BGFETCH_DEFAULT_INTERVAL 3600*3
#endif

@class MLContact;

//some typedefs used throughout the project
typedef void (^contactCompletion)(MLContact *selectedContact);
typedef void (^contactTabCompletion)(MLContact *selectedTabContact);
typedef void (^accountCompletion)(NSInteger accountRow);
typedef void (^monal_void_block_t)(void);
typedef void (^monal_id_block_t)(id);

typedef enum NotificationPrivacySettingOption {
    DisplayNameAndMessage,
    DisplayOnlyName,
    DisplayOnlyPlaceholder
} NotificationPrivacySettingOption;


//some useful macros
#define weakify(var) __weak __typeof__(var) AHKWeak_##var = var
#define strongify(var) _Pragma("clang diagnostic push") _Pragma("clang diagnostic ignored \"-Wshadow\"") __strong __typeof__(var) var = AHKWeak_##var; _Pragma("clang diagnostic pop")
#define nilWrapper(var) (var ? var : [NSNull null])
#define nilExtractor(var) (var == [NSNull null] ? nil : var)

#if defined(IS_ALPHA) || defined(DEBUG)
    #define unreachable() { \
        DDLogWarn(@"unreachable: %s %d %s", __FILE__, __LINE__, __func__); \
        NSAssert(NO, @"unreachable"); \
    }
#else
    #define unreachable() { \
        DDLogWarn(@"unreachable: %s %d %s", __FILE__, __LINE__, __func__); \
    }
#endif

// https://clang-analyzer.llvm.org/faq.html#unlocalized_string
__attribute__((annotate("returns_localized_nsstring")))
static inline NSString* LocalizationNotNeeded(NSString* s)
{
  return s;
}

//some xmpp related constants
#define kRegServer @"chat.securesignal.in"
#define kMessageDeletedBody @"in.securesignal.secure.service.message_deleted"

#define kXMLNS @"xmlns"
#define kId @"id"
#define kJid @"jid"
#define kMessageId @"kMessageId"

#define kRegisterNameSpace @"jabber:iq:register"
#define kDataNameSpace @"jabber:x:data"

//all other constants needed
#define kMonalWillBeFreezed @"kMonalWillBeFreezed"
#define kMonalNewMessageNotice @"kMLNewMessageNotice"
#define kMonalMucSubjectChanged @"kMonalMucSubjectChanged"
#define kMonalDeletedMessageNotice @"kMonalDeletedMessageNotice"
#define kMonalDisplayedMessagesNotice @"kMonalDisplayedMessagesNotice"
#define kMonalHistoryMessagesNotice @"kMonalHistoryMessagesNotice"
#define kMLMessageSentToContact @"kMLMessageSentToContact"
#define kMonalSentMessageNotice @"kMLSentMessageNotice"
#define kMonalMessageFiletransferUpdateNotice @"kMonalMessageFiletransferUpdateNotice"

#define kMonalLastInteractionUpdatedNotice @"kMonalLastInteractionUpdatedNotice"
#define kMonalMessageReceivedNotice @"kMonalMessageReceivedNotice"
#define kMonalMessageDisplayedNotice @"kMonalMessageDisplayedNotice"
#define kMonalMessageErrorNotice @"kMonalMessageErrorNotice"
#define kMonalReceivedMucInviteNotice @"kMonalReceivedMucInviteNotice"
#define kXMPPError @"kXMPPError"
#define kgroupMessageWarning @"kgroupMessageWarning"
#define kScheduleBackgroundFetchingTask @"kScheduleBackgroundFetchingTask"
#define kMonalUpdateUnread @"kMonalUpdateUnread"
#define kMonalrefreshTabController @"kMonalrefreshTabController"
#define kMonalchatSearch @"kMonalchatSearch"
#define kMLHasConnectedNotice @"kMLHasConnectedNotice"
#define kMLMessageHaskeyrefresh @"kMLMessageHaskeyrefresh"
#define kMonalFinishedCatchup @"kMonalFinishedCatchup"
#define kMonalFinishedOmemoBundleFetch @"kMonalFinishedOmemoBundleFetch"
#define kMonalUpdateBundleFetchStatus @"kMonalUpdateBundleFetchStatus"
#define kMonalIdle @"kMonalIdle"
#define kMonalFiletransfersIdle @"kMonalFiletransfersIdle"

#define kMonalBackgroundChanged @"kMonalBackgroundChanged"

#define kMonalPresentChat @"kMonalPresentChat"

#define kMLMAMPref @"kMLMAMPref"


#define kMonalCallStartedNotice @"kMonalCallStartedNotice"
#define kMonalCallRequestNotice @"kMonalCallRequestNotice"

#define kMonalAccountStatusChanged @"kMonalAccountStatusChanged"
#define kMonalAccountAuthRequest @"kMonalAccountAuthRequest"
#define kMonalrefreshLogin @"kMonalrefreshLogin"
#define kMonalRefresh @"kMonalRefresh"
#define kMonalContactRefresh @"kMonalContactRefresh"
#define kMonalXmppUserSoftWareVersionRefresh @"kMonalXmppUserSoftWareVersionRefresh"
#define kMonalBlockListRefresh @"kMonalBlockListRefresh"
#define kMonalContactRemoved @"kMonalContactRemoved"


#define kMonalUpdateMessageNotice @"kMonalUpdateMessageNotice"
#define kMonalStoreMessageNotice @"kMonalStoreMessageNotice"

// max count of char's in a single message (both: sending and receiving)
#define kMonalChatMaxAllowedTextLen 2048

#if TARGET_OS_MACCATALYST
#define kMonalBackscrollingMsgCount 75
#else
#define kMonalBackscrollingMsgCount 50
#endif

//contact cells
#define kusernameKey @"username"
#define kfullNameKey @"fullName"
#define kaccountNoKey @"accountNo"
#define kstateKey @"state"
#define kstatusKey @"status"

//info cells
#define kaccountNameKey @"accountName"
#define kinfoTypeKey @"type"
#define kinfoStatusKey @"status"

//blocking rules
#define kBlockingNoMatch 0
#define kBlockingMatchedNodeHostResource 1
#define kBlockingMatchedNodeHost 2
#define kBlockingMatchedHostResource 3
#define kBlockingMatchedHost 4

//use this to completely disable omemo in build
//#ifndef DISABLE_OMEMO
//#define DISABLE_OMEMO 1
//#endif

//build MLXMLNode query statistics (will only optimize MLXMLNode queries if *not* defined)
//#define QueryStatistics 1

#define geoPattern  @"^geo:(-?(?:90|[1-8][0-9]|[0-9])(?:\\.[0-9]{1,32})?),(-?(?:180|1[0-7][0-9]|[0-9]{1,2})(?:\\.[0-9]{1,32})?)$"

//UTI @"public.data" for everything
#define mimeType_images @"public.image"
#define mimeType_gifFiles @"com.compuserve.gif"
#define mimeType_txtFiles @"public.text"
#define mimeType_xmlFiles @"public.xml"
#define mimeType_sourceCodeFiles @"public.source-code"
#define mimeType_pdfFiles @"com.adobe.pdf"
#define mimeType_rtfFiles @"public.rtf"
#define mimeType_xlsFiles @"com.microsoft.excel.xls"
#define mimeType_pptFiles @"com.microsoft.powerpoint.ppt"
#define mimeType_docFiles @"com.microsoft.word.doc"
#define mimeType_keyNoteFiles @"com.apple.keynote.key"
#define mimeType_presentationFiles @"public.presentation"
#define mimeType_videoFiles @"public.video"
#define mimeType_mp4Files @"public.mpeg-4"
#define mimeType_aviFiles @"public.avi"
#define mimeType_rmFiles @"com.real.realmedia"
#define mimeType_movFiles @"com.apple.quicktime-movie"
#define mimeType_zipFiles @"com.pkware.zip-archive"
#define mimeType_gzipFiles @"org.gnu.gnu-zip-archive"
#define mimeType_tarFiles @"public.tar-archive"
#define mimeType_audioFiles @"public.audio"
#define mimeType_mp3Files @"public.mp3"
#define mimeType_mp4aFiles @"public.mpeg-4-audio"
#define mimeType_wavFiles @"com.microsoft.waveform-audio"

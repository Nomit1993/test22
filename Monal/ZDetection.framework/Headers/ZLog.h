#ifndef ZLOG_H_INCLUDED
#define ZLOG_H_INCLUDED

#include <stdio.h>
#include <stdarg.h>

#ifdef __ANDROID_API__

#include <android/log.h>

#endif

#ifdef __APPLE__
#include <TargetConditionals.h>
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#ifdef __cplusplus
extern "C" {
#endif
    void zlogios(const char *message, ...);
#ifdef __cplusplus
}
#endif
#endif
#endif

#define ZLOG_OFF 0
#define ZLOG_ERROR 2
#define ZLOG_WARN 3
#define ZLOG_INFO 4
#define ZLOG_DEBUG 5
#define ZLOG_ALL 9

#include "ZLogConfig.h"

// Generic Log
#define ZLog(level, tag, ...) ::zlog::zlog(level, tag, [&](std::ostream &zostream) { zostream << "[+] " << tag << " : " << __VA_ARGS__ << std::endl; });
#define ZLogF(level, tag, ...) zlog_f_c(level, tag, __VA_ARGS__);

// Dynamic detection log
#if ZLOGLEVEL_COMPILE >= ZLOG_DEBUG
#define ZDDLog(...) ({ ZLog(ZLOG_DEBUG, "ZDD", __VA_ARGS__); })
#define ZDDLogF(...) ({ ZLogF(ZLOG_DEBUG, "ZDD", __VA_ARGS__); })
#else
#define ZDDLog(...) ({})
#define ZDDLogF(...) ({})
#endif

// ZWall logs
#if ZLOGLEVEL_COMPILE >= ZLOG_DEBUG && ZLOG_ZWALL_DEBUG > 0
#define ZF_LOGD(...) ({ ZLogF(ZLOG_DEBUG, "ZWALL", __VA_ARGS__); })
#else
#define ZF_LOGD(...) ({})
#endif

#if ZLOGLEVEL_COMPILE >= ZLOG_INFO && ZLOG_ZWALL_DEBUG > 0
#define ZF_LOGI(...) ({ ZLogF(ZLOG_INFO, "ZWALL", __VA_ARGS__); })
#else
#define ZF_LOGI(...) ({})
#endif

#if ZLOGLEVEL_COMPILE >= ZLOG_WARN
#define ZF_LOGW(...) ({ ZLogF(ZLOG_WARN, "ZWALL", __VA_ARGS__); })
#else
#define ZF_LOGW(...) ({})
#endif

#if ZLOGLEVEL_COMPILE >= ZLOG_ERROR
#define ZF_LOGE(...) ({ ZLogF(ZLOG_ERROR, "ZWALL", __VA_ARGS__); })
#else
#define ZF_LOGE(...) ({})
#endif

// NSLog
#if ZLOGLEVEL_COMPILE > ZLOG_DEBUG
//#define NSLog(message, ...) ({ zlog_f_c(ZLOG_DEBUG, "OBJC", message.UTF8String, ##__VA_ARGS__); })
#else
#define NSLog(message, ...) ({})
#endif

#ifdef __cplusplus
extern "C" {
#endif
    void zlog_f_c(int level, const char *tag, const char *format, ...);
#ifdef __cplusplus
}
#endif

#ifdef __cplusplus

#include <functional>
#include <string>
#include <sstream>

namespace zlog {
    
    void zlog(int level, const char *tag, std::function<void(std::ostream &)> p);

}
#endif // __cplusplus

#endif // ZLOG_H_INCLUDED

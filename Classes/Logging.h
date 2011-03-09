/*
 *  Logging.h
 *  GamesOnDemandClient
 *
 *  Created by Pedro Gomes on 1/25/11.
 *  Copyright 2011 SAPO. All rights reserved.
 *
 */

// Logging facility

#ifdef DEBUG
#	define DLog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
#else
#	define DLog(...) /* */
#endif

#define ALog(...) NSLog(__VA_ARGS__)

#define LOG_LEVEL_TRACE 0
#define LOG_LEVEL_INFO	1
#define LOG_LEVEL_WARN	2
#define LOG_LEVEL_ERROR	3
#define LOG_LEVEL_FATAL	4

#ifdef DEBUGLOG
#define LOG(LEVEL, ...)	NSLog(@"%s: %s %@", #LEVEL, __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
#else
#define LOG(LEVEL, ...) /* */
#endif

#if LOG_LEVEL_TRACE >= LOG_LEVEL && LOG_LEVEL <= LOG_LEVEL_FATAL
#define TRACE(...) LOG(TRACE, __VA_ARGS__)
#else
#define TRACE(...) /* */
#endif

#if LOG_LEVEL_INFO >= LOG_LEVEL && LOG_LEVEL <= LOG_LEVEL_FATAL
#define INFO(...) LOG(INFO, __VA_ARGS__)
#else
#define INFO(...) /* */
#endif

#if LOG_LEVEL_WARN >= LOG_LEVEL && LOG_LEVEL <= LOG_LEVEL_FATAL
#define WARN(...) LOG(WARN, __VA_ARGS__)
#else
#define WARN(...) /* */
#endif

#if LOG_LEVEL_ERROR >= LOG_LEVEL && LOG_LEVEL <= LOG_LEVEL_FATAL
#define ERROR(...) LOG(ERROR, __VA_ARGS__)
#else
#define ERROR(...) /* */
#endif

#if LOG_LEVEL == LOG_LEVEL_FATAL
#define FATAL(...) LOG(FATAL, __VA_ARGS__)
#else
#define FATAL(...) /* */
#endif

#define LOGRECT(rect) TRACE(@"%@", NSStringFromRect(rect))
#define LOGPOINT(point) TRACE(@"%@", NSStringFromPoint(point))
#define LOGBOOL(_bool_) TRACE(@"%s: %d",  #_bool_, _bool_)

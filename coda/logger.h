#ifndef __CODA_LOGGER_H__
#define __CODA_LOGGER_H__

#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif

#include <pthread.h>
#include "gmtime.h"
#include "system.h"

#ifdef __cplusplus
extern "C" {
#endif

#define LOG_access  0  /* ACC: special level for access log      */
#define LOG_emerg   1  /* EME: system is unusable                */
#define LOG_alert   2  /* ALE: action must be taken immediately  */
#define LOG_crit    3  /* CRI: critical conditions               */
#define LOG_error   4  /* ERR: error conditions                  */
#define LOG_warn    5  /* WRN: warning conditions                */
#define LOG_notice  6  /* NOT: normal, but significant condition */
#define LOG_info    7  /* NFO: informational message             */
#define LOG_debug   8  /* DBG: debug message                     */

#define log_msg(lev,fmt,...) log_fmt(stderr,LOG_##lev,#lev,fmt,##__VA_ARGS__)
#define log_err(err,fmt,...) log_msg(error,fmt " (%d: %s)\n", ##__VA_ARGS__, err, coda_strerror(err))
#define log_ret(err,fmt,...) log_msg(error,fmt " (%d: %s)\n", ##__VA_ARGS__, err, coda_strerror(err)), err
#define log_die(err,fmt,...) log_msg(emerg,fmt " (%d: %s)\n", ##__VA_ARGS__, err, coda_strerror(err)); exit(EXIT_FAILURE)

#define msg(fmt,...)     fprintf(stderr, fmt          "\n", ##__VA_ARGS__)
#define err(err,fmt,...) fprintf(stderr, fmt " (%d: %s)\n", ##__VA_ARGS__, err, coda_strerror(err))
#define ret(err,fmt,...) fprintf(stderr, fmt " (%d: %s)\n", ##__VA_ARGS__, err, coda_strerror(err)), err
#define die(err,fmt,...) fprintf(stderr, fmt " (%d: %s)\n", ##__VA_ARGS__, err, coda_strerror(err)); exit(EXIT_FAILURE)

#define log_access( fmt,...) log_msg(access,fmt,##__VA_ARGS__)
#define log_emerg(  fmt,...) log_msg(emerg, fmt,##__VA_ARGS__)
#define log_alert(  fmt,...) log_msg(alert, fmt,##__VA_ARGS__)
#define log_crit(   fmt,...) log_msg(crit,  fmt,##__VA_ARGS__)
#define log_error(  fmt,...) log_msg(error, fmt,##__VA_ARGS__)
#define log_warn(   fmt,...) log_msg(warn,  fmt,##__VA_ARGS__)
#define log_notice( fmt,...) log_msg(notice,fmt,##__VA_ARGS__)
#define log_info(   fmt,...) log_msg(info,  fmt,##__VA_ARGS__)
#ifndef NDEBUG
#define log_debug(  fmt,...) log_msg(debug, fmt,##__VA_ARGS__)
#else
#define log_debug(  fmt,...) /* nothing here */
#endif /* NDEBUG */

#define LOG_FORMAT(lvstr,tname,fmt) "%04u-%02u-%02u %02u:%02u:%02u " lvstr " " tname " " fmt "\n"
#define LOG_VALUES(tmloc,tname,...) tmloc.tm_year + 1900, tmloc.tm_mon + 1, tmloc.tm_mday, \
    tmloc.tm_hour, tmloc.tm_min, tmloc.tm_sec, tname, ##__VA_ARGS__

#define log_fmt(f,level,lvstr,fmt,...) do {                                 \
                                                                            \
    if (level <= log_level)                                                 \
    {                                                                       \
        struct tm tmloc;                                                    \
        time_t ts = time(NULL);                                             \
        const char* tname;                                                  \
                                                                            \
        localtime_r(&ts, &tmloc);                                           \
                                                                            \
        if (NULL != (tname = log_thread_name_get()))                        \
        {                                                                   \
            fprintf(f, LOG_FORMAT(lvstr,"%s",fmt),                          \
                       LOG_VALUES(tmloc,tname,##__VA_ARGS__));              \
        }                                                                   \
        else                                                                \
        {                                                                   \
            fprintf(f, LOG_FORMAT(lvstr,"%lu",fmt),                         \
                       LOG_VALUES(tmloc,(unsigned long)pthread_self(),##__VA_ARGS__));     \
        }                                                                   \
    }                                                                       \
                                                                            \
} while (0)

extern volatile int log_level;
int log_levels(const char* level);
int log_create(const char* path, int level);
int log_thread_name_set(const char* name);
const char* log_thread_name_get();

#define log_create_from_str(path, level) log_create(path, log_levels(level))
#define log_rotate(path)                 log_create(path, log_level)

#ifdef __cplusplus
}
#endif

#endif /* __CODA_LOGGER_H__ */

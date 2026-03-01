/* termux-compat.h - Compatibility header for native builds on Termux/Android */

#ifndef TERMUX_COMPAT_H
#define TERMUX_COMPAT_H

/* Android/Bionic compatibility definitions */

/* Missing or different function declarations */
#ifndef __ANDROID__
#define __ANDROID__ 1
#endif

/* Bionic doesn't have some GNU extensions */
#ifdef __BIONIC__

/* Missing ifaddrs.h definitions */
#ifndef IFF_UP
#define IFF_UP          0x1
#define IFF_BROADCAST   0x2
#define IFF_DEBUG       0x4
#define IFF_LOOPBACK    0x8
#define IFF_POINTOPOINT 0x10
#define IFF_NOTRAILERS  0x20
#define IFF_RUNNING     0x40
#define IFF_NOARP       0x80
#define IFF_PROMISC     0x100
#define IFF_ALLMULTI    0x200
#define IFF_MASTER      0x400
#define IFF_SLAVE       0x800
#define IFF_MULTICAST   0x1000
#endif

/* Timer compatibility */
#ifndef TIMER_ABSTIME
#define TIMER_ABSTIME   0x01
#endif

/* Missing RTLD_* flags */
#ifndef RTLD_LOCAL
#define RTLD_LOCAL      0
#endif

#ifndef RTLD_NOLOAD
#define RTLD_NOLOAD     0x4
#endif

#endif /* __BIONIC__ */

/* Common workarounds for native module builds */

/* Suppress common warnings */
#pragma GCC diagnostic ignored "-Wimplicit-function-declaration"
#pragma GCC diagnostic ignored "-Wunused-but-set-variable"
#pragma GCC diagnostic ignored "-Wmaybe-uninitialized"

/* Provide missing prototypes */
#ifdef __cplusplus
extern "C" {
#endif

/* These may be missing on older NDK headers */
#ifndef __has_include
#define __has_include(x) 0
#endif

#ifdef __cplusplus
}
#endif

#endif /* TERMUX_COMPAT_H */

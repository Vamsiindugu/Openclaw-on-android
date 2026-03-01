/* spawn.h - Minimal stub for Termux/Android
 * 
 * Bionic (Android's libc) doesn't have posix_spawn functions.
 * This stub provides minimal definitions to satisfy compile-time checks.
 * Actual functionality may be limited.
 */

#ifndef _SPAWN_H
#define _SPAWN_H 1

#include <sys/types.h>
#include <signal.h>

/* spawn attributes */
typedef struct {
    int flags;
    sigset_t sigmask;
    sigset_t sigdefault;
    int pgrp;
} posix_spawnattr_t;

/* spawn file actions */
typedef struct {
    int actions_allocated;
    int actions_used;
    void *actions;
} posix_spawn_file_actions_t;

/* spawn flags */
#ifndef POSIX_SPAWN_RESETIDS
#define POSIX_SPAWN_RESETIDS      0x01
#endif
#ifndef POSIX_SPAWN_SETPGROUP
#define POSIX_SPAWN_SETPGROUP     0x02
#endif
#ifndef POSIX_SPAWN_SETSIGDEF
#define POSIX_SPAWN_SETSIGDEF     0x04
#endif
#ifndef POSIX_SPAWN_SETSIGMASK
#define POSIX_SPAWN_SETSIGMASK    0x08
#endif
#ifndef POSIX_SPAWN_SETSCHEDPARAM
#define POSIX_SPAWN_SETSCHEDPARAM 0x10
#endif
#ifndef POSIX_SPAWN_SETSCHEDULER
#define POSIX_SPAWN_SETSCHEDULER  0x20
#endif

/* Stub implementations - these will fail at runtime if called */
#ifdef __cplusplus
extern "C" {
#endif

static inline int posix_spawnattr_init(posix_spawnattr_t *attr) {
    (void)attr;
    return 0;
}

static inline int posix_spawnattr_destroy(posix_spawnattr_t *attr) {
    (void)attr;
    return 0;
}

static inline int posix_spawnattr_setflags(posix_spawnattr_t *attr, int flags) {
    (void)attr; (void)flags;
    return 0;
}

static inline int posix_spawn_file_actions_init(posix_spawn_file_actions_t *actions) {
    (void)actions;
    return 0;
}

static inline int posix_spawn_file_actions_destroy(posix_spawn_file_actions_t *actions) {
    (void)actions;
    return 0;
}

static inline int posix_spawn(pid_t *pid, const char *path,
                              const posix_spawn_file_actions_t *actions,
                              const posix_spawnattr_t *attr,
                              char *const argv[], char *const envp[]) {
    (void)pid; (void)path; (void)actions; (void)attr; (void)argv; (void)envp;
    return -1; /* Not implemented */
}

static inline int posix_spawnp(pid_t *pid, const char *file,
                               const posix_spawn_file_actions_t *actions,
                               const posix_spawnattr_t *attr,
                               char *const argv[], char *const envp[]) {
    (void)pid; (void)file; (void)actions; (void)attr; (void)argv; (void)envp;
    return -1; /* Not implemented */
}

#ifdef __cplusplus
}
#endif

#endif /* _SPAWN_H */

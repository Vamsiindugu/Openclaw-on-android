// bionic-compat.js - Bionic libc compatibility for Node.js on Android/Termux
// This patch addresses common issues when running Node.js native modules on Android

'use strict';

// Patch process.binding for bionic compatibility
if (process.binding) {
    const originalBinding = process.binding;
    process.binding = function patchedBinding(module) {
        try {
            return originalBinding.call(this, module);
        } catch (err) {
            // Handle common bionic-specific errors
            if (err.code === 'MODULE_NOT_FOUND') {
                // Return empty object for missing native modules
                console.warn(`[bionic-compat] Native module '${module}' not available, using fallback`);
                return {};
            }
            throw err;
        }
    };
}

// Patch fs.realpath for Android's /data/data paths
const fs = require('fs');
const originalRealpath = fs.realpath;
fs.realpath = function patchedRealpath(path, options, callback) {
    if (typeof options === 'function') {
        callback = options;
        options = null;
    }
    
    // Handle common Android paths
    if (path && typeof path === 'string') {
        // Normalize /data/data paths
        path = path.replace(/\/data\/data\/([^\/]+)\//, '/data/data/$1/');
    }
    
    return originalRealpath.call(this, path, options, callback);
};

console.log('[bionic-compat] Compatibility patches loaded');

#!/usr/bin/env node
const whatsUpdated = (original, updated) => {
    if (original === updated) {
        return undefined
    } else if (!original) { 
        return updated
    } else if (!updated) {
        return null
    } else if (typeof original === 'object' && !Array.isArray(original)) {
        const changes = {};
        [...Object.keys(original), ...Object.keys(updated)].forEach((key) => {
            const theChanges = whatsUpdated(original[key], updated[key])
            if (theChanges !== undefined) {
                changes[key] = theChanges
            }
        })
        return changes;
    } else if (Array.isArray(original)) {
        if (original.length != updated.length) {
            return updated
        } else {
            for (var i = 0; i < original.length; i++) {
                if (original[i] != updated[i]) {
                    return updated;
                }
            }
            return undefined;
        }
    } else {
        return updated;
    }
}

const args = process.argv
const original = JSON.parse(args[2])
const updated = JSON.parse(args[3])
console.log(JSON.stringify(whatsUpdated(original, updated)));

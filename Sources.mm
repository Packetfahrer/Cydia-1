/* Cydia - iPhone UIKit Front-End for Debian APT
 * Copyright (C) 2008-2013  Jay Freeman (saurik)
*/

/* GNU General Public License, Version 3 {{{ */
/*
 * Cydia is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published
 * by the Free Software Foundation, either version 3 of the License,
 * or (at your option) any later version.
 *
 * Cydia is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Cydia.  If not, see <http://www.gnu.org/licenses/>.
**/
/* }}} */

#include "CyteKit/UCPlatform.h"

#include <Foundation/Foundation.h>
#include <Menes/ObjectHandle.h>

#include <cstdio>

#include "Sources.h"

extern _H<NSMutableDictionary> Sources_;

void CydiaWriteSources() {
    unlink(SOURCES_LIST);
    FILE *file(fopen(SOURCES_LIST, "w"));
    _assert(file != NULL);

    if (kCFCoreFoundationVersionNumber >= 1556) {
        fprintf(file, "deb https://electrarepo64.coolstar.org/ ./\n");
        fprintf(file, "deb https://diatr.us/chicydia/ ./\n");
    } else {
        fprintf(file, "deb https://electrarepo64.coolstar.org/ ./\n");
        fprintf(file, "deb https://diatr.us/chicydia/ ./\n");
    }

    for (NSString *key in [Sources_ allKeys]) {
        if ([key hasPrefix:@"deb:http:"] && [Sources_ objectForKey:[NSString stringWithFormat:@"deb:https:%s", [key UTF8String] + 9]])
            continue;

        NSDictionary *source([Sources_ objectForKey:key]);
        // Ignore it if main source is added again
        if ([[source objectForKey:@"URI"] hasPrefix:@"http://diatr.us/chicydia/"] || [[source objectForKey:@"URI"] hasPrefix:@"https://diatr.us/chicydia/"])
            continue;
        
        // Ignore it if main source is added again
        if ([[source objectForKey:@"URI"] hasPrefix:@"http://electrarepo64.coolstar.org/"] || [[source objectForKey:@"URI"] hasPrefix:@"https://electrarepo64.coolstar.org/"])
        continue;
        
        // Ignore it if main source is added again
        //if ([[source objectForKey:@"URI"] hasPrefix:@"http://repo.chimera.sh/"] || [[source //objectForKey:@"URI"] hasPrefix:@"https://repo.chimera.sh/"])
        //continue;
        
        // Don't add Bingner sources
        if ([[source objectForKey:@"URI"] rangeOfString:@"bingner" options:NSCaseInsensitiveSearch].location != NSNotFound || [[source objectForKey:@"URI"] rangeOfString:@"chimera" options:NSCaseInsensitiveSearch].location != NSNotFound)
            continue;

        NSArray *sections([source objectForKey:@"Sections"] ?: [NSArray array]);

        fprintf(file, "%s %s %s%s%s\n",
            [[source objectForKey:@"Type"] UTF8String],
            [[source objectForKey:@"URI"] UTF8String],
            [[source objectForKey:@"Distribution"] UTF8String],
            [sections count] == 0 ? "" : " ",
            [[sections componentsJoinedByString:@" "] UTF8String]
        );
    }

    fclose(file);
}

void CydiaAddSource(NSDictionary *source) {
    // Ignore it if main source is added again
    if ([[source objectForKey:@"URI"] hasPrefix:@"http://diatr.us/chicydia/"] || [[source objectForKey:@"URI"] hasPrefix:@"https://diatr.us/chicydia/"])
        return;
    
    // Ignore it if main source is added again
    if ([[source objectForKey:@"URI"] hasPrefix:@"http://electrarepo64.coolstar.org/"] || [[source objectForKey:@"URI"] hasPrefix:@"https://electrarepo64.coolstar.org/"])
    return;
    
    // Ignore it if main source is added again
    //if ([[source objectForKey:@"URI"] hasPrefix:@"http://repo.chimera.sh/"] || [[source objectForKey:@"URI"] hasPrefix:@"https://repo.chimera.sh/"])
    //return;
    
    // Don't add Bingner sources
    if ([[source objectForKey:@"URI"] rangeOfString:@"bingner" options:NSCaseInsensitiveSearch].location != NSNotFound || [[source objectForKey:@"URI"] rangeOfString:@"chimera" options:NSCaseInsensitiveSearch].location != NSNotFound)
        return;

    [Sources_ setObject:source forKey:[NSString stringWithFormat:@"%@:%@:%@", [source objectForKey:@"Type"], [source objectForKey:@"URI"], [source objectForKey:@"Distribution"]]];
}

void CydiaAddSource(NSString *href, NSString *distribution, NSArray *sections) {
    if (href == nil || distribution == nil)
        return;

    CydiaAddSource([NSMutableDictionary dictionaryWithObjectsAndKeys:
        @"deb", @"Type",
        href, @"URI",
        distribution, @"Distribution",
        sections ?: [NSMutableArray array], @"Sections",
    nil]);
}

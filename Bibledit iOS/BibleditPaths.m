/*
 Copyright (©) 2003-2017 Teus Benschop.
 
 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */


#import "BibleditPaths.h"

@implementation BibleditPaths


+ (NSString *)resources
{
    NSString * path = [[NSBundle mainBundle] resourcePath];
    NSArray *components = [NSArray arrayWithObjects:path, @"webroot", nil];
    path = [NSString pathWithComponents:components];
    return path;
}


+ (NSString *)documents
{
    NSString * path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSArray *components = [NSArray arrayWithObjects:path, @"webroot", nil];
    path = [NSString pathWithComponents:components];
    return path;
}


@end

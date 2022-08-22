//
//  ModelHelper.h
//  ZDetection
//
//  Created by Ryan Chazen on 3/18/16.
//  Copyright © 2016 Zimperium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface ZModelHelper : NSObject

+ (void) setup;

+ (NSManagedObjectContext *_Nonnull) backgroundMOC;
+ (NSManagedObjectContext *_Nonnull) foregroundMOC;

+ (void) saveContext:(NSManagedObjectContext *_Nonnull) context;
+ (void) saveContext:(NSManagedObjectContext *_Nonnull) context andRunBlock:(void (^_Nonnull)(void))block;

+ (void) migrateToZThreatDB;

@end

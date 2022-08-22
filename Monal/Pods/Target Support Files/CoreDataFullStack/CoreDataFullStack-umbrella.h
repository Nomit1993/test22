#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "CoreDataFullStack.h"
#import "CDFCollectionViewFetchedResultsController.h"
#import "CDFTableViewFetchedResultsController.h"
#import "CDFCoreDataManager.h"
#import "CDFCountService.h"
#import "CDFDeletionService.h"
#import "CDFInsertService.h"
#import "CDFRetrievalService.h"

FOUNDATION_EXPORT double CoreDataFullStackVersionNumber;
FOUNDATION_EXPORT const unsigned char CoreDataFullStackVersionString[];


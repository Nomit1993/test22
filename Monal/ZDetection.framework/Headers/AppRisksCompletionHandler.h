//
//  AppRisksCompletionHandler.h
//  ZDetection
//
//  Created by Pawel Kijowski on 1/23/20.
//  Copyright © 2020 Zimperium Inc. All rights reserved.
//

#ifndef AppRisksCompletionHandler_h
#define AppRisksCompletionHandler_h

@class AppRisk;

typedef void(^AppRisksRequestCompletionHandler)(NSArray<AppRisk*> * _Nonnull appRisks, NSError * _Nullable error);

#endif /* AppRisksCompletionHandler_h */

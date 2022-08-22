//
//  XMPPDataForm.h
//  monalxmpp
//
//  Created by tmolitor on 12.10.20.
//  Copyright © 2020 Monal.im. All rights reserved.
//

#ifndef XMPPDataForm_h
#define XMPPDataForm_h

#import <Foundation/Foundation.h>
#import "MLXMLNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface XMPPDataForm : MLXMLNode

-(id) initWithType:(NSString*) type andFormType:(NSString*) formType;
-(id) initWithType:(NSString*) type formType:(NSString*) formType andDictionary:(NSDictionary*) vars;

@property (atomic, strong) NSString* type;
@property (atomic, strong) NSString* formType;
-(void) setFieldWithDictionary:(NSDictionary*) field;
-(void) setField:(NSString*) name withValue:(NSString*) value;
-(void) setField:(NSString*) name withType:(NSString* _Nullable) type andValue:(NSString*) value;
-(NSDictionary* _Nullable) getField:(NSString*) name;
-(void) removeField:(NSString*) name;

//NSMutableDictionary interface (not complete, but nearly complete)
@property(readonly) NSUInteger count;
@property(readonly, copy) NSArray* allKeys;
@property(readonly, copy) NSArray* allValues;
-(id _Nullable) objectForKeyedSubscript:(NSString*) key;
-(void) setObject:(id _Nullable) obj forKeyedSubscript:(NSString*) key;
-(NSArray*) allKeys;
-(NSArray*) allValues;
-(NSArray*) allKeysForObject:(id) anObject;
-(id) valueForKey:(NSString*) key;
-(id) objectForKey:(NSString*) key;
-(void) removeObjectForKey:(NSString*) key;
-(void) removeAllObjects;
-(void) removeObjectsForKeys:(NSArray*) keyArray;
-(void) setObject:(NSString*) value forKey:(NSString*) key;
-(void) setValue:(NSString* _Nullable) value forKey:(NSString*) key;
-(void) addEntriesFromDictionary:(NSDictionary*) vars;
-(void) setDictionary:(NSDictionary*) vars;

@end

NS_ASSUME_NONNULL_END

#endif /* XMPPDataForm_h */

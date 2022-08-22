//
//  MLMucProcessor.h
//  monalxmpp
//
//  Created by Thilo Molitor on 29.12.20.
//  Copyright © 2020 Monal.im. All rights reserved.
//

#import "MLConstants.h"

NS_ASSUME_NONNULL_BEGIN

@class XMPPPresence;
@class XMPPMessage;
@class xmpp;

@interface MLMucProcessor : NSObject
+(void)fetchmamMessages:(NSString *)room onAccount:(xmpp*) account;
+(void) addUIHandler:(monal_id_block_t) handler forMuc:(NSString*) room;
+(void) removeUIHandlerForMuc:(NSString*) room;
+(void) fetchMembersList:(NSString *)room onAccount:(xmpp*) account;
+(void) processPresence:(XMPPPresence*) presenceNode forAccount:(xmpp*) account;
+(BOOL) processMessage:(XMPPMessage*) messageNode forAccount:(xmpp*) account;
@property (nonatomic, strong) contactCompletion selectContact;
+(void) setAffiliation:(NSString*) jid room:(NSString*)roomJid type:(NSString *)type onAccount:(xmpp*) account;
+(void) grantRole:(NSString*) jid room:(NSString*)roomJid onAccount:(xmpp*) account;
+(void) grantMembership:(NSString*) jid room:(NSString*)roomJid onAccount:(xmpp*) account;
+(void) inviteUser:(NSString*) jid room:(NSString*)roomJid onAccount:(xmpp*) account;
+(void) create:(NSString *)room onAccount:(xmpp*) account subject:(NSString *)roomName completion:(void (^)(BOOL success))completion;
+(void) changeMucSubject:(NSString *)subjectName room:(NSString *)roomJid onAccount:(xmpp*) account;
+(void) moderatorMsgSubscriberoom:(NSString *)roomJid onAccount:(xmpp *)account;
+(void) checkSubscriberoom:(NSString *)roomJid onAccount:(xmpp *)account completion:(void (^)(BOOL success))finishBlock;
+(void) moderatorSubscriberoom:(NSString *)roomJid onAccount:(xmpp *)account;
+(void) mucSubscribeUser:(NSString *) jid room:(NSString *)roomJid onAccount:(xmpp *)account;
+(void) sendDefaultRoomConfiguration:(NSString*) room onAccount:(xmpp*) account subjcet:(NSString *)GroupSubject completion:(void (^)(BOOL success))finishBlock;
+(void) sendJoinPresenceFor:(NSString*) room onAccount:(xmpp*) account;
+(void) sendDiscoQueryFor:(NSString*) roomJid onAccount:(xmpp*) account withJoin:(BOOL) join andBookmarksUpdate:(BOOL) updateBookmarks;
+(void) join:(NSString*) room onAccount:(xmpp*) account;
+(void) leave:(NSString*) room onAccount:(xmpp*) account withBookmarksUpdate:(BOOL) updateBookmarks;
+(void) pingAllMucsOnAccount:(xmpp*) account;
+(void) ping:(NSString*) roomJid onAccount:(xmpp*) account;

@end

NS_ASSUME_NONNULL_END

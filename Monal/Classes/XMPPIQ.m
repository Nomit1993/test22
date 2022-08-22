//
//  XMPPIQ.m
//  Monal
//
//  Created by Anurodh Pokharel on 6/30/13.
//
//

#import "XMPPIQ.h"
#import "XMPPDataForm.h"
#import "HelperTools.h"
#import "SignalPreKey.h"

NSString* const kiqGetType = @"get";
NSString* const kiqSetType = @"set";
NSString* const kiqResultType = @"result";
NSString* const kiqErrorType = @"error";

@implementation XMPPIQ

-(id) initInternalWithId:(NSString*) iqid andType:(NSString*) iqType
{
    self = [super initWithElement:@"iq"];
    [self setXMLNS:@"c5b9cdd82abcf6305f9c24fa5b7715e15dfe36fa810852494dad0297fd9dc866:client"];
    self.id = iqid;
    if(iqType)
        self.attributes[@"type"] = iqType;
    return self;
}

-(id) initWithType:(NSString*) iqType
{
    return [self initInternalWithId:[[NSUUID UUID] UUIDString] andType:iqType];
}

-(id) initWithType:(NSString*) iqType to:(NSString*) to
{
    self = [self initWithType:iqType];
    if(to)
        [self setiqTo:to];
    return self;
}

-(id) initAsResponseTo:(XMPPIQ*) iq
{
    self = [self initInternalWithId:[iq findFirst:@"/@id"] andType:kiqResultType];
    if(iq.from)
        [self setiqTo:iq.from];
    return self;
}

#pragma mark iq set

-(void) setRegisterOnAppserverWithToken:(NSString*) token
{
    //http://jabber.org/protocol/pubsub#publish-options
    [self addChild:[[MLXMLNode alloc] initWithElement:@"command" andNamespace:@"http://jabber.org/protocol/commands" withAttributes:@{
        @"node": @"v1-register-push",
        @"action": @"execute"
    } andChildren:@[
        [[XMPPDataForm alloc] initWithType:@"submit" formType:@"https://github.com/tmolitor-stud-tu/mod_push_appserver/#v1-register-push" andDictionary:@{
            @"type": @"apns",
            @"node": [[[UIDevice currentDevice] identifierForVendor] UUIDString],
            @"token": token
        }]
    ] andData:nil]];
}

-(void) setPushEnableWithNode:(NSString*) node andSecret:(NSString*) secret onAppserver:(NSString*) jid
{
    [self addChild:[[MLXMLNode alloc] initWithElement:@"enable" andNamespace:@"in:secure:signal:push:0" withAttributes:@{
        @"jid": jid,
        @"node": node
    } andChildren:@[
        [[XMPPDataForm alloc] initWithType:@"submit" formType:@"http://jabber.org/protocol/pubsub#publish-options" andDictionary:@{
            @"secret": secret
        }]
    ] andData:nil]];
}

-(void) setPushDisable
{
    [self addChild:[[MLXMLNode alloc] initWithElement:@"disable" andNamespace:@"in:secure:signal:push:0" withAttributes:@{
        @"jid": [HelperTools pushServer][@"jid"],
        @"node": [[[UIDevice currentDevice] identifierForVendor] UUIDString]
    } andChildren:@[] andData:nil]];
}

-(void) setBindWithResource:(NSString*) resource
{
    MLXMLNode* bindNode =[[MLXMLNode alloc] initWithElement:@"bind" andNamespace:@"in:secure:signal:xml:ns:xmpp-bind"];
    MLXMLNode* resourceNode = [[MLXMLNode alloc] initWithElement:@"resource"];
    resourceNode.data = resource;
    [bindNode addChild:resourceNode];
    [self addChild:bindNode];
}

-(void) setMucListQueryFor:(NSString*) listType
{
    [self addChild:[[MLXMLNode alloc] initWithElement:@"query" andNamespace:@"http://jabber.org/protocol/muc#admin" withAttributes:@{} andChildren:@[
        [[MLXMLNode alloc] initWithElement:@"item" withAttributes:@{@"affiliation": listType} andChildren:@[] andData:nil]
    ] andData:nil]];
}

-(void) setDiscoInfoNode
{
    MLXMLNode* queryNode =[[MLXMLNode alloc] initWithElement:@"query" andNamespace:@"http://jabber.org/protocol/disco#info"];
    [self addChild:queryNode];
}

-(void) setDiscoItemNode
{
    MLXMLNode* queryNode =[[MLXMLNode alloc] initWithElement:@"query" andNamespace:@"http://jabber.org/protocol/disco#items"];
    [self addChild:queryNode];
}

-(void) setDiscoInfoWithFeatures:(NSSet*) features identity:(MLXMLNode*) identity andNode:(NSString*) node
{
    MLXMLNode* queryNode = [[MLXMLNode alloc] initWithElement:@"query" andNamespace:@"http://jabber.org/protocol/disco#info"];
    if(node)
        [queryNode.attributes setObject:node forKey:@"node"];
    
    for(NSString* feature in features)
    {
        MLXMLNode* featureNode = [[MLXMLNode alloc] initWithElement:@"feature"];
        featureNode.attributes[@"var"] = feature;
        [queryNode addChild:featureNode];
    }
    
    [queryNode addChild:identity];
    
    [self addChild:queryNode];
}

-(void) setiqTo:(NSString*) to
{
    if(to)
        [self.attributes setObject:to forKey:@"to"];
}

-(void) setiqFrom:(NSString *) from
{
    if(from)
        [self.attributes setObject:from forKey:@"from"];
}
-(void) setPing
{
    MLXMLNode* pingNode = [[MLXMLNode alloc] initWithElement:@"ping" andNamespace:@"in:secure:signal:ping"];
    [self addChild:pingNode];
}

#pragma mark - MAM

-(void) mamArchivePref
{
    MLXMLNode* queryNode =[[MLXMLNode alloc] init];
    queryNode.element=@"prefs";
    [queryNode.attributes setObject:@"in:secure:signal:mam:2" forKey:kXMLNS];
    [self addChild:queryNode];
}

-(void) updateMamArchivePrefDefault:(NSString *) pref
{
    /**
     pref is aways, never or roster
     */
    MLXMLNode* queryNode =[[MLXMLNode alloc] init];
    queryNode.element=@"prefs";
    [queryNode.attributes setObject:@"in:secure:signal:mam:2" forKey:kXMLNS];
    [queryNode.attributes setObject:pref forKey:@"default"];
    [self addChild:queryNode];
}

-(void) setMAMQueryLatestMessagesForJid:(NSString* _Nullable) jid before:(NSString* _Nullable) uid
{
    //set iq id to mam query id
    self.id = [NSString stringWithFormat:@"MLhistory:%@", [[NSUUID UUID] UUIDString]];
    XMPPDataForm* form = [[XMPPDataForm alloc] initWithType:@"submit" andFormType:@"in:secure:signal:mam:2"];
    if(jid)
        form[@"with"] = jid;
    MLXMLNode* queryNode = [[MLXMLNode alloc] initWithElement:@"query" andNamespace:@"in:secure:signal:mam:2" withAttributes:@{
        @"queryid": self.id
    } andChildren:@[
        form,
        [[MLXMLNode alloc] initWithElement:@"set" andNamespace:@"http://jabber.org/protocol/rsm" withAttributes:@{} andChildren:@[
            [[MLXMLNode alloc] initWithElement:@"max" withAttributes:@{} andChildren:@[] andData:@"50"],
            [[MLXMLNode alloc] initWithElement:@"before" withAttributes:@{} andChildren:@[] andData:uid]
        ] andData:nil]
    ] andData:nil];
    [self addChild:queryNode];
}

-(void) setMAMQueryForLatestId
{
    //set iq id to mam query id
    self.id = [NSString stringWithFormat:@"MLignore:%@", [[NSUUID UUID] UUIDString]];
    MLXMLNode* queryNode = [[MLXMLNode alloc] initWithElement:@"query" andNamespace:@"in:secure:signal:mam:2" withAttributes:@{
        @"queryid": self.id
    } andChildren:@[
        [[XMPPDataForm alloc] initWithType:@"submit" formType:@"in:secure:signal:mam:2" andDictionary:@{
            @"end": [HelperTools generateDateTimeString:[NSDate date]]
        }],
        [[MLXMLNode alloc] initWithElement:@"set" andNamespace:@"http://jabber.org/protocol/rsm" withAttributes:@{} andChildren:@[
            [[MLXMLNode alloc] initWithElement:@"max" withAttributes:@{} andChildren:@[] andData:@"1"],
            [[MLXMLNode alloc] initWithElement:@"before"]
        ] andData:nil]
    ] andData:nil];
    [self addChild:queryNode];
}

-(void) setMAMQueryAfter:(NSString*) uid
{
    //set iq id to mam query id
    self.id = [NSString stringWithFormat:@"MLcatchup:%@", [[NSUUID UUID] UUIDString]];
    MLXMLNode* queryNode = [[MLXMLNode alloc] initWithElement:@"query" andNamespace:@"in:secure:signal:mam:2" withAttributes:@{
        @"queryid": self.id
    } andChildren:@[
        [[XMPPDataForm alloc] initWithType:@"submit" andFormType:@"in:secure:signal:mam:2"],
        [[MLXMLNode alloc] initWithElement:@"set" andNamespace:@"http://jabber.org/protocol/rsm" withAttributes:@{} andChildren:@[
            [[MLXMLNode alloc] initWithElement:@"max" withAttributes:@{} andChildren:@[] andData:@"50"],
            [[MLXMLNode alloc] initWithElement:@"after" withAttributes:@{} andChildren:@[] andData:uid]
        ] andData:nil]
    ] andData:nil];
    [self addChild:queryNode];
}

-(void) setCompleteMAMQuery
{
    //set iq id to mam query id
    self.id = [NSString stringWithFormat:@"MLcatchup:%@", [[NSUUID UUID] UUIDString]];
    MLXMLNode* queryNode = [[MLXMLNode alloc] initWithElement:@"query" andNamespace:@"in:secure:signal:mam:2" withAttributes:@{
        @"queryid": self.id
    } andChildren:@[
        [[XMPPDataForm alloc] initWithType:@"submit" andFormType:@"in:secure:signal:mam:2"],
        [[MLXMLNode alloc] initWithElement:@"set" andNamespace:@"http://jabber.org/protocol/rsm" withAttributes:@{} andChildren:@[
            [[MLXMLNode alloc] initWithElement:@"max" withAttributes:@{} andChildren:@[] andData:@"50"]
        ] andData:nil]
    ] andData:nil];
    [self addChild:queryNode];
}

-(void) setRemoveFromRoster:(NSString*) jid
{
    [self addChild:[[MLXMLNode alloc] initWithElement:@"query" andNamespace:@"jabber:iq:roster" withAttributes:@{} andChildren:@[
        [[MLXMLNode alloc] initWithElement:@"item" withAttributes:@{
            @"jid": jid,
            @"subscription": @"remove"
        } andChildren:@[] andData:nil]
    ] andData:nil]];
}

-(void) setUpdateRosterItem:(NSString* _Nonnull) jid withName:(NSString* _Nonnull) name
{
    [self addChild:[[MLXMLNode alloc] initWithElement:@"query" andNamespace:@"jabber:iq:roster" withAttributes:@{} andChildren:@[
        [[MLXMLNode alloc] initWithElement:@"item" withAttributes:@{
            @"jid": jid,
            @"name": name,
        } andChildren:@[] andData:nil]
    ] andData:nil]];
}

-(void) setRosterRequest:(NSString*) version
{
    MLXMLNode* queryNode = [[MLXMLNode alloc] init];
    queryNode.element = @"query";
    [queryNode.attributes setObject:@"jabber:iq:roster" forKey:kXMLNS];
    if(version)
        [queryNode.attributes setObject:version forKey:@"ver"];
    [self addChild:queryNode];
}

-(void) setVersion
{
    MLXMLNode* queryNode = [[MLXMLNode alloc] init];
    queryNode.element = @"query";
    [queryNode.attributes setObject:@"jabber:iq:version" forKey:kXMLNS];
    
    MLXMLNode* name = [[MLXMLNode alloc] init];
    name.element = @"name";
    name.data = @"Monal";
    
#if TARGET_OS_MACCATALYST
    MLXMLNode* os = [[MLXMLNode alloc] init];
    os.element = @"os";
    os.data = @"macOS";
#else
    MLXMLNode* os = [[MLXMLNode alloc] init];
    os.element = @"os";
    os.data = @"iOS";
#endif
    
    MLXMLNode* appVersion = [[MLXMLNode alloc] initWithElement:@"version"];
    appVersion.data = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    [queryNode addChild:name];
    [queryNode addChild:os];
    [queryNode addChild:appVersion];
    [self addChild:queryNode];
}

-(void) setBlocked:(BOOL) blocked forJid:(NSString* _Nonnull) blockedJid
{
    MLXMLNode* blockNode = [[MLXMLNode alloc] initWithElement:(blocked ? @"block" : @"unblock") andNamespace:@"in:secure:signal:blocking"];
    
    MLXMLNode* itemNode = [[MLXMLNode alloc] initWithElement:@"item"];
    [itemNode.attributes setObject:blockedJid forKey:kJid];
    [blockNode addChild:itemNode];
    
    [self addChild:blockNode];
}

-(void) requestBlockList
{
    MLXMLNode* blockNode = [[MLXMLNode alloc] initWithElement:@"blocklist" andNamespace:@"in:secure:signal:blocking"];
    [self addChild:blockNode];
}

-(void) httpUploadforFile:(NSString *) file ofSize:(NSNumber *) filesize andContentType:(NSString *) contentType
{
    MLXMLNode* requestNode = [[MLXMLNode alloc] initWithElement:@"request" andNamespace:@"in:secure:signal:http:upload:0"];
    requestNode.attributes[@"filename"] = file;
    requestNode.attributes[@"size"] = [NSString stringWithFormat:@"%@", filesize];
    requestNode.attributes[@"content-type"] = contentType;
    [self addChild:requestNode];
}


#pragma mark iq get

-(void) getEntitySoftWareVersionTo:(NSString*) to
{
    [self setiqTo:to];
    
    MLXMLNode* queryNode = [[MLXMLNode alloc] initWithElement:@"query" andNamespace:@"jabber:iq:version"];
    
    [self addChild:queryNode];
}

#pragma mark MUC


-(void) createReserverdRoom
{
    MLXMLNode* queryNode =[[MLXMLNode alloc] init];
    queryNode.element=@"query";
    [queryNode.attributes setObject:@"http://jabber.org/protocol/muc#owner" forKey:kXMLNS];
    
//    MLXMLNode* xNode =[[MLXMLNode alloc] init];
//    xNode.element=@"x";
//    [xNode.attributes setObject:@"jabber:x:data" forKey:kXMLNS];
//    [xNode.attributes setObject:@"submit" forKey:@"type"];
//
//    [queryNode addChild:xNode];
    [self addChild:queryNode];
}

-(void) defaultRoomConfiguration:(NSString *)roomSubjectName{
    NSNumber *truevalue = @1;
    NSNumber *falsevalue = @0;
    MLXMLNode* queryNode = [[MLXMLNode alloc] init];
    queryNode.element=@"query";
    [queryNode.attributes setObject:@"http://jabber.org/protocol/muc#owner" forKey:kXMLNS];
    
    MLXMLNode* xNode =[[MLXMLNode alloc] init];
    xNode.element=@"x";
    [xNode.attributes setObject:@"jabber:x:data" forKey:kXMLNS];
    [xNode.attributes setObject:@"submit" forKey:@"type"];
    
    MLXMLNode* formTypeField =[[MLXMLNode alloc] init];
    formTypeField.element=@"field";
   
    [formTypeField.attributes setObject:@"FORM_TYPE" forKey:@"var"];
    MLXMLNode *formValue = [[MLXMLNode alloc] initWithElement:@"value"];
    formValue.data = @"http://jabber.org/protocol/muc#roomconfig";
    [formTypeField addChild:formValue];
  
    
    MLXMLNode* publicField =[[MLXMLNode alloc] init];
    publicField.element=@"field";
    [publicField.attributes setObject:@"muc#roomconfig_publicroom" forKey:@"var"];
    MLXMLNode *publicValue = [[MLXMLNode alloc] initWithElement:@"value"];
    publicValue.data = [falsevalue stringValue];
    [publicField addChild:publicValue];
    
    
    MLXMLNode* RoomSubject =[[MLXMLNode alloc] init];
    RoomSubject.element=@"field";
    [RoomSubject.attributes setObject:@"muc#roomconfig_changesubject" forKey:@"var"];
    MLXMLNode *roomValue = [[MLXMLNode alloc] initWithElement:@"value"];
    roomValue.data = [truevalue stringValue];
    [RoomSubject addChild:roomValue];
   
    
    MLXMLNode* RoomName =[[MLXMLNode alloc] init];
    RoomName.element=@"field";
    [RoomName.attributes setObject:@"muc#roomconfig_roomname" forKey:@"var"];
    MLXMLNode *roomNameValue = [[MLXMLNode alloc] initWithElement:@"value"];
    roomNameValue.data = roomSubjectName;
   
    [RoomName addChild:roomNameValue];
   
    
    MLXMLNode* persistantField =[[MLXMLNode alloc] init];
    persistantField.element=@"field";
    [persistantField.attributes setObject:@"muc#roomconfig_persistentroom" forKey:@"var"];
    MLXMLNode *persistantValue = [[MLXMLNode alloc] initWithElement:@"value"];
    persistantValue.data = [truevalue stringValue];
    [persistantField addChild:persistantValue];
  
    

    MLXMLNode* whoisfield =[[MLXMLNode alloc] init];
    whoisfield.element= @"field";
    [whoisfield.attributes setObject:@"muc#roomconfig_whois" forKey:@"var"];
    MLXMLNode *whoisValue = [[MLXMLNode alloc] initWithElement:@"value"];
    whoisValue.data = @"anyone";
    [whoisfield addChild:whoisValue];
  
    
    MLXMLNode* membersonlyField =[[MLXMLNode alloc] init];
    membersonlyField.element=@"field";
    [membersonlyField.attributes setObject:@"muc#roomconfig_membersonly" forKey:@"var"];
    MLXMLNode *memberValue = [[MLXMLNode alloc] initWithElement:@"value"];
    memberValue.data = [truevalue stringValue] ;
    [membersonlyField addChild:memberValue];
    
   
    
    MLXMLNode* invitesField =[[MLXMLNode alloc] init];
    invitesField.element=@"field";
    [invitesField.attributes setObject:@"muc#roomconfig_allowinvites" forKey:@"var"];
    MLXMLNode *inviteValue = [[MLXMLNode alloc] initWithElement:@"value"];
    inviteValue.data = [truevalue stringValue];
    [invitesField addChild:inviteValue];
    
    //presenceBroadcastField
    MLXMLNode* presenceBroadcastField =[[MLXMLNode alloc] init];
    presenceBroadcastField.element=@"field";
    [presenceBroadcastField.attributes setObject:@"muc#roomconfig_presencebroadcast" forKey:@"var"];
    MLXMLNode *presenceValue = [[MLXMLNode alloc] initWithElement:@"value"];
    presenceValue.data = @"moderator";
    MLXMLNode *presenceAnyoneValue =[[MLXMLNode alloc] initWithElement:@"value"];
    presenceAnyoneValue.data = @"anyone";
    [presenceBroadcastField addChild:presenceValue];
    [presenceBroadcastField addChild:presenceAnyoneValue];
 
 
    [xNode addChild:formTypeField];
    [xNode addChild:publicField];
    [xNode addChild:RoomSubject];
    [xNode addChild:RoomName];
    [xNode addChild:persistantField];
    [xNode addChild:whoisfield];
    [xNode addChild:membersonlyField];
    [xNode addChild:invitesField];
   // [xNode addChild:presenceBroadcastField];
    [queryNode addChild:xNode];
    
    [self addChild:queryNode];
}
-(void) setInstantRoom
{
    MLXMLNode* queryNode =[[MLXMLNode alloc] init];
    queryNode.element=@"query";
    [queryNode.attributes setObject:@"http://jabber.org/protocol/muc#owner" forKey:kXMLNS];
    
    MLXMLNode* xNode =[[MLXMLNode alloc] init];
    xNode.element=@"x";
    [xNode.attributes setObject:@"jabber:x:data" forKey:kXMLNS];
    [xNode.attributes setObject:@"submit" forKey:@"type"];
    
    [queryNode addChild:xNode];
    [self addChild:queryNode];
}

#pragma mark Jingle

-(void) setJingleInitiateTo:(NSString*) jid andResource:(NSString*) resource withValues:(NSDictionary*) info
{
    [self setiqTo:[NSString stringWithFormat:@"%@/%@",jid,resource]];
    
    MLXMLNode* jingleNode =[[MLXMLNode alloc] init];
    jingleNode.element=@"jingle";
    [jingleNode setXMLNS:@"in:secure:signal:jingle:1"];
    [jingleNode.attributes setObject:@"session-initiate" forKey:@"action"];
    [jingleNode.attributes setObject:[info objectForKey:@"initiator"] forKey:@"initiator"];
   [jingleNode.attributes setObject:[info objectForKey:@"sid"] forKey:@"sid"];
 
   MLXMLNode* contentNode =[[MLXMLNode alloc] init];
    contentNode.element=@"content";
    [contentNode.attributes setObject:@"initiator" forKey:@"creator"];
    [contentNode.attributes setObject:@"audio-session" forKey:@"name"];
    
    MLXMLNode* description =[[MLXMLNode alloc] init];
    description.element=@"description";
    [description.attributes setObject:@"in:secure:signal:jingle:apps:rtp:1" forKey:kXMLNS];
    [description.attributes setObject:@"audio" forKey:@"media"];

    
    MLXMLNode* payload =[[MLXMLNode alloc] init];
    payload.element=@"payload-type";
    [payload.attributes setObject:@"8" forKey:@"id"];
    [payload.attributes setObject:@"PCMA" forKey:@"name"];
    [payload.attributes setObject:@"8000" forKey:@"clockrate"];
    [payload.attributes setObject:@"1" forKey:@"channels"];
    
    [description addChild:payload];
    
    MLXMLNode* transport =[[MLXMLNode alloc] init];
    transport.element=@"transport";
    [transport.attributes setObject:@"in:secure:signal:jingle:transports:raw-udp:1" forKey:kXMLNS];

    
    MLXMLNode* candidate1 =[[MLXMLNode alloc] init];
    candidate1.element=@"candidate";
    [candidate1.attributes setObject:@"1" forKey:@"component"];
    [candidate1.attributes setObject:[info objectForKey:@"ownip"] forKey:@"ip"];
    [candidate1.attributes setObject:[info objectForKey:@"localport1"] forKey:@"port"];
    [candidate1.attributes setObject:@"monal001" forKey:@"id"];
    [candidate1.attributes setObject:@"0" forKey:@"generation"];
    
    MLXMLNode* candidate2 =[[MLXMLNode alloc] init];
    candidate2.element=@"candidate";
    [candidate2.attributes setObject:@"2" forKey:@"component"];
    [candidate2.attributes setObject:[info objectForKey:@"ownip"] forKey:@"ip"];
    [candidate2.attributes setObject:[info objectForKey:@"localport2"] forKey:@"port"];
    [candidate2.attributes setObject:@"monal002" forKey:@"id"];
    [candidate2.attributes setObject:@"0" forKey:@"generation"];
    
    [transport addChild:candidate1];
    [transport addChild:candidate2];
    
    [contentNode addChild:description];
    [contentNode addChild:transport];
    
    [jingleNode addChild:contentNode];
    [self addChild:jingleNode];
    
    
//        [query appendFormat:@" <iq to='%@/%@' id='%@' type='set'> <jingle xmlns='in:secure:signal:jingle:1' action='session-initiate' initiator='%@' responder='%@' sid='%@'>
//         <content creator='initiator'  name=\"audio-session\" senders=\"both\" responder='%@'>
//         <description xmlns=\"in:secure:signal:jingle:apps:rtp:1\" media=\"audio\">
//         <payload-type id=\"8\" name=\"PCMA\" clockrate=\"8000\" channels='0'/></description>
//         
//         <transport xmlns='in:secure:signal:jingle:transports:raw-udp:1'>
//         <candidate component=\"1\" ip=\"%@\" port=\"%@\"   id=\"monal001\" generation=\"0\"   />
//         <candidate component=\"2\" ip=\"%@\" port=\"%@\"   id=\"monal002\" generation=\"0\"  /> </transport> </content>
//         
//         </jingle> </iq>", self.otherParty, _resource, _iqid, self.me, _to,  self.thesid, _to, _ownIP, self.localPort, _ownIP,self.localPort2];
}


-(void) setJingleAcceptTo:(NSString*) jid andResource:(NSString*) resource withValues:(NSDictionary*) info
{
    [self setiqTo:[NSString stringWithFormat:@"%@/%@",jid,resource]];
    
    MLXMLNode* jingleNode =[[MLXMLNode alloc] init];
    jingleNode.element=@"jingle";
    [jingleNode setXMLNS:@"in:secure:signal:jingle:1"];
    [jingleNode.attributes setObject:@"session-accept" forKey:@"action"];
    [jingleNode.attributes setObject:[info objectForKey:@"initiator"] forKey:@"initiator"];
    [jingleNode.attributes setObject:[info objectForKey:@"responder"] forKey:@"responder"];
    [jingleNode.attributes setObject:[info objectForKey:@"sid"] forKey:@"sid"];
    
    MLXMLNode* contentNode =[[MLXMLNode alloc] init];
    contentNode.element=@"content";
    [contentNode.attributes setObject:@"creator" forKey:@"initiator"];
    [contentNode.attributes setObject:@"audio-session" forKey:@"name"];
    [contentNode.attributes setObject:@"both" forKey:@"senders"];
    [contentNode.attributes setObject:[info objectForKey:@"responder"] forKey:@"responder"];
    
    
    MLXMLNode* description =[[MLXMLNode alloc] init];
    description.element=@"description";
    [description.attributes setObject:@"in:secure:signal:jingle:apps:rtp:1" forKey:kXMLNS];
    [description.attributes setObject:@"audio" forKey:@"media"];
    
    
    MLXMLNode* payload =[[MLXMLNode alloc] init];
    payload.element=@"payload-type";
    [payload.attributes setObject:@"8" forKey:@"id"];
    [payload.attributes setObject:@"PCMA" forKey:@"name"];
    [payload.attributes setObject:@"8000" forKey:@"clockrate"];
    [payload.attributes setObject:@"1" forKey:@"channels"];
    
    [description addChild:payload];
    
    MLXMLNode* transport =[[MLXMLNode alloc] init];
    transport.element=@"transport";
    [transport.attributes setObject:@"in:secure:signal:jingle:transports:raw-udp:1" forKey:kXMLNS];
    
    
    MLXMLNode* candidate1 =[[MLXMLNode alloc] init];
    candidate1.element=@"candidate";
    [candidate1.attributes setObject:@"1" forKey:@"component"];
    [candidate1.attributes setObject:[info objectForKey:@"ownip"] forKey:@"ip"];
    [candidate1.attributes setObject:[info objectForKey:@"localport1"] forKey:@"port"];
    [candidate1.attributes setObject:@"monal001" forKey:@"id"];
    [candidate1.attributes setObject:@"0" forKey:@"generation"];
    
    MLXMLNode* candidate2 =[[MLXMLNode alloc] init];
    candidate2.element=@"candidate";
    [candidate2.attributes setObject:@"2" forKey:@"component"];
    [candidate2.attributes setObject:[info objectForKey:@"ownip"] forKey:@"ip"];
    [candidate2.attributes setObject:[info objectForKey:@"localport2"] forKey:@"port"];
    [candidate2.attributes setObject:@"monal002" forKey:@"id"];
    [candidate2.attributes setObject:@"0" forKey:@"generation"];
    
    [transport addChild:candidate1];
    [transport addChild:candidate2];
    
    [contentNode addChild:description];
    [contentNode addChild:transport];
    
    [jingleNode addChild:contentNode];
    [self addChild:jingleNode];
    
}
-(void) setJingleDeclineTo:(NSString*) jid andResource:(NSString*) resource withValues:(NSDictionary*) info
{
    [self setiqTo:[NSString stringWithFormat:@"%@/%@",jid,resource]];

    MLXMLNode* jingleNode =[[MLXMLNode alloc] init];
    jingleNode.element=@"jingle";
    [jingleNode setXMLNS:@"in:secure:signal:jingle:1"];
    [jingleNode.attributes setObject:@"session-terminate" forKey:@"action"];
    [jingleNode.attributes setObject:[info objectForKey:@"sid"] forKey:@"sid"];
    
    MLXMLNode* reason =[[MLXMLNode alloc] init];
    reason.element=@"reason";
    
    MLXMLNode* decline =[[MLXMLNode alloc] init];
    decline.element=@"decline";
    
    [reason addChild:decline] ;
    [jingleNode addChild:reason];
    [self addChild:jingleNode];
    
}

-(void) setJingleTerminateTo:(NSString*) jid andResource:(NSString*) resource withValues:(NSDictionary*) info
{
    if([jid rangeOfString:@"/"].location==NSNotFound) {
        [self setiqTo:[NSString stringWithFormat:@"%@/%@",jid,resource]];
    }
    else {
        [self setiqTo:jid];
    }
    
    MLXMLNode* jingleNode =[[MLXMLNode alloc] init];
    jingleNode.element=@"jingle";
    [jingleNode setXMLNS:@"in:secure:signal:jingle:1"];
    [jingleNode.attributes setObject:@"session-terminate" forKey:@"action"];
  
    [jingleNode.attributes setObject:[info objectForKey:@"sid"] forKey:@"sid"];
    
    MLXMLNode* reason =[[MLXMLNode alloc] init];
    reason.element=@"reason";

    MLXMLNode* success =[[MLXMLNode alloc] init];
    success.element=@"success";

    [reason addChild:success] ;
    [jingleNode addChild:reason];
    [self addChild:jingleNode];

  
}

#pragma mark - Account Management
-(void) getRegistrationFields
{
    MLXMLNode* query = [[MLXMLNode alloc] init];
    query.element = @"query";
    [query setXMLNS:kRegisterNameSpace];
    [self addChild:query];
}

/*
 This is really hardcoded for yax.im might work for others
 */
-(void) registerUser:(NSString *) user withPassword:(NSString *) newPass captcha:(NSString *) captcha andHiddenFields:(NSDictionary *)hiddenFields
{
    MLXMLNode* query =[[MLXMLNode alloc] init];
    query.element=@"query";
    [query setXMLNS:kRegisterNameSpace];
    
    MLXMLNode* x =[[MLXMLNode alloc] init];
    x.element=@"x";
    [x setXMLNS:kDataNameSpace];
    [x.attributes setValue:@"submit" forKey:@"type"];
    
    
    MLXMLNode* username =[[MLXMLNode alloc] init];
    username.element=@"field";
    [username.attributes setValue:@"username" forKey:@"var"];
    MLXMLNode* usernameValue =[[MLXMLNode alloc] init];
    usernameValue.element=@"value";
    usernameValue.data=user;
    [username addChild:usernameValue];
    
    MLXMLNode* password =[[MLXMLNode alloc] init];
    password.element=@"field";
    [password.attributes setValue:@"password" forKey:@"var"];
    MLXMLNode* passwordValue =[[MLXMLNode alloc] init];
    passwordValue.element=@"value";
    passwordValue.data=newPass;
     [password addChild:passwordValue];
    
    MLXMLNode* ocr =[[MLXMLNode alloc] init];
    ocr.element=@"field";
     [ocr.attributes setValue:@"ocr" forKey:@"var"];
    MLXMLNode* ocrValue =[[MLXMLNode alloc] init];
    ocrValue.element=@"value";
    ocrValue.data=captcha;
    [ocr addChild:ocrValue];
    
    [hiddenFields enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
       
        MLXMLNode* field =[[MLXMLNode alloc] init];
        field.element=@"field";
        [field.attributes setValue:key forKey:@"var"];
        MLXMLNode* fieldValue =[[MLXMLNode alloc] init];
        fieldValue.element=@"value";
        fieldValue.data=obj;
        [field addChild:fieldValue];
        
        [x addChild:field];
        
    }];
    
    [x addChild:username];
    [x addChild:password];
    [x addChild:ocr];
    
    [query addChild:x];
    
    [self addChild:query];
}

-(void) changePasswordForUser:(NSString *) user newPassword:(NSString *)newPass
{
    MLXMLNode* query =[[MLXMLNode alloc] init];
    query.element=@"query";
    [query setXMLNS:kRegisterNameSpace];
    
    MLXMLNode* username =[[MLXMLNode alloc] init];
    username.element=@"username";
    username.data=user;
    
    MLXMLNode* password =[[MLXMLNode alloc] init];
    password.element=@"password";
    password.data=newPass;
   
    [query addChild:username];
    [query addChild:password];
    
    [self addChild:query];
    
}


@end

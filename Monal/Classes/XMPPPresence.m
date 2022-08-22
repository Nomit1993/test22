//
//  XMPPPresence.m
//  Monal
//
//  Created by Anurodh Pokharel on 7/5/13.
//
//

#import "XMPPPresence.h"
#import "HelperTools.h"

@implementation XMPPPresence

-(id) init
{
    self = [super init];
    self.element = @"presence";
    [self setXMLNS:@"c5b9cdd82abcf6305f9c24fa5b7715e15dfe36fa810852494dad0297fd9dc866:client"];
    self.attributes[@"id"] = [[NSUUID UUID] UUIDString];
    return self;
}

-(id) initWithHash:(NSString*) version
{
    self = [self init];
    [self addChild:[[MLXMLNode alloc] initWithElement:@"c" andNamespace:@"http://jabber.org/protocol/caps" withAttributes:@{
        @"node": @"http://monal.im/",
        @"hash": @"sha-1",
        @"ver": version
    } andChildren:@[] andData:nil]];
    return self;
}

#pragma mark own state
-(void) setShow:(NSString*) showVal
{
    MLXMLNode* show = [[MLXMLNode alloc] init];
    show.element = @"show";
    show.data=showVal;
    [self addChild:show];
}

-(void) setAway
{
    [self setShow:@"away"];
}

-(void) setAvailable
{
    [self setShow:@"chat"];
}

-(void) setStatus:(NSString*) status
{
    MLXMLNode* statusNode = [[MLXMLNode alloc] init];
    statusNode.element = @"status";
    statusNode.data = status;
    [self addChild:statusNode];
}

-(void) setLastInteraction:(NSDate*) date
{
    MLXMLNode* idle = [[MLXMLNode alloc] initWithElement:@"idle" andNamespace:@"in:secure:signal:idle:1"];
    [idle.attributes setValue:[HelperTools generateDateTimeString:date] forKey:@"since"];
    [self addChild:idle];
}

#pragma mark MUC 

-(void) joinRoom:(NSString*) room withNick:(NSString*) nick
{
    [self.attributes setObject:[NSString stringWithFormat:@"%@/%@", room, nick] forKey:@"to"];
    [self addChild:[[MLXMLNode alloc] initWithElement:@"x" andNamespace:@"http://jabber.org/protocol/muc" withAttributes:@{} andChildren:@[
        [[MLXMLNode alloc] initWithElement:@"history" withAttributes:@{@"maxstanzas": @"0"} andChildren:@[] andData:nil]
    ] andData:nil]];
}

-(void) createRoom:(NSString*) room withNick:(NSString*)nick{
    self.attributes[@"to"] = [NSString stringWithFormat:@"%@/%@", room, nick];
    self.attributes[@"type"] = @"set";
}
-(void) leaveRoom:(NSString*) room withNick:(NSString*) nick
{
    self.attributes[@"to"] = [NSString stringWithFormat:@"%@/%@", room, nick];
    self.attributes[@"type"] = @"unavailable";
}

#pragma mark subscription

-(void) unsubscribeContact:(NSString*) jid
{
    [self.attributes setObject:jid forKey:@"to"];
    [self.attributes setObject:@"unsubscribe" forKey:@"type"];
}

-(void) subscribeContact:(NSString*) jid
{
    [self.attributes setObject:jid forKey:@"to"];
    [self.attributes setObject:@"subscribe" forKey:@"type"];
}

-(void) subscribedContact:(NSString*) jid
{
    [self.attributes setObject:jid forKey:@"to"];
    [self.attributes setObject:@"subscribed" forKey:@"type"];
}

-(void) unsubscribedContact:(NSString*) jid
{
    [self.attributes setObject:jid forKey:@"to"];
    [self.attributes setObject:@"unsubscribed" forKey:@"type"];
}

@end

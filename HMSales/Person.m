//
//  Person.m
//  Maestro iLeads
//
//  Created by Dan Frazee on 9/14/12.
//  Copyright (c) 2012 Maestro. All rights reserved.
//

#import "Person.h"
//#import "PhoneNumber.h"

@implementation Person

@synthesize name;
@synthesize designation;
@synthesize email;
@synthesize phone;
@synthesize contactTime;
@synthesize shouldbeNotifiedWithMail;
@synthesize arrayInterested;
@synthesize picture;
@synthesize contactTimeOther;
@synthesize interestedInOther;

-(NSString *)description
{
    return [NSString stringWithFormat:@"%@,%@",self.name,self.email,nil];
}

@end

//
//  Person.h
//  Maestro iLeads
//
//  Created by Dan Frazee on 9/14/12.
//  Copyright (c) 2012 Maestro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PhoneNumber;

@interface Person : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *designation;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *contactTime;
@property (nonatomic, strong) NSString *contactTimeOther;
@property (nonatomic, strong) NSString *shouldbeNotifiedWithMail;
@property (nonatomic, strong) NSString *picture;
@property (nonatomic, strong) NSMutableArray  *arrayInterested;
@property (nonatomic, strong) NSString *interestedInOther;

@end
//
//  artistInfoData.h
//  Echonest API
//
//  Created by Zoufishan Mehdi on 11/8/15.
//  Copyright © 2015 Zoufishan Mehdi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface artistInfoData : NSObject

@property (nonatomic) NSString *artist;
@property (nonatomic) NSString *yearsActive;
@property (nonatomic) NSString *hometown;
@property (nonatomic) NSString *bio;
@property (nonatomic) NSString *imageURL;

- (instancetype)initWithJSON:(NSDictionary *)json;


@end

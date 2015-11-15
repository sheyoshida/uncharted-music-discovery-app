//
//  artistInfoData.h
//  Echonest API
//
//  Created by Zoufishan Mehdi on 11/8/15.
//  Copyright © 2015 Zoufishan Mehdi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface artistInfoData : NSObject

// echonest api call
@property (nonatomic) NSString *artistName;
@property (nonatomic) NSString *artistYearsActive;
@property (nonatomic) NSString *artistHometown;
@property (nonatomic) NSString *artistBio;
@property (nonatomic) NSString *artistImageURL;
@property (nonatomic) NSString *artistGenre;

@property (nonatomic) NSString *ratingDiscovery; // measure how unexpectedly artist is
@property (nonatomic) NSString *ratingFamiliarity; // measure how familiar artist is
@property (nonatomic) NSString *ratingHotttnesss; // measure how popular artist is

// spotify api call #1
@property (nonatomic) NSString *albumArtURL;
@property (nonatomic) NSString *albumTitle;
@property (nonatomic) NSString *albumID;

// spotify api call #2
@property (nonatomic) NSString *songPreview; // url
@property (nonatomic) NSString *songTitle;


- (void)initWithJSON:(NSDictionary *)json;


@end

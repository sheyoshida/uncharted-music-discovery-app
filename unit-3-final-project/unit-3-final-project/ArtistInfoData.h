//
//  artistInfoData.h
//  Echonest API
//
//  Created by Zoufishan Mehdi on 11/8/15.
//  Copyright © 2015 Zoufishan Mehdi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArtistInfoData : NSObject

// echonest api call
@property (nonatomic) NSString *artistName;
@property (nonatomic) NSString *artistYearsActiveStartDate;
@property (nonatomic) NSString *artistYearsActiveEndDate;
@property (nonatomic) NSString *artistHometown;
@property (nonatomic) NSString *artistLocation; 
@property (nonatomic) NSString *artistBio;
@property (nonatomic) NSMutableArray *echonestImages;
@property (nonatomic) NSMutableArray *spotifyImages;

@property (nonatomic) NSString *artistImageURL;
@property (nonatomic) NSString *artistGenre;

@property (nonatomic) NSString *ratingDiscovery; // measure how unexpected artist is
@property (nonatomic) NSString *ratingFamiliarity; // measure how familiar artist is
@property (nonatomic) NSString *ratingHotttnesss; // measure how popular artist is

// spotify api call #1
@property (nonatomic) NSString *albumArtURL;
@property (nonatomic) NSString *albumTitle;
@property (nonatomic) NSString *albumID;

// spotify api call #2
@property (nonatomic) NSString *songPreview; // url
@property (nonatomic) NSString *songTitle;
<<<<<<< 954d15ad8bb336a4fdc55d5249c0d06fc1b0a252
@property (nonatomic) NSString *songURI; // for adding song to playlist

// playlist stuff
@property (nonatomic) BOOL liked; // for heart button
=======
@property (nonatomic) NSString *songURI;
>>>>>>> spotify integration


- (instancetype)initWithJSON:(NSDictionary *)json;


@end

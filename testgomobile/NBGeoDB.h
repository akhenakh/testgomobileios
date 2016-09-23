//
//  NBGeoDB.h
//  testgomobile
//
//  Created by akh on 9/22/16.
//  Copyright © 2016 akh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mobile/Mobile.h>

@interface NBGeoDB : NSObject

@property(strong) GoMobileGeoDB* gf;

+ (id)sharedGeoDB;

@end

//
//  NBGeoDB.m
//  testgomobile
//
//  Created by akh on 9/22/16.
//  Copyright © 2016 akh. All rights reserved.
//

#import "NBGeoDB.h"


@interface NBGeoDB()
@end


@implementation NBGeoDB

+ (id)sharedGeoDB {
    static NBGeoDB *sharedGeoDB = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedGeoDB = [[self alloc] init];
    });
    return sharedGeoDB;
}

- (id)init {
    if (self = [super init]) {
        _gf = GoMobileNewGeoDB();
        NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"region" ofType:@"db"];
        
        NSError *error;
        [self.gf openDB:resourcePath error:&error];
        if (error != nil) {
            NSLog(@"error opening db %@", [error localizedDescription]);
        } else {
            NSLog(@"opened db at %@", resourcePath);
        }
    }
    return self;
}



@end

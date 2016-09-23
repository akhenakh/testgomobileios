//
//  testgomobileTests.m
//  testgomobileTests
//
//  Created by akh on 9/21/16.
//  Copyright © 2016 akh. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Mobile/Mobile.h>

@interface testgomobileTests : XCTestCase
@property(strong) GoMobileGeoDB *db;
@end

@implementation testgomobileTests

- (void)setUp {
    [super setUp];
    GoMobileGeoDB *db = GoMobileNewGeoDB();
    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"region" ofType:@"db"];
    NSLog(@"opened db at %@", resourcePath);

    NSError *error;
    [db openDB:resourcePath error:&error];
    if (error != nil) {
        NSLog(@"error opening db %@", [error localizedDescription]);
    } else {
        NSLog(@"opened db at %@", resourcePath);
    }
    XCTAssertNil(error);
    self.db = db;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [self.db close:nil];
    self.db = nil;
}

- (void)testDB {
    GoMobileFence *fence = [self.db queryHandler:48.2 lng:2.2];
    XCTAssertNotNil(fence);
    XCTAssertEqualObjects(@"FR", fence.iso);
}


- (void)testSpeedMissing {
      [self measureBlock:^{
        for (int i=0;i<60000;i++) {
            GoMobileFence *fence = [self.db queryHandler:34 lng:34];
            XCTAssertNil(fence);
        }
    }];
}

- (void)testSpeedInFence {
       [self measureBlock:^{
        for (int i=0;i<4000;i++) {
            GoMobileFence *fence = [self.db queryHandler:49.214439 lng:-2.131250];
            XCTAssertNotNil(fence);
            XCTAssertEqualObjects(@"JE", fence.iso);
        }
    }];
}

@end

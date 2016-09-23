//
//  ViewController.m
//  testgomobile
//
//  Created by akh on 9/21/16.
//  Copyright © 2016 akh. All rights reserved.
//

#import "ViewController.h"
#import "NBGeoDB.h"
#import <MapKit/MapKit.h>

#define FENCE_COUNT 7629


@interface ViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property(nonatomic, strong) GoMobileFence *currentFence;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // add a tap gesture to perform a query into the DB
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(handleGesture:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self.mapView addGestureRecognizer:tap];
    
    NBGeoDB *db = [NBGeoDB sharedGeoDB];
    
}

- (void)randomFence {
    // find a random fence in the DB
    int fenceId = arc4random_uniform(FENCE_COUNT);
    NBGeoDB *db = [NBGeoDB sharedGeoDB];
    GoMobileFence *fence = [db.gf fenceByID:fenceId];
    self.currentFence = fence;
}

- (void) displayRegion {
    // clear the map
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    
    // Get the GeoJSON
    NSData *json =  [self.currentFence.geoJSON dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSArray *poly = [[NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingAllowFragments error:&error] objectForKey:@"features"];
    if (error != nil) {
        NSLog(@"ERROR JSON %@", [error localizedDescription]);
        return;
    }
    
    NSDictionary *geometry = poly[0][@"geometry"];
    NSArray *coordinates = geometry[@"coordinates"][0];
    
    
    // find the min max to zoom on the right region
    CLLocationCoordinate2D *coords = malloc(sizeof(CLLocationCoordinate2D) * [coordinates count]);
    
    double latmin = 180;
    double lngmin = 180;
    double latmax = -180;
    double lngmax = -180;
    
    for(int idx = 0; idx < [coordinates count]; idx++) {
        NSArray *pair = [coordinates objectAtIndex:idx];
        coords[idx] = CLLocationCoordinate2DMake([pair[1] doubleValue], [pair[0] doubleValue]);
        
        latmin = MIN(latmin, [pair[1] doubleValue]);
        latmax = MAX(latmax, [pair[1] doubleValue]);
        
        lngmin = MIN(lngmin, [pair[0] doubleValue]);
        lngmax = MAX(lngmax, [pair[0] doubleValue]);
    }
    
    // create the polygon shape
    MKPolygon *overlayPolygon = [MKPolygon polygonWithCoordinates:coords count:[coordinates count]];
    overlayPolygon.title = self.currentFence.name;
    free(coords);
    [self.mapView addOverlay:overlayPolygon];
    
    NSArray *pair = [coordinates objectAtIndex:0];
    
    // add an annotation
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = CLLocationCoordinate2DMake([pair[1] doubleValue], [pair[0] doubleValue]);
    annotation.title = self.currentFence.name;
    annotation.subtitle = self.currentFence.iso;
    [self.mapView addAnnotation:annotation];
    
    // center on the region
    double centerLat = latmin + (latmax - latmin) / 2;
    double centerLng = lngmin + (lngmax - lngmin) / 2;
    MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(centerLat, centerLng), MKCoordinateSpanMake((latmax-latmin)*1.5, (lngmax-lngmin)*1.5));
    
    [self.mapView setRegion:region];
    dispatch_async(dispatch_get_main_queue(),^{
        [self.mapView selectAnnotation:annotation animated:NO];
    });
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    // render the polygon
    MKPolygonRenderer *polyRenderer = [[MKPolygonRenderer alloc] initWithPolygon:overlay];
    
    polyRenderer.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
    polyRenderer.strokeColor = [UIColor blueColor];
    polyRenderer.lineWidth = 3;
    return polyRenderer;
}

- (IBAction)nextButton:(id)sender {
    [self randomFence];
    [self displayRegion];
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer {
    // handle the one tap gesture
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded)
        return;
    
    // convert the screen tap to map coordinates
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D c =
    [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    // query the database
    NBGeoDB *db = [NBGeoDB sharedGeoDB];
    GoMobileFence *fence = [db.gf queryHandler:c.latitude lng:c.longitude];
    self.currentFence = fence;
    if (self.currentFence != nil) {
        [self displayRegion];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"myannotation";

    MKAnnotationView *annotationView = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (annotationView == nil) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        annotationView.canShowCallout = YES;
    } else {
        annotationView.annotation = annotation;
    }
    
    return annotationView;
}

@end

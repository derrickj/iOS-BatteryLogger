//
//  DJViewController.m
//  BatteryLevelLogger
//
//  Created by Derrick Jones on 5/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DJViewController.h"

@interface DJViewController ()

@end

@implementation DJViewController

@synthesize batteryLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batterStateDidChange:) name:UIDeviceBatteryStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryLevelDidChange:) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    
    batteryLabel.text =[NSString stringWithFormat:@"%.1f%%", [[UIDevice currentDevice] batteryLevel] * 100];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Interface Builder Actions
- (IBAction)didAskToDumpData:(id)sender {
    // not checking anything cause only 1 button
    NSString *s = [self contentsOfLog];
    NSLog(@"data: %@", s);
}

#pragma mark - Battery Level Monitoring
- (void) batteryStateDidChange:(NSNotification *)notification {
    NSLog(@"battery changed: %@", notification);
}
- (void) batteryLevelDidChange:(NSNotification *)notification {
    float currentLevel = [[UIDevice currentDevice] batteryLevel];
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    NSString *logMsg = [NSString stringWithFormat:@"%f,%f", timestamp, currentLevel];
    [self updateLogWithString:logMsg];
    self.batteryLabel.text = [NSString stringWithFormat:@"%.2f", currentLevel];
    NSLog(@"battery level changed %@", notification);
}

#pragma mark - I/O
// CSV with utc timestamp, and battery as 0-1 float
+ (NSFileHandle *)logFileHandle {
    NSArray *directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [directories objectAtIndex:0];
    NSString *logFilePath = [docDir stringByAppendingPathComponent:@"battery-log.txt"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:logFilePath] == NO) {
        [[NSFileManager defaultManager] createFileAtPath:logFilePath contents:nil attributes:nil];
    }
    NSFileHandle *fh = [NSFileHandle fileHandleForUpdatingAtPath:logFilePath];
    return [[fh retain] autorelease];
}

- (void)updateLogWithString:(NSString *)msg {
    NSFileHandle *fileHandle = [DJViewController logFileHandle];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[[msg stringByAppendingString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandle closeFile];
}
- (NSString *)contentsOfLog {
    NSFileHandle *fileHandle = [DJViewController logFileHandle];
    NSData *data = [fileHandle readDataToEndOfFile];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return [string autorelease];
}

@end

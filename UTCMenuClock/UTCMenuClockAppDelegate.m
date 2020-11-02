//
// UTCMenuClockAppDelegate.m
// UTCMenuClock
//
// Created by John Adams on 11/14/11.
//
// Copyright 2011-2016 John Adams
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "UTCMenuClockAppDelegate.h"
#import "LaunchAtLoginController.h"

static NSString *const showDatePreferenceKey = @"ShowDate";
static NSString *const showSecondsPreferenceKey = @"ShowSeconds";
static NSString *const showJulianDatePreferenceKey = @"ShowJulianDate";
static NSString *const showTimeZonePreferenceKey = @"ShowTimeZone";
static NSString *const show24HourPreferenceKey = @"24HRTime";

@implementation UTCMenuClockAppDelegate

@synthesize window;
@synthesize mainMenu;

NSStatusItem *ourStatus;
NSMenuItem *dateMenuItem;
NSMenuItem *showTimeZoneItem;
NSMenuItem *show24HrTimeItem;

- (void) quitProgram:(id)sender {
    // Cleanup here if necessary...
    [[NSApplication sharedApplication] terminate:nil];
}

- (void) toggleLaunch:(id)sender {
    NSInteger state = [sender state];
    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];

    if (state == NSControlStateValueOff) {
        [sender setState:NSControlStateValueOn];
        [launchController setLaunchAtLogin:YES];
    } else {
        [sender setState:NSControlStateValueOff];
        [launchController setLaunchAtLogin:NO];
    }

    [launchController release];
}

- (BOOL) fetchBooleanPreference:(NSString *)preference {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    BOOL value = [standardUserDefaults boolForKey:preference];
    return value;
}

- (void) togglePreference:(id)sender {
    NSInteger state = [sender state];
    NSString *preference = [sender representedObject];
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];

    if (state == NSControlStateValueOff) {
        [sender setState:NSControlStateValueOn];
        [standardUserDefaults setBool:TRUE forKey:preference];
    } else {
        [sender setState:NSControlStateValueOff];
        [standardUserDefaults setBool:FALSE forKey:preference];
    }

}

- (void) openGithubURL:(id)sender {
    [[NSWorkspace sharedWorkspace]
        openURL:[NSURL URLWithString:@"http://github.com/netik/UTCMenuClock"]];
}


- (void) doDateUpdate {

    NSDate* date = [NSDate date];
    NSDateFormatter* UTCdf = [[[NSDateFormatter alloc] init] autorelease];
    NSDateFormatter* UTCdateDF = [[[NSDateFormatter alloc] init] autorelease];
    NSDateFormatter* UTCdateShortDF = [[[NSDateFormatter alloc] init] autorelease];
    NSDateFormatter* UTCdaynum = [[[NSDateFormatter alloc] init] autorelease];
    
    NSTimeZone* UTCtz = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];

    [UTCdf setTimeZone: UTCtz];
    [UTCdateDF setTimeZone: UTCtz];
    [UTCdateShortDF setTimeZone: UTCtz];
    [UTCdaynum setTimeZone: UTCtz];

    BOOL showDate = [self fetchBooleanPreference:showDatePreferenceKey];
    BOOL showSeconds = [self fetchBooleanPreference:showSecondsPreferenceKey];
    BOOL showJulian = [self fetchBooleanPreference:showJulianDatePreferenceKey];
    BOOL showTimeZone = [self fetchBooleanPreference:showTimeZonePreferenceKey];
    BOOL show24HrTime = [self fetchBooleanPreference:show24HourPreferenceKey];
    
    if (showSeconds) {
        if (show24HrTime){
            [UTCdf setDateFormat: @"HH:mm:ss"];
        } else {
            [UTCdf setDateFormat: @"hh:mm:ss a"];
        }
    } else {
        if (show24HrTime){
            [UTCdf setDateFormat: @"HH:mm"];
        } else {
            [UTCdf setDateFormat: @"hh:mm a"];
        }
    }
    [UTCdateDF setDateStyle:NSDateFormatterFullStyle];
    [UTCdateShortDF setDateStyle:NSDateFormatterShortStyle];
    [UTCdaynum setDateFormat:@"D/"];

    NSString* UTCtimepart = [UTCdf stringFromDate: date];
    NSString* UTCdatepart = [UTCdateDF stringFromDate: date];
    NSString* UTCdateShort = [UTCdateShortDF stringFromDate: date];
    NSString* UTCJulianDay;
    NSString* UTCTzString;
    
    
    if (showJulian) { 
        UTCJulianDay = [UTCdaynum stringFromDate: date];
    } else { 
        UTCJulianDay = @"";
    }
    
    if (showTimeZone) { 
        UTCTzString = @" UTC";
    } else { 
        UTCTzString = @"";
    }

    if (showDate) {
        [ourStatus setTitle:[NSString stringWithFormat:@"%@ %@%@%@", UTCdateShort, UTCJulianDay, UTCtimepart, UTCTzString]];
    } else {
        [ourStatus setTitle:[NSString stringWithFormat:@"%@%@%@", UTCJulianDay, UTCtimepart, UTCTzString]];
    }

    [dateMenuItem setTitle:UTCdatepart];

}

- (IBAction)showFontMenu:(id)sender {
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    [fontManager setDelegate:self];
    
    NSFontPanel *fontPanel = [fontManager fontPanel:YES];
    [fontPanel makeKeyAndOrderFront:sender];
}
// this is the main work loop, fired on 1s intervals.
- (void) fireTimer:(NSTimer*)theTimer {
    [self doDateUpdate];
}

- (id)init {
    if (self = [super init]) {
        // set our default preferences at each launch.
        
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *appDefaults = @{showTimeZonePreferenceKey: @YES,
                                      show24HourPreferenceKey: @YES,
                                      showJulianDatePreferenceKey: @NO,
                                      showDatePreferenceKey: @NO,
                                      showSecondsPreferenceKey: @NO};
        [standardUserDefaults registerDefaults:appDefaults];
        NSString *dateKey    = @"dateKey";
        //Remove old, outdated date key
        [standardUserDefaults removeObjectForKey:dateKey];
    }
    return self;
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    [self doDateUpdate];

}

- (void)awakeFromNib
{
    mainMenu = [[NSMenu alloc] init];

    //Create Image for menu item
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    NSStatusItem *theItem;
    theItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    [theItem retain];
    // retain a reference to the item so we don't have to find it again
    ourStatus = theItem;

    //Set Image
    //[theItem setImage:(NSImage *)menuicon];
    [theItem setTitle:@""];

    //Make it turn blue when you click on it
    [theItem setHighlightMode:YES];
    [theItem setEnabled: YES];

    // build the menu
    NSMenuItem *mainItem = [[NSMenuItem alloc] init];
    dateMenuItem = mainItem;

    NSMenuItem *cp1Item = [[[NSMenuItem alloc] init] autorelease];
    NSMenuItem *cp2Item = [[[NSMenuItem alloc] init] autorelease];
    NSMenuItem *cp3Item = [[[NSMenuItem alloc] init] autorelease];
    NSMenuItem *quitItem = [[[NSMenuItem alloc] init] autorelease];
    NSMenuItem *launchItem = [[[NSMenuItem alloc] init] autorelease];
    NSMenuItem *showDateItem = [[[NSMenuItem alloc] init] autorelease];
    NSMenuItem *show24Item = [[[NSMenuItem alloc] init] autorelease];
    NSMenuItem *showSecondsItem = [[[NSMenuItem alloc] init] autorelease];
    NSMenuItem *showJulianItem = [[[NSMenuItem alloc] init] autorelease];
 //   NSMenuItem *changeFontItem = [[[NSMenuItem alloc] init] autorelease];
    
    showTimeZoneItem = [[[NSMenuItem alloc] init] autorelease];
    NSMenuItem *sep1Item = [NSMenuItem separatorItem];
    NSMenuItem *sep2Item = [NSMenuItem separatorItem];
    NSMenuItem *sep3Item = [NSMenuItem separatorItem];
    NSMenuItem *sep4Item = [NSMenuItem separatorItem];
    
    [mainItem setTitle:@""];

    [cp1Item setTitle:@"UTC Menu Clock v1.2.3"];
    [cp2Item setTitle:@"jna@retina.net"];
    [cp3Item setTitle:@"http://github.com/netik/UTCMenuClock"];

    [cp3Item setEnabled:TRUE];
    [cp3Item setAction:@selector(openGithubURL:)];

    [launchItem setTitle:@"Open at Login"];
    [launchItem setEnabled:TRUE];
    [launchItem setAction:@selector(toggleLaunch:)];

    [show24Item setTitle:@"24 HR Time"];
    [show24Item setEnabled:TRUE];
    [show24Item setAction:@selector(togglePreference:)];
    [show24Item setRepresentedObject:show24HourPreferenceKey];
    
    [showDateItem setTitle:@"Show Date"];
    [showDateItem setEnabled:TRUE];
    [showDateItem setAction:@selector(togglePreference:)];
    [showDateItem setRepresentedObject:showDatePreferenceKey];

    [showSecondsItem setTitle:@"Show Seconds"];
    [showSecondsItem setEnabled:TRUE];
    [showSecondsItem setAction:@selector(togglePreference:)];
    [showSecondsItem setRepresentedObject:showSecondsPreferenceKey];
    
    [showJulianItem setTitle:@"Show Julian Date"];
    [showJulianItem setEnabled:TRUE];
    [showJulianItem setAction:@selector(togglePreference:)];
    [showJulianItem setRepresentedObject:showJulianDatePreferenceKey];

    [showTimeZoneItem setTitle:@"Show Time Zone"];
    [showTimeZoneItem setEnabled:TRUE];
    [showTimeZoneItem setAction:@selector(togglePreference:)];
    [showTimeZoneItem setRepresentedObject:showTimeZonePreferenceKey];
    
 //   [changeFontItem setTitle:@"Change Font..."];
  //  [changeFontItem setAction:@selector(showFontMenu:)];
    
    [quitItem setTitle:@"Quit"];
    [quitItem setEnabled:TRUE];
    [quitItem setAction:@selector(quitProgram:)];

    [mainMenu addItem:mainItem];
    // "---"
    [mainMenu addItem:sep2Item];
    // "---"
    [mainMenu addItem:cp1Item];
    [mainMenu addItem:cp2Item];
    // "---"
    [mainMenu addItem:sep1Item];
    [mainMenu addItem:cp3Item];
    // "---"
    [mainMenu addItem:sep3Item];

    // showDateItem
    BOOL showDate = [self fetchBooleanPreference:showDatePreferenceKey];
    BOOL showSeconds = [self fetchBooleanPreference:showSecondsPreferenceKey];
    BOOL showJulian = [self fetchBooleanPreference:showJulianDatePreferenceKey];
    BOOL showTimeZone = [self fetchBooleanPreference:showTimeZonePreferenceKey];
    BOOL show24HrTime = [self fetchBooleanPreference:show24HourPreferenceKey];
    
    // TODO: DRY this up a bit.
    
    if (show24HrTime) {
        [show24Item setState:NSOnState];
    } else {
        [show24Item setState:NSOffState];
    }
    
    if (showDate) {
        [showDateItem setState:NSOnState];
    } else {
        [showDateItem setState:NSOffState];
    }

    if (showSeconds) {
        [showSecondsItem setState:NSOnState];
    } else {
        [showSecondsItem setState:NSOffState];
    }

    if (showJulian) {
        [showJulianItem setState:NSOnState];
    } else {
        [showJulianItem setState:NSOffState];
    }
    
    if (showTimeZone) {
        [showTimeZoneItem setState:NSOnState];
    } else {
        [showTimeZoneItem setState:NSOffState];
    }
    
    // latsly, deal with Launch at Login
    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
    BOOL launch = [launchController launchAtLogin];
    [launchController release];

    if (launch) {
        [launchItem setState:NSOnState];
    } else {
        [launchItem setState:NSOffState];
    }

    [mainMenu addItem:launchItem];
    [mainMenu addItem:show24Item];
    [mainMenu addItem:showDateItem];
    [mainMenu addItem:showSecondsItem];
    [mainMenu addItem:showJulianItem];
    [mainMenu addItem:showTimeZoneItem];
  //  [mainMenu addItem:changeFontItem];
    // "---"
    [mainMenu addItem:sep4Item];
    [mainMenu addItem:quitItem];

    [theItem setMenu:(NSMenu *)mainMenu];

    // Update the date immediately after setup so that there is no timer lag
    [self doDateUpdate];

    NSNumber *myInt = [NSNumber numberWithInt:1];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(fireTimer:) userInfo:myInt repeats:YES];


}

@end

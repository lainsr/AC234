//
//  ACSettingsViewController.m
//  AC234
//
//  Created by Stéphane Rossé on 05.09.12.
//
//
#import "HTTPServer.h"
#import "ACAppDelegate.h"
#import "ACGlobalInfos.h"
#import "ACToggleSwitchCell.h"
#import "ACSettingsViewController.h"

@implementation ACSettingsViewController

static NSString *kSwitchCellIdentifier = @"MySwitchCellIdentifier";
static NSString *kDetailsCellIdentifier = @"DetailsCellIdentifier";

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - ACSettingsCellDelegate
-(void)valueChanged {
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int sectionIndex = [indexPath indexAtPosition:0];
    if(sectionIndex == 0) {
        [self performSegueWithIdentifier:@"PasswordSettingsSegue" sender:self];
    } else if(sectionIndex == 1) {
        [self performSegueWithIdentifier:@"ThumbnailSettingsSegue" sender:self];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int sectionIndex = [indexPath indexAtPosition:0];
    if(sectionIndex == 2) {
        return nil;
    }
    return indexPath;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: return NSLocalizedString(@"Security",@"");
        case 1: return NSLocalizedString(@"Thumbnails",@"");
        case 2: return NSLocalizedString(@"Servers",@"");
        default: return NULL;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if(section == 2) {
        ACAppDelegate *appDelegate = (ACAppDelegate*)[[UIApplication sharedApplication] delegate];
        if([appDelegate webdavServer] && [appDelegate.webdavServer isRunning]) {
            HTTPServer *server = [appDelegate webdavServer];
			NSMutableString *message = [NSMutableString stringWithCapacity:32];
			[message appendString:@"http://"];
            [message appendString:[appDelegate getAddress]];
			[message appendString:@":"];
            [message appendFormat:@"%i",[server listeningPort]];
            return message;
        }
    }
    return NULL;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    int sectionIndex = [indexPath indexAtPosition:0];
    UITableViewCell *cell;
    if (sectionIndex == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:kDetailsCellIdentifier];
        [cell.textLabel setText:NSLocalizedString(@"Password",@"")];
        if([[ACGlobalInfos sharedInstance] isPasswordActivated]) {
            [cell.detailTextLabel setText:NSLocalizedString(@"Active",@"")];
        } else {
            [cell.detailTextLabel setText:NSLocalizedString(@"Inactive",@"")];
        }
    } else if(sectionIndex == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:kDetailsCellIdentifier];
        [cell.textLabel setText:NSLocalizedString(@"Thumbnails",@"")];
        [cell.detailTextLabel setText:@""];
    } else if(sectionIndex == 2) {
        ACToggleSwitchCell *toggleCell = (ACToggleSwitchCell*)[tableView dequeueReusableCellWithIdentifier:kSwitchCellIdentifier];
        if(toggleCell == nil) {
            toggleCell = [[ACToggleSwitchCell alloc] initWithReuseIdentifier:kSwitchCellIdentifier];
        }
        [toggleCell.textLabel setText:NSLocalizedString(@"ServerHTTPWebDAV",@"")];
        [toggleCell setDelegate:self];
        
        ACAppDelegate *appDelegate = (ACAppDelegate*)[[UIApplication sharedApplication] delegate];
        if([appDelegate webdavServer] && [appDelegate.webdavServer isRunning]) {
            [toggleCell setValue:[NSNumber numberWithBool:YES]];
        } else {
            NSLog(@"Egg");
        }
        cell = toggleCell;
    }
    return cell;
}

@end
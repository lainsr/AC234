//
//  ACSettingsViewController.m
//  AC234
//
//  Created by Stéphane Rossé on 05.09.12.
//
//

#import "ACGlobalInfos.h"
#import "ACToggleSwitchCell.h"
#import "ACSettingsViewController.h"

@interface ACSettingsViewController ()

@end

@implementation ACSettingsViewController


static NSString *kSwitchCellIdentifier = @"MySwitchCellIdentifier";
static NSString *kDetailsCellIdentifier = @"DetailsCellIdentifier";


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark .
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int sectionIndex = [indexPath indexAtPosition:0];
    if(sectionIndex == 0) {
        [self performSegueWithIdentifier:@"PasswordSettingsSegue" sender:self];
    } else if(sectionIndex == 1) {
        [self performSegueWithIdentifier:@"ThumbnailSettingsSegue" sender:self];
    }
}

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 1;
        case 1: return 1;
        case 2: return 2;
        default: return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: return @"Password";
        case 1: return @"Thumbnails";
        case 2: return @"Servers";
        default: return NULL;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if(section == 2) {
        return @"http://191.168.1.110:8080/ac234";
    }
    return NULL;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    int sectionIndex = [indexPath indexAtPosition:0];
    int rowIndex = [indexPath indexAtPosition:1];
    UITableViewCell *cell;
    if (sectionIndex == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:kDetailsCellIdentifier];
        [cell.textLabel setText:@"Password"];
        if([[ACGlobalInfos sharedInstance] isPasswordActivated]) {
            [cell.detailTextLabel setText:@"Active"];
        } else {
            [cell.detailTextLabel setText:@"Inactive"];
        }
    } else if(sectionIndex == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:kDetailsCellIdentifier];
        [cell.textLabel setText:@"Thumbnail"];
        [cell.detailTextLabel setText:@""];
    } else if(sectionIndex == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:kSwitchCellIdentifier];
        if(cell == nil) {
            cell = [[ACToggleSwitchCell alloc] initWithReuseIdentifier:kSwitchCellIdentifier];
        }
        if(rowIndex == 0) {
            [cell.textLabel setText:@"FTP"];
        } else if(rowIndex == 1) {
            [cell.textLabel setText:@"HTTP / WebDAV"];
        }
    }
    return cell;
}



@end

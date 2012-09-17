//
//  ACThumbnailSettingsViewController.m
//  AC234
//
//  Created by Stéphane Rossé on 14.09.12.
//
//

#import "ACThumbnailSettingsViewController.h"

@implementation ACThumbnailSettingsViewController

static NSString *kCellIdentifier = @"MyCellIdentifier";

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    int sectionIndex = [indexPath indexAtPosition:0];
    if(sectionIndex == 0) {
        [cell.textLabel setText:@"Complete"];
    } else {
        [cell.textLabel setText:@"Delete"];
    }
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    NSLog(@"Make something thumbnail related");
}

@end

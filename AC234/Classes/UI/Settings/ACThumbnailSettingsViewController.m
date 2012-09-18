//
//  ACThumbnailSettingsViewController.m
//  AC234
//
//  Created by Stéphane Rossé on 14.09.12.
//
//

#import "ACAppDelegate.h"
#import "ACProgressBarController.h"
#import "ACUpdateThumbnailsOperation.h"
#import "ACThumbnailSettingsViewController.h"

@implementation ACThumbnailSettingsViewController

@synthesize progressBarController;

static NSString *kCellIdentifier = @"MyCellIdentifier";

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *destinationController = [segue destinationViewController];
    if([destinationController isKindOfClass: [ACProgressBarController class]]) {
        progressBarController = (ACProgressBarController *)destinationController;
    }
}

#pragma mark - ACUpdateThumbnailsOperationDelegate
- (void)updateThumbnailsProgress:(ACUpdateInfos *)infos {
	[self performSelectorOnMainThread:@selector(updateThumbnailsInDocumentsProgress:) withObject:infos waitUntilDone:NO];
}

- (void)operationFinished:(id)op {
	[self performSelectorOnMainThread:@selector(updateThumbnailsInDocumentsEnded) withObject:nil waitUntilDone:NO];
}

- (void)updateThumbnailsInDocumentsEnded {
    if(self.progressBarController != NULL) {
        [self.progressBarController.progressView setProgress:1.0];
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (void)updateThumbnailsInDocumentsProgress:(ACUpdateInfos *)infos {
    if([self progressBarController] != NULL) {
        [progressBarController.progressView setProgress:[infos progress]];
        NSString *filename = [infos.path lastPathComponent];
        [progressBarController.filenameLabel setText:filename];
        [progressBarController.progressView setNeedsLayout];
    }
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
	int section = [indexPath section];
	if(section == 0 || section == 1) {
		ACUpdateThumbnailsOperation	*updateOp = [[ACUpdateThumbnailsOperation alloc] init];
		[updateOp setDelegate:self];		// set the delegate
		[updateOp setReset:(section == 1)];
        
		ACAppDelegate *appDelegate = (ACAppDelegate *)[[UIApplication sharedApplication] delegate];
		[[appDelegate thumbnailQueue] addOperation:updateOp];
        
        [self performSegueWithIdentifier:@"ThumbnailProgressSegue" sender:updateOp];
	}
}

@end

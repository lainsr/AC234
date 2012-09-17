//
//  ACPasswordSettingsViewController.m
//  AC234
//
//  Created by Stéphane Rossé on 14.09.12.
//
//

#import "ACGlobalInfos.h"
#import "ACPasswordController.h"
#import "ACPasswordSettingsViewController.h"

#import "KeychainItemWrapper.h"

@implementation ACPasswordSettingsViewController

static NSString *kCellIdentifier = @"MyCellIdentifier";


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *destinationController = [segue destinationViewController];
    if([destinationController isKindOfClass: [ACPasswordController class]]) {
        ACPasswordController *passwordController = (ACPasswordController *)destinationController;
        [passwordController setPasswordDelegate:self];
    }
}

-(BOOL)passwordSet:(NSString *)password {
    if(activate) {
		KeychainItemWrapper *keychainActivationWrapper = [[ACGlobalInfos sharedInstance] keychainActivationWrapper];
		if([[ACGlobalInfos sharedInstance] isPasswordActivated]) {
			[keychainActivationWrapper setObject:@"NO" forKey:(__bridge_transfer id)kSecValueData];
		} else {
			[keychainActivationWrapper setObject:@"YES" forKey:(__bridge_transfer id)kSecValueData];
			
			//save password
			KeychainItemWrapper *keychainPasswordWrapper = [[ACGlobalInfos sharedInstance] keychainPasswordWrapper];
			[keychainPasswordWrapper setObject:@"AC234" forKey:(__bridge_transfer id)kSecAttrAccount];
			[keychainPasswordWrapper setObject:password forKey:(__bridge_transfer id)kSecValueData];
		}
	} else {
		KeychainItemWrapper *keychainPasswordWrapper = [[ACGlobalInfos sharedInstance] keychainPasswordWrapper];
		[keychainPasswordWrapper setObject:@"AC234" forKey:(__bridge_transfer id)kSecAttrAccount];
		[keychainPasswordWrapper setObject:password forKey:(__bridge_transfer id)kSecValueData];
	}
	[self.tableView reloadData];
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
        [cell.textLabel setText:@"Activate"];
    } else {
        [cell.textLabel setText:@"Change password"];
    }
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"DeactivatePasswordSegue" sender:self];
}

@end

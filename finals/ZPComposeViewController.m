//
//  ZPComposeViewController.m
//  finals
//
//  Created by Ziyad Parekh on 12/25/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "ZPComposeViewController.h"
#import <VENTokenField/VENTokenField.h>
#import <Parse/Parse.h>
#import "ZPConstants.h"
#import "ZPUserTableViewCell.h"
#import "UIColor+ZPColors.h"

@interface ZPComposeViewController () <VENTokenFieldDelegate, VENTokenFieldDataSource, UITableViewDataSource, UITableViewDelegate, ZPUserTableViewCellDelegate>
@property (strong, nonatomic) IBOutlet VENTokenField *tokenField;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *names;
@property (strong, nonatomic) NSMutableArray *selectedNames;
@end

@implementation ZPComposeViewController
@synthesize tokenField;
@synthesize tableView;
@synthesize selectedNames;
@synthesize names;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.names = [NSMutableArray array];
    self.selectedNames = [NSMutableArray array];
    
    self.tokenField = [[VENTokenField alloc] initWithFrame:CGRectMake(0.0f, self.navigationController.navigationBar.frame.size.height + 20.0f, self.view.bounds.size.width, 42.0f)];
    self.tokenField.delegate = self;
    self.tokenField.dataSource = self;
    self.tokenField.placeholderText = NSLocalizedString(@"Enter names here", nil);
    self.tokenField.toLabelText = NSLocalizedString(@"Post to:", nil);
    [self.tokenField setColorScheme:[UIColor colorWithRed:61/255.0f green:149/255.0f blue:206/255.0f alpha:1.0f]];
    self.tokenField.layer.borderColor = [UIColor zp_lightGreyColor].CGColor;
    self.tokenField.layer.borderWidth = 0.5f;
    self.tokenField.delimiters = @[@",", @";", @"--"];
    [self.tokenField becomeFirstResponder];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, self.navigationController.navigationBar.frame.size.height + 62.0f, self.view.bounds.size.width, self.view.bounds.size.height - self.navigationController.navigationBar.frame.size.height + 62.0f)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
//    [self.view addGestureRecognizer:tap];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.tokenField];
    [self.view addSubview:self.tableView];
    
    [self.navigationItem setHidesBackButton:YES];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Publish" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonAction:)];
}

- (void)cancelButtonAction:(id)sender {
    [self resignFirstResponder];
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneButtonAction:(id)sender {
    [self cancelButtonAction:self];
}

-(void)dismissKeyboard {
    [self.tokenField resignFirstResponder];
    self.tableView.hidden = YES;
}

#pragma mark - VENTokenFieldDelegate

- (void)tokenField:(VENTokenField *)tokenField didEnterText:(NSString *)text
{
    return;
}

- (void)tokenField:(VENTokenField *)tokenField didDeleteTokenAtIndex:(NSUInteger)index
{
    [self.selectedNames removeObjectAtIndex:index];
    [self.tokenField reloadData];
}

- (void)tokenFieldDidBeginEditing:(VENTokenField * __nonnull)tokenField {
    //self.tableView.hidden = NO;
}

- (void)tokenField:(VENTokenField * __nonnull)tokenField didChangeText:(nullable NSString *)text {
    
    if ([text length] == 0) {
        return;
    }
    self.tableView.frame = CGRectMake(0.0f, self.navigationController.navigationBar.frame.size.height + 20.0f + self.tokenField.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height - (self.navigationController.navigationBar.frame.size.height + 20.0f + self.tokenField.bounds.size.height));
    self.tableView.hidden = NO;
    
    PFQuery *searchQuery = [PFQuery queryWithClassName:kZPUserClass];
    [searchQuery whereKey:kZPUserLowercaseNameKey containsString:[text lowercaseString]];
    [searchQuery whereKey:kZPUserIdKey notEqualTo:[[PFUser currentUser] objectId]];
    searchQuery.limit = 50;
    
    [searchQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"%@", objects);
            // The find succeeded.
            // Do something with the found objects
            [self.names removeAllObjects];
            for (PFObject *object in objects) {
                [self.names addObject:object];
            }
            [self.tableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    
    }];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.names.count) {
        return [ZPUserTableViewCell heightForCell];
    } else {
        return 44.0f;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.names.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *FriendCellIdentifier = @"FriendCell";
    
    ZPUserTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:FriendCellIdentifier];
    if (cell == nil) {
        cell = [[ZPUserTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FriendCellIdentifier];
        [cell setDelegate:self];
    }
    
    PFObject *object = [self.names objectAtIndex:indexPath.row];
    [cell setUser:(PFUser*)object];
    [cell.photoLabel setText:@"0 photos"];
    cell.tag = indexPath.row;
    
    if ([self.selectedNames containsObject:[object objectForKey:kZPUserDisplayNameKey]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;

}

#pragma mark - ZPUserTableViewCellDelegate

- (void)cell:(ZPUserTableViewCell *)cellView didTapUserButton:(PFUser *)aUser {
    [self updateTokenViewWithNewData:aUser];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *object = [self.names objectAtIndex:indexPath.row];
    [self updateTokenViewWithNewData:(PFUser *)object];
}

- (void)updateTokenViewWithNewData:(PFUser *)aUser {
    if ([self.selectedNames containsObject:[aUser objectForKey:kZPUserDisplayNameKey]]) {
        [self.selectedNames removeObject:[aUser objectForKey:kZPUserDisplayNameKey]];
    } else {
        [self.selectedNames addObject:[aUser objectForKey:kZPUserDisplayNameKey]];
    }
    self.tableView.hidden = YES;
    [self.tokenField reloadData];
}

#pragma mark - VENTokenFieldDataSource

- (NSString *)tokenField:(VENTokenField *)tokenField titleForTokenAtIndex:(NSUInteger)index
{
    return self.selectedNames[index];
}

- (NSUInteger)numberOfTokensInTokenField:(VENTokenField *)tokenField
{
    return [self.selectedNames count];
}

- (NSString *)tokenFieldCollapsedText:(VENTokenField *)tokenField
{
    return [NSString stringWithFormat:@"%tu people", [self.selectedNames count]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

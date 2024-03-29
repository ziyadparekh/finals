//
//  ZPComposeViewController.m
//  finals
//
//  Created by Ziyad Parekh on 12/25/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "ZPComposeViewController.h"
#import <VENTokenField/VENTokenField.h>
#import <VENCalculatorInputView/VENCalculatorInputTextField.h>
#import "ZPConstants.h"
#import "ZPUtility.h"
#import "ZPUserTableViewCell.h"
#import "UIColor+ZPColors.h"
#import <UITextView+Placeholder/UITextView+Placeholder.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface ZPComposeViewController () <VENTokenFieldDelegate, VENTokenFieldDataSource, UITableViewDataSource, UITableViewDelegate, ZPUserTableViewCellDelegate, UITextViewDelegate, VENCalculatorInputViewDelegate, UITextFieldDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet VENTokenField *tokenField;
@property (strong, nonatomic) IBOutlet VENCalculatorInputTextField *calcInputTextField;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *accessoryView;
@property (strong, nonatomic) IBOutlet UIButton *payButtonView;
@property (strong, nonatomic) IBOutlet UIButton *confirmButtonView;
@property (strong, nonatomic) IBOutlet UITextView *noteTextView;
@property (strong, nonatomic) NSMutableArray *names;
@property (strong, nonatomic) NSMutableArray *selectedNames;
@property (assign, nonatomic) float keyboardHeight;
@property (assign, nonatomic) NSUInteger totalAmount;
@property (assign, nonatomic) NSUInteger _expectedTransactionsCount;
@property (assign, nonatomic) NSUInteger _processedTransactionsCount;
@property (strong, nonatomic) PFUser *initialUser;

@end

@implementation ZPComposeViewController
@synthesize initialUser;
@synthesize tokenField;
@synthesize calcInputTextField;
@synthesize tableView;
@synthesize accessoryView;
@synthesize payButtonView;
@synthesize confirmButtonView;
@synthesize selectedNames;
@synthesize noteTextView;
@synthesize names;
@synthesize keyboardHeight;
@synthesize _expectedTransactionsCount;
@synthesize _processedTransactionsCount;


- (id)initWithUser:(PFUser *)aUser {
    self = [super init];
    if (self) {
        self.initialUser = aUser;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.names = [NSMutableArray array];
    self.selectedNames = [NSMutableArray array];
    self.keyboardHeight = 253.0f;
    
    [self createAccessoryView];
    
    self.tokenField = [[VENTokenField alloc] initWithFrame:CGRectMake(0.0f, self.navigationController.navigationBar.frame.size.height + 20.0f, self.view.bounds.size.width, 42.0f)];
    self.tokenField.delegate = self;
    self.tokenField.dataSource = self;
    self.tokenField.placeholderText = NSLocalizedString(@"Enter names here", nil);
    self.tokenField.toLabelText = nil;
    [self.tokenField setColorScheme:[UIColor colorWithRed:61/255.0f green:149/255.0f blue:206/255.0f alpha:1.0f]];
    self.tokenField.layer.borderColor = [UIColor zp_lightGreyColor].CGColor;
    self.tokenField.layer.borderWidth = 0.5f;
    self.tokenField.delimiters = @[@",", @";", @"--"];
    [self.tokenField becomeFirstResponder];

    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20.0f, 20)];
    
    self.calcInputTextField = [[VENCalculatorInputTextField alloc] initWithFrame: CGRectMake(0.0f, self.navigationController.navigationBar.frame.size.height + 62.0f, self.view.bounds.size.width, 40.0f)];
    self.calcInputTextField.placeholder = @"Rs0.00";
    self.calcInputTextField.font = [UIFont boldSystemFontOfSize:14.0f];
    [self.calcInputTextField setTextAlignment:NSTextAlignmentLeft];
    [self.calcInputTextField setTextColor:[UIColor zp_darkGreyColor]];
    self.calcInputTextField.layer.borderColor = [UIColor zp_lightGreyColor].CGColor;
    self.calcInputTextField.layer.borderWidth = 0.5f;
    self.calcInputTextField.leftView = paddingView;
    self.calcInputTextField.rightView = paddingView;
    self.calcInputTextField.leftViewMode = UITextFieldViewModeAlways;
    self.calcInputTextField.rightViewMode = UITextFieldViewModeAlways;
    self.calcInputTextField.hidden = YES;
    self.calcInputTextField.delegate = self;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, self.navigationController.navigationBar.frame.size.height + 62.0f, self.view.bounds.size.width, self.view.bounds.size.height - self.navigationController.navigationBar.frame.size.height + 62.0f)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.noteTextView = [[UITextView alloc] initWithFrame:CGRectMake(15.0f, self.navigationController.navigationBar.frame.size.height + 102.0f, self.view.bounds.size.width - 30.0f, 100.0f)];
    self.noteTextView.editable = YES;
    self.noteTextView.placeholder = @"What's it for?";
    self.noteTextView.hidden = YES;
    self.noteTextView.delegate = self;
    self.noteTextView.autocorrectionType = UITextAutocorrectionTypeDefault;
    self.noteTextView.inputAccessoryView = self.accessoryView;
    self.noteTextView.font = [UIFont systemFontOfSize:14.0f];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.tokenField];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.noteTextView];
    [self.view addSubview:self.calcInputTextField];
    
    [self.navigationItem setHidesBackButton:YES];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonAction:)];
    self.navigationItem.title = @"Transact";
    
    if (self.initialUser) {
        [self updateTokenViewWithNewData:self.initialUser];
    }
}

- (void)createAccessoryView {
    self.accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 45.0f)];
    [self.accessoryView setBackgroundColor:[UIColor clearColor]];
    
    self.payButtonView = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 45.0f)];
    [self.payButtonView setBackgroundColor:[UIColor zp_venmoBlueColor]];
    [self.payButtonView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.payButtonView setTitle:@"Pay" forState:UIControlStateNormal];
    [self.payButtonView setTitleColor:[UIColor zp_lightGreyColor] forState:UIControlStateHighlighted];
    [self.payButtonView addTarget:self action:@selector(validatePaymentAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.confirmButtonView = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 45.0f)];
    [self.confirmButtonView setBackgroundColor:[UIColor zp_greenColor]];
    [self.confirmButtonView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.confirmButtonView setTitleColor:[UIColor zp_lightGreyColor] forState:UIControlStateHighlighted];
    [self.confirmButtonView addTarget:self action:@selector(submitTransaction:) forControlEvents:UIControlEventTouchUpInside];
    self.confirmButtonView.hidden = YES;
    
    [self.accessoryView addSubview:self.payButtonView];
    [self.accessoryView addSubview:self.confirmButtonView];
    
}

- (IBAction)cancelButtonAction:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneButtonAction:(id)sender {
    [self cancelButtonAction:self];
}

- (void)submitTransaction:(id)sender {
    self.confirmButtonView.enabled = NO;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    UIWindow *tempKeyboardWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    MBProgressHUD *hud=[[MBProgressHUD alloc] initWithWindow:tempKeyboardWindow];
    hud.mode=MBProgressHUDModeIndeterminate;
    [tempKeyboardWindow addSubview:hud];
    [hud show:YES];
    
    //[MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    
    _expectedTransactionsCount = self.selectedNames.count;
    _processedTransactionsCount = 0;
    
    self.totalAmount = [self.calcInputTextField.text floatValue] * self.selectedNames.count;
    
    PFObject *transaction = [PFObject objectWithClassName:kZPTransactionObjectKey];
    [transaction setObject:self.noteTextView.text forKey:kZPTransactionNoteKey];
    [transaction setObject:self.calcInputTextField.text forKey:kZPTransactionAmountKey];
    [transaction setObject:[NSString stringWithFormat:@"%li", (unsigned long)self.totalAmount] forKey:kZPTransactionTotalAmountKey];
    
    __block NSError *errorString = nil;
    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
    dispatch_async(backgroundQueue, ^{
        [ZPUtility submitTransaction:transaction toUsers:self.selectedNames block:^(BOOL succeeded, NSError *error) {
            errorString = error;
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide:YES];
            if (errorString == nil) {
                [self cancelButtonAction:self];
            } else {
                [self presentAlertControllerWithTitle:@"Error" message:@"There was error processing your payment"];
            }
        });
    });
}

- (void)presentAlertControllerWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
        [self cancelButtonAction:self];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)validatePaymentAction:(id)sender {
    if (self.selectedNames.count < 1) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Please select at least one person" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    } else if ([self.calcInputTextField.text floatValue] < 1.0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Please enter an amount greater than Rs0.00" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    } else if ([self.noteTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Please enter a note to go along with your payment" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    } else {
        [self formatConfirmButtonTitle];
    }
}

- (void)formatConfirmButtonTitle {
    NSString *formattedText = @"";
    if (self.selectedNames.count == 1) {
        PFUser *recipient = self.selectedNames[0];
        float amount = [self.calcInputTextField.text floatValue];
        formattedText = [NSString stringWithFormat:@"Pay %@ Rs%.02f", [recipient objectForKey:kZPUserDisplayNameKey], amount];
    } else {
        NSUInteger numberOfRecipients = self.selectedNames.count;
        float amount = [self.calcInputTextField.text floatValue];
        formattedText = [NSString stringWithFormat:@"Pay %lu people Rs%.02f", (unsigned long)numberOfRecipients, amount];
    }
    [self.confirmButtonView setTitle:formattedText forState:UIControlStateNormal];
    self.confirmButtonView.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    self.payButtonView.hidden = YES;
    self.confirmButtonView.hidden = NO;
}

-(void)dismissKeyboard {
    [self.tokenField resignFirstResponder];
    self.tableView.hidden = YES;
    self.noteTextView.hidden = NO;
    self.calcInputTextField.hidden = NO;
}

- (void)dismissTableView:(id)sender {
    self.tableView.hidden = YES;
    self.noteTextView.hidden = NO;
    self.calcInputTextField.hidden = NO;
    [self.tokenField resignFirstResponder];
    [self.tokenField reloadData];
    [self.tokenField collapse];
    [self setRightBarButtonItemToTotalAmount];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return textView.text.length + (text.length - range.length) <= 140;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    textView.inputAccessoryView = nil;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.payButtonView.hidden = NO;
    self.confirmButtonView.hidden = YES;
    self.noteTextView.inputAccessoryView = self.accessoryView;
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self.tokenField collapse];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return textField.text.length + (string.length - range.length) <= 5;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self setRightBarButtonItemToTotalAmount];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.tokenField collapse];
}

#pragma mark - VENTokenFieldDelegate

- (void)tokenField:(VENTokenField *)tokenField didEnterText:(NSString *)text {
    return;
}

- (void)tokenField:(VENTokenField *)tokenField didDeleteTokenAtIndex:(NSUInteger)index {
    [self.selectedNames removeObjectAtIndex:index];
    [self.tokenField reloadData];
}

- (void)tokenFieldDidBeginEditing:(VENTokenField * __nonnull)tokenField {
    self.tableView.frame = CGRectMake(0.0f, self.navigationController.navigationBar.frame.size.height + 20.0f + self.tokenField.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height - (self.navigationController.navigationBar.frame.size.height + 20.0f + self.tokenField.bounds.size.height));
    [self setDismissTableViewButtonIfNeccessary];
    self.tableView.hidden = NO;
    self.noteTextView.hidden = YES;
    self.calcInputTextField.hidden = YES;
}

- (void)setDismissTableViewButtonIfNeccessary {
    if (self.selectedNames.count >= 1 && self.tableView.hidden == NO) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(dismissTableView:)];
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}


- (void)tokenField:(VENTokenField * __nonnull)tokenField didChangeText:(nullable NSString *)text {
    
    if ([text length] == 0) {
        return;
    }
    
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
    cell.tag = indexPath.row;
    
    if ([self doesArray:self.selectedNames ContainItem:[object objectId]]) {
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
    if ([self doesArray:self.selectedNames ContainItem:[aUser objectId]]) {
        [self removeItem:[aUser objectId] FromArray:self.selectedNames];
    } else {
        [self.selectedNames addObject:aUser];
    }
    [self.tokenField reloadData];
    [self.tokenField collapse];

    self.tableView.hidden = YES;
    self.noteTextView.hidden = NO;
    self.calcInputTextField.hidden = NO;
    [self setDismissTableViewButtonIfNeccessary];
}

- (BOOL)doesArray:(NSMutableArray *)array ContainItem:(NSString *)item {
    BOOL contains = NO;
    for (PFObject *user in array) {
        if ([[user objectId] isEqualToString:item]) {
            contains = YES;
            break;
        }
    }
    return contains;
}

- (void)removeItem:(NSString *)item FromArray:(NSMutableArray *)array {
    [self.selectedNames enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PFObject *user, NSUInteger index, BOOL *stop) {
        if ([[user objectId] isEqualToString:item]) {
            [self.selectedNames removeObjectAtIndex:index];
        }
    }];
}

#pragma mark - VENTokenFieldDataSource

- (NSString *)tokenField:(VENTokenField *)tokenField titleForTokenAtIndex:(NSUInteger)index {
    PFUser *object = self.selectedNames[index];
    return [object objectForKey:kZPUserDisplayNameKey];
}

- (NSUInteger)numberOfTokensInTokenField:(VENTokenField *)tokenField {
    [self setRightBarButtonItemToTotalAmount];
    return [self.selectedNames count];
}

- (void)setRightBarButtonItemToTotalAmount {
    if (self.selectedNames.count > 1) {
        float singleAmount = [self.calcInputTextField.text floatValue];
        float totalAmount = singleAmount * self.selectedNames.count;
        NSString* formattedNumber = [NSString stringWithFormat:@"%.02f", totalAmount];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"total: Rs%@", formattedNumber] style:UIBarButtonItemStylePlain target:self action:nil];
        [self.navigationItem.rightBarButtonItem setTintColor:[UIColor zp_lightGreyColor]];
        [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14.0]} forState:UIControlStateNormal];
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (NSString *)tokenFieldCollapsedText:(VENTokenField *)tokenField {
    NSUInteger count = self.selectedNames.count;
    if (count == 0) {
        return @"";
    } else if (count == 1) {
        PFObject *user = self.selectedNames[0];
        NSString *name = [ZPUtility firstNameForDisplayName:[user objectForKey:kZPUserDisplayNameKey]];
        return name;
    } else {
        return [NSString stringWithFormat:@"%tu people", [self.selectedNames count]];
    }
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

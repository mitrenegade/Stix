//
//  AddressBookViewController.m
//  Stixx
//
//  Created by Bobby Ren on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AddressBookViewController.h"
@interface AddressBookViewController ()

@end

@implementation AddressBookViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)onAddressBook
{
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    [self presentModalViewController:picker animated:YES];
}






- (IBAction)onPersonView
{
    ABAddressBookRef addressBook = ABAddressBookCreate();
    ABPersonViewController *personView = [[ABPersonViewController alloc] init];
    personView.personViewDelegate = self;
    //ABRecordID recID = (ABRecordID)[lblID.text intValue];
    //personView.displayedPerson = ABAddressBookGetPersonWithRecordID(addressBook, recID);
    personView.allowsEditing = YES;
    if (personView.displayedPerson != NULL) {
        [self.navigationController pushViewController:personView animated:YES];
    }
}






- (IBAction)onAddNew
{
    ABNewPersonViewController *newPerson = [[ABNewPersonViewController alloc] init];
    newPerson.newPersonViewDelegate = self;
    [self.navigationController pushViewController:newPerson animated:YES];
}






- (IBAction)onUnknownPerson
{
    ABAddressBookRef addressBook = ABAddressBookCreate();
    ABUnknownPersonViewController *unknown = [[ABUnknownPersonViewController alloc] init];
    unknown.unknownPersonViewDelegate = self;
    unknown.allowsAddingToAddressBook = YES;
    unknown.addressBook = addressBook;
    ABRecordRef unknownPerson = ABPersonCreate();
    ABMultiValueRef email = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(email, CFSTR("test@naver.com"), kABHomeLabel, NULL);
    ABMultiValueAddValueAndLabel(email, CFSTR("test@gmail.com"), kABHomeLabel, NULL);
    CFErrorRef error;
    ABRecordSetValue(unknownPerson, kABPersonEmailProperty, email, &error);
    unknown.displayedPerson = unknownPerson;
    [self.navigationController pushViewController:unknown animated:YES];
    CFRelease(email);
    CFRelease(unknownPerson);
}






#pragma mark -
#pragma mark ABPeoplePickerNavigationControllerDelegate
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    [peoplePicker dismissModalViewControllerAnimated:YES];
    NSString *firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *lastName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    //lblName.text = [NSString stringWithFormat:@"%@ %@", lastName, firstName];
    ABRecordID recID = ABRecordGetRecordID(person);
    //lblID.text = [NSString stringWithFormat:@"%@", [NSNumber numberWithInt:recID]];
    return NO;
}






- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return YES;
}






- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [peoplePicker dismissModalViewControllerAnimated:YES];
}






#pragma mark -
#pragma mark ABPersonViewControllerDelegate
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue
{
    return YES;
}





#pragma mark -
#pragma mark ABNewPersonViewControllerDelegate
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person
{
    [self.navigationController popViewControllerAnimated:YES];
}





#pragma mark -
#pragma mark ABUnknownPersonViewControllerDelegate
- (void)unknownPersonViewController:(ABUnknownPersonViewController *)unknownPersonView didResolveToPerson:(ABRecordRef)person
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end

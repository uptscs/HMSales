//
//  ViewController.m
//  HMSales
//
//  Created by admin on 05/03/15.
//  Copyright (c) 2015 HappiestMinds. All rights reserved.
//

#import "ViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "DocumentHelper.h"
#import "Person.h"
#import "AppDelegate.h"


@implementation DetailTableViewCell
//
//- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
//{
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    if (self) {
//        NSArray *cellArray = [[NSBundle mainBundle] loadNibNamed:@"DetailTableViewCell" owner:self options:nil];
//        self = [cellArray objectAtIndex:0];
//    }
//    return self;
//}

@end

@interface ViewController (){
    Person *_contact;
    UITextField *currentActiveTextfield;
    NSString *shouldbeNotifiedWithEmail;
    NSArray *points;
    CGPoint center;
    CGFloat radius;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBar.translucent = NO;
    [self addNavigationButton];
    //    self.title = @"HAPPIEST MINDS TECHNOLOGIES @ ZINNOV CONFLUENCE 2015";
    self.title = @"HAPPIEST MINDS";
    shouldbeNotifiedWithEmail = @"YES Please";
    [self populateDefaultValues];
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //    [self sendEventInEmail];
}

-(void)populateDefaultValues{
    if (_contact) {
        _contact = nil;
    }
    _contact = [[Person alloc] init];
    _contact.arrayInterested = [[NSMutableArray alloc] init];
    _contact.shouldbeNotifiedWithMail = shouldbeNotifiedWithEmail;
    _contact.contactTime = @"0-3 Months";
    _img = nil;
    _imagePath = nil;
    
    for (int section = 0; section < [_contactTableView numberOfSections]; section++) {
        for (int row = 0; row < [_contactTableView numberOfRowsInSection:section]; row++) {
            NSIndexPath* cellPath = [NSIndexPath indexPathForRow:row inSection:section];
            UITableViewCell* cell = [_contactTableView cellForRowAtIndexPath:cellPath];
            for (UIView *view in cell.subviews) {
                for (UIView *subview in view.subviews) {
                    if ([subview isKindOfClass:[UITextField class]]) {
                        UITextField *textfield = (UITextField *)subview;
                        textfield.text = @"";
                    }
                }
            }
        }
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_contactTableView reloadData];
}

-(void)addNavigationButton{
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save)];
    [[self navigationItem] setRightBarButtonItem:done];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    [[self navigationItem] setLeftBarButtonItem:cancelItem];
}

-(BOOL)validateContact{
    if(_contact.name.length || _contact.designation.length || _contact.email.length || _contact.phone.length || _contact.interestedInOther.length || _contact.arrayInterested.count || _contact.picture.length){
        return YES;
    }
    return NO;
}

-(void)save{
    [currentActiveTextfield resignFirstResponder];
    if(![self validateEmail]){
        return;
    }
    if(![self validateContact])
        return;
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSMutableArray *tempInterestedDomains = [NSMutableArray new];
    for (NSNumber *tagNumber in _contact.arrayInterested) {
        NSString *domain = [self getDomainNamebyConstant:tagNumber];
        [tempInterestedDomains addObject:domain];
    }
    NSString *interest = [tempInterestedDomains componentsJoinedByString:@" / "];
    NSManagedObjectContext *context =
    [appDelegate managedObjectContext];
    NSManagedObject *newContact;
    newContact = [NSEntityDescription
                  insertNewObjectForEntityForName:@"Contacts"
                  inManagedObjectContext:context];
    [newContact setValue: (_contact.name != nil && _contact.name.length ? _contact.name : @"NA")  forKey:@"name"];
    [newContact setValue: (_contact.email  != nil && _contact.email.length ? _contact.email : @"NA") forKey:@"email"];
    [newContact setValue: (_contact.designation  != nil && _contact.designation.length ? _contact.designation : @"NA") forKey:@"designation"];
    [newContact setValue: (_contact.phone != nil && _contact.phone.length ? _contact.phone : @"NA") forKey:@"phone"];
    [newContact setValue: (_contact.interestedInOther != nil && _contact.interestedInOther.length ? _contact.interestedInOther : @"NA") forKey:@"interesttext"];
    [newContact setValue: (interest.length ? interest : @"NA") forKey:@"interest"];
    [newContact setValue:(_contact.contactTime  != nil && _contact.contactTime.length ? _contact.contactTime : @"NA") forKey:@"contactduration"];
    [newContact setValue:(_contact.contactTimeOther  != nil && _contact.contactTimeOther.length ? _contact.contactTimeOther : @"NA") forKey:@"contactdurationtext"];
    [newContact setValue:(_contact.shouldbeNotifiedWithMail  != nil && _contact.shouldbeNotifiedWithMail.length ? _contact.shouldbeNotifiedWithMail : @"NA") forKey:@"canmail"];
    [newContact setValue:(_contact.picture  != nil && _contact.picture.length ? _contact.picture : @"") forKey:@"picture"];
    
    NSError *error;
    [context save:&error];
    [self reloadTableView];
    [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Contact has been created successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (void)createHTMLContacts
{
    AppDelegate *appDelegate =
    [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *moc = [appDelegate managedObjectContext];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Contacts"
                                                  inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    NSError *error = nil;
    NSArray *contacts = [moc executeFetchRequest:request error:&error];
    NSMutableString *trtd = [NSMutableString new];
    if (error) {
        NSLog(@"Error fetching the punch item entities: %@", error);
    } else {
        for (NSDictionary *contact in contacts) {
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:[contact valueForKey:@"picture"]];
            NSString *strEncoded = [self encodeToBase64String:image];
            NSString* subhtml = [NSString stringWithFormat:@"<tr><td>%@</td><td>%@</td><td>%@</td><td>%@</td><td>%@</td><td>%@</td><td>%@</td><td>%@</td><td>%@</td><td><img src=\"data:image/jpg;base64,%@ alt=\"\" style=\"width: 150px; height: 50px;\"/></td></tr>",[contact valueForKey:@"name"],
                                 [contact valueForKey:@"designation"],
                                 [contact valueForKey:@"email"],
                                 [contact valueForKey:@"phone"],
                                 [contact valueForKey:@"interest"],
                                 [contact valueForKey:@"interesttext"],
                                 [contact valueForKey:@"contactduration"],
                                 [contact valueForKey:@"contactdurationtext"],
                                 [contact valueForKey:@"canmail"],
                                 strEncoded];
            [trtd appendString:subhtml];
        }
    }
    NSString* html = [NSString stringWithFormat:@"<html xmlns=\"http://www.w3.org/1999/xhtml\"><head><meta name=\"viewport\" content=\"width=device-width\"/><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" /><title>Request</title><link rel=\"stylesheet\" type=\"text/css\" href=\"email.css\" /></head><body bgcolor=\"#FFFFFF\"><table class=\"body-wrap\" border=\"1\" style=\"width:100%%\"><tr><td>\"Name\"</td><td>\"Designation\"</td><td>\"Email\"</td><td>\"Mobile\"</td><td>\"Interest\"</td><td>\"Interest Comment\"</td><td>\"Contact Duration\"</td><td>\"Contact Duration Comment\"</td><td>\"Can we contact\"</td><td>\"Business card\"</td></tr>%@</table></body></html>", trtd];
    NSURL * documentsDirectory = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
    NSURL *file = [documentsDirectory URLByAppendingPathComponent:@"contacts.html"];
    [html writeToFile:file.path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (NSString *)encodeToBase64String:(UIImage *)image {
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

- (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData {
    NSData *data = [[NSData alloc]initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}

- (void) sendEventInEmail
{
    NSURL * documentsDirectory = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
    NSError *error;
    NSURL *file = [documentsDirectory URLByAppendingPathComponent:@"contacts.html"];
    NSMutableString *emailBody = [[NSMutableString alloc] initWithContentsOfFile:file.path encoding:NSASCIIStringEncoding error:&error];
    // Compose dialog
    MFMailComposeViewController *emailDialog = [[MFMailComposeViewController alloc] init];
    emailDialog.mailComposeDelegate = self;
    NSString *filePath = [DocumentHelper getDocumentPathForFile:@"SalesLeads"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    [emailDialog addAttachmentData:data mimeType:@"text/html" fileName:@"SalesLeads.html"];
    // Set subject
    [emailDialog setSubject:@"Sales Leads!"];
    // Set body
    [emailDialog setMessageBody:emailBody isHTML:YES];
    // Show mail
    [self presentViewController:emailDialog animated:YES completion:nil];
}

-(void)cancel{
    NSLog(@"Canceled");
    [self reloadTableView];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void) reloadTableView{
    [self populateDefaultValues];
    [_contactTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Controls
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(_imagePath != nil && _imagePath.length)
        return 8;
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CustomStaticCell";
    static NSString *CellIdentifier2 = @"ImageCell";
    static NSString *CellIdentifier3 = @"CustomStaticInterestCell";
    static NSString *CellIdentifier4 = @"CustomStaticDemoCell";
    static NSString *CellIdentifier5 = @"CustomStaticYesNoCell";
    if (indexPath.section == 4) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier3 forIndexPath:indexPath];
        for (UIView *view in cell.subviews) {
            for (UIView *subview in view.subviews) {
                if ([subview isKindOfClass:[UIButton class]]) {
                    UIButton *button = (UIButton *)subview;
                    NSNumber *tagNumber = [NSNumber numberWithInteger:button.tag];
                    if ([_contact.arrayInterested containsObject:tagNumber]) {
                        [button setSelected:YES];
                    }else{
                        [button setSelected:NO];
                    }
                }
            }
        }
        return cell;
    }
    if (indexPath.section == 5) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier4 forIndexPath:indexPath];
        return cell;
    }
    if (indexPath.section == 6) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier5 forIndexPath:indexPath];
        return cell;
    }
    if (indexPath.section == 7 && _img != nil) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
        if (!cell)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2];
        
        UIImage *img = _img;
        CGFloat height = (280/img.size.width)*img.size.height;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(cell.bounds.origin.x+11, cell.bounds.origin.y+2, 298, height)];
        [imageView setBackgroundColor:[UIColor clearColor]];
        imageView.layer.cornerRadius = 10;
        imageView.clipsToBounds = YES;
        [imageView.layer setBorderColor: [[UIColor grayColor] CGColor]];
        [imageView.layer setBorderWidth: 0.25];
        [imageView setImage:img];
        [cell.contentView addSubview:imageView];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell setUserInteractionEnabled:NO];
        return cell;
    }
    DetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[DetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textFieldInput.tag = indexPath.section;
    switch (indexPath.section) {
        case 0:
            cell.textFieldInput.placeholder = @"Name";
            cell.textFieldInput.keyboardType = UIKeyboardTypeAlphabet;
            cell.textFieldInput.tag = 1001;
            if (_contact.name) {
                cell.textFieldInput.text = _contact.name;
            }else{
                cell.textFieldInput.text = @"";
            }
            break;
        case 1:
            cell.textFieldInput.placeholder = @"Designation";
            cell.textFieldInput.keyboardType = UIKeyboardTypeAlphabet;
            cell.textFieldInput.tag = 1002;
            if (_contact.designation) {
                cell.textFieldInput.text = _contact.designation;
            }else{
                cell.textFieldInput.text = @"";
            }
            break;
        case 2:
            cell.textFieldInput.placeholder = @"Email";
            cell.textFieldInput.keyboardType = UIKeyboardTypeEmailAddress;
            cell.textFieldInput.tag = 1003;
            if (_contact.email) {
                cell.textFieldInput.text = _contact.email;
            }else{
                cell.textFieldInput.text = @"";
            }
            break;
        case 3:
            cell.textFieldInput.placeholder = @"Phone";
            cell.textFieldInput.keyboardType = UIKeyboardTypePhonePad;
            cell.textFieldInput.tag = 1004;
            if (_contact.phone) {
                cell.textFieldInput.text = _contact.phone;
            }else{
                cell.textFieldInput.text = @"";
            }
            break;
        case 4:
            //CustomStaticInterestCell
            break;
        case 5:
            //CustomStaticDemoCell
            break;
        case 6:
            //CustomStaticYesNoCell
            break;
        default:
            break;
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 4) {
        return 270;
    }
    if (indexPath.section == 5) {
        return 180;
    }
    if (indexPath.section == 6) {
        return 110;
    }
    if (indexPath.section == 7 && _imagePath != nil) {
        _img = [UIImage imageWithContentsOfFile:_imagePath];
        CGFloat height = (280/_img.size.width)*_img.size.height +4;
        return height;
    }
    return 60;
}


#pragma mark - ImagePickerController Controls
-(IBAction)beginImageInsertion:(id)sender
{
    [currentActiveTextfield resignFirstResponder];
    
    UIImagePickerController *imagePicker =[[UIImagePickerController alloc] init];
    
    // Checking  and setting source types - ignoring photo albums
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    imagePicker.delegate = (id)self;
    
    imagePicker.mediaTypes = [NSArray arrayWithObjects:
                              (NSString *) kUTTypeImage,
                              (NSString *) kUTTypeMovie, nil];
    
    imagePicker.allowsEditing = YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

-(IBAction)email:(id)sender{
    [self sendEventInEmail];
}

-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
    {
        UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
        NSString *filePath = [DocumentHelper setDocumentPathForImage:image];
        NSLog(@"Image Stored in: %@", filePath);
        _imagePath = filePath;
        _contact.picture = _imagePath;
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Invalid Action" message:@"Videos are not allowed for placement here." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    [_contactTableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
    NSIndexPath *imageIndexpath = [NSIndexPath indexPathForRow:0 inSection:7];
    [_contactTableView scrollToRowAtIndexPath:imageIndexpath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(void)imagePickerControllerDidCancel:
(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)onRadioBtn:(RadioButton*)sender
{
    NSLog(@"Selected: %@", sender.titleLabel.text);
    shouldbeNotifiedWithEmail = sender.titleLabel.text;
    _contact.shouldbeNotifiedWithMail = shouldbeNotifiedWithEmail;
}

-(IBAction)contactTimeSelected:(RadioButton*)sender
{
    _contact.contactTime = sender.titleLabel.text;
}

- (IBAction)checkButton:(UIButton *)sender {
    sender.selected = !sender.selected;
    BOOL checked = sender.selected;
    NSNumber *tagNumber = [NSNumber numberWithInteger:sender.tag];
    if (checked) {
        [_contact.arrayInterested addObject:tagNumber];
    }else if([_contact.arrayInterested containsObject:_contact.arrayInterested]){
        [_contact.arrayInterested removeObject:tagNumber];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    id textFieldSuper = textField;
    while (![textFieldSuper isKindOfClass:[UITableViewCell class]]) {
        textFieldSuper = [textFieldSuper superview];
    }
    // Get that cell's index path
    NSIndexPath *indexPath = [_contactTableView indexPathForCell:(UITableViewCell *)textFieldSuper];
    [_contactTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    [_contactTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    CGPoint point = _contactTableView.contentOffset;
    point.y += 150;
    _contactTableView.contentOffset = point;
    
    currentActiveTextfield = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    switch (textField.tag) {
        case 1001:
            _contact.name = textField.text;
            break;
        case 1002:
            _contact.designation = textField.text;
            break;
        case 1003:
            _contact.email = textField.text;
            [self validateEmail];
            break;
        case 1004:
            _contact.phone = textField.text;
            break;
        case 14001:
            _contact.interestedInOther = textField.text;
            break;
        case 15001:
            _contact.contactTimeOther = textField.text;
            break;
        default:
            break;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    //    NSUInteger nextTextfieldTag = [self getNextTextfiledTag:textField];
    //    if (textField.tag == 15001)
    {
        [textField resignFirstResponder];
    }
    //    else
    //    {
    //        UITextField *nextTextfield  = [_contactTableView subviewWithTag];
    //        [nextTextfieldTag becomeFirstResponder];
    //    }
    return YES;
}

-(NSUInteger)getNextTextfiledTag : (UITextField *)textField{
    NSUInteger nextTag = 15001;
    switch (textField.tag) {
        case 1001:
            nextTag = 1002;
            break;
        case 1002:
            nextTag = 1003;
            break;
        case 1003:
            nextTag = 1004;
            break;
        case 1004:
            nextTag = 14001;
            break;
        case 14001:
            nextTag = 15001;
            break;
        case 15001:
            nextTag = 15001;
            break;
        default:
            break;
    }
    return nextTag;
}

-(NSString *)getDomainNamebyConstant : (NSNumber *)constant{
    NSString *domainName = @"";
    switch (constant.integerValue) {
        case 40001:
            domainName = @"Enterprise Platform";
            break;
        case 40002:
            domainName = @"Consumer Solutions";
            break;
        case 40003:
            domainName = @"Data Center Technologies";
            break;
        case 40004:
            domainName = @"Internet of Things";
            break;
        case 40005:
            domainName = @"Mobility";
            break;
        case 40006:
            domainName = @"Application Platforms";
            break;
        case 40007:
            domainName = @"Product Engineering";
            break;
        default:
            break;
    }
    return domainName;
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    NSURL * documentsDirectory = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
    NSURL *file = [documentsDirectory URLByAppendingPathComponent:@"contacts.html"];
    if ([[NSFileManager defaultManager] isDeletableFileAtPath:file.path]) {
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:file.path error:&error];
        if (!success) {
            NSLog(@"Error removing file at path: %@", error.localizedDescription);
        }
    }
    NSLog(@"Mail Sent");
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)share:(UIBarButtonItem *)sender
{
    [self createHTMLContacts];
    NSURL * documentsDirectory = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
    NSURL *file = [documentsDirectory URLByAppendingPathComponent:@"contacts.html"];
    NSString *filePath = file.path;
    UIDocumentInteractionController *document = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:filePath]];
    document.delegate = self;
    [document presentPreviewAnimated: YES];
}

-(UIViewController *)documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controller
{
    return self;
}

-(void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller
{
    //Placeholder for cleaning of PDF
    NSError *error;
    NSURL * documentsDirectory = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
    NSURL *file = [documentsDirectory URLByAppendingPathComponent:@"contacts.html"];
    if ([[NSFileManager defaultManager] isDeletableFileAtPath:file.path]) {
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:file.path error:&error];
        if (!success) {
            NSLog(@"Error removing file at path: %@", error.localizedDescription);
        }
    }
}


-(BOOL) isValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

-(BOOL) validateEmail{
    if(!_contact.email.length || [self isValidEmail:_contact.email]){
        return YES;
    }
   [[[UIAlertView alloc] initWithTitle:@"Invalid Email" message:@"Please enter valid email" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    return NO;
}

@end
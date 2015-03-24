//
//  ViewController.h
//  HMSales
//
//  Created by admin on 05/03/15.
//  Copyright (c) 2015 HappiestMinds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RadioButton.h"
#import <MessageUI/MessageUI.h>

@class Person;

@interface ViewController : UIViewController<UITextFieldDelegate, MFMailComposeViewControllerDelegate, UIDocumentInteractionControllerDelegate> {
    NSString *_imagePath;
    UIImage *_img;
}

@property (nonatomic, weak) IBOutlet UITableView *contactTableView;
@property NSManagedObjectContext *managedObjectContext;

-(IBAction)beginImageInsertion:(id)sender;

@property (nonatomic, strong) IBOutlet RadioButton* radioButton;
@property (nonatomic, strong) IBOutlet UILabel* statusLabel;
-(IBAction)onRadioBtn:(id)sender;

@end

@interface DetailTableViewCell : UITableViewCell  {
    BOOL swipedToDelete;
    UITableView*typeTable;
}

@property (nonatomic, strong) NSString*cellType;
@property (nonatomic, strong) id delegate;
@property (nonatomic, strong) IBOutlet UITextField *textFieldInput;

@end

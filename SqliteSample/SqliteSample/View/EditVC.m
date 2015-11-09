//
//  EditVC.m
//  SqliteSample
//
//  Created by TaiND on 11/9/15.
//  Copyright (c) 2015 ToanLH. All rights reserved.
//

#import "EditVC.h"
#import "DBManager.h"
#import "ViewController.h"

@interface EditVC ()<UITextFieldDelegate,edittingInfoFinished>
@property (strong, nonatomic) IBOutlet UITextField *txfFirstName;
@property (strong, nonatomic) IBOutlet UITextField *txfLastName;
@property (strong, nonatomic) IBOutlet UITextField *txfAge;

@property (nonatomic, strong) ViewController *mainVC;
@property (nonatomic, strong) DBManager *dbManager;

@end

@implementation EditVC{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveInfo)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    self.txfFirstName.delegate = self;
    self.txfLastName.delegate = self;
    self.txfAge.delegate = self;
    
    self.navigationController.navigationBar.tintColor = self.navigationItem.rightBarButtonItem.tintColor;
    self.dbManager = [[DBManager alloc] initWithDBFileName:@"toanlhDb.sql"];
    NSLog(@"count array: %d", (int)self.dbManager.columnNamesArray.count);
    
    if (self.recordIDToEdit != -1) {
        self.title = @"Edit record";
        [self loadInfoToEdit];
    }else{
        self.title = @"Add record";
    }
}

-(void)loadInfoToEdit{
    NSString *query = [NSString stringWithFormat:@"Select * from peopleinfo Where ppId = %d", self.recordIDToEdit];
    
    NSArray *results = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    self.txfFirstName.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.columnNamesArray indexOfObject:@"firstname"]];
    self.txfLastName.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.columnNamesArray indexOfObject:@"lastname"]];
    self.txfAge.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.columnNamesArray indexOfObject:@"age"]];
}

-(void)saveInfo{
    NSString *query;
    if (self.recordIDToEdit == -1) {
        query = [NSString stringWithFormat:@"Insert into peopleinfo Values (null, '%@', '%@', %d)", self.txfFirstName.text, self.txfLastName.text, [self.txfAge.text intValue]];
    }else{
        query = [NSString stringWithFormat:@"Update peopleinfo Set firstname = '%@', lastname = '%@', age = '%d'", self.txfFirstName.text, self.txfLastName.text, [self.txfAge.text intValue]];
    }
    
    [self.dbManager executeQuery:query];
    
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
        
        [self.delegate edittingInfoWasFinished];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        NSLog(@"Could not execute the query");
    }
}

-(void)edittingInfoWasFinished{
    [(ViewController*)self.parentViewController edittingInfoWasFinished];
}

@end

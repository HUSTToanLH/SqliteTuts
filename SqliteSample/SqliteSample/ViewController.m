//
//  ViewController.m
//  SqliteSample
//
//  Created by TaiND on 11/9/15.
//  Copyright (c) 2015 ToanLH. All rights reserved.
//

#import "ViewController.h"
#import "DBManager.h"
#import "EditVC.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate, edittingInfoFinished>

@property (nonatomic, strong) EditVC *editVc;
@property (nonatomic, strong) DBManager *dbManager;
@property (nonatomic, strong) NSArray *peopleInfoArray;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addButton;
- (IBAction)onTapNavButton:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"List people";
    
    self.peopleTable.delegate = self;
    self.peopleTable.dataSource = self;
    
    //init db manager property
    self.dbManager = [[DBManager alloc] initWithDBFileName:@"toanlhDb.sql"];
    
    
    [self loadData];
    self.editVc.delegate = self;
}

-(void)loadData{
    NSString *query = @"select * from peopleinfo";
    
    //get result
    if (self.peopleInfoArray != nil) {
        self.peopleInfoArray = nil;
    }
    
    self.peopleInfoArray = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    NSLog(@"count data: %d", (int)self.peopleInfoArray.count);
    [self.peopleTable reloadData];
}

#pragma mark - table view datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.peopleInfoArray.count;
}

//display cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"peopleTable"];
    
    NSInteger idxFirstName = [self.dbManager.columnNamesArray indexOfObject:@"firstname"];
    NSInteger idxLastName = [self.dbManager.columnNamesArray indexOfObject:@"lastname"];
    NSInteger idxAge = [self.dbManager.columnNamesArray indexOfObject:@"age"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [[self.peopleInfoArray objectAtIndex:indexPath.row] objectAtIndex:idxFirstName],[[self.peopleInfoArray objectAtIndex:indexPath.row] objectAtIndex:idxLastName]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Age: %@", [[self.peopleInfoArray objectAtIndex:indexPath.row] objectAtIndex:idxAge]];
    
    return cell;
}

//delete data and load data
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //find record id
        int recordIDToDelete = [[[self.peopleInfoArray objectAtIndex:indexPath.row] objectAtIndex:0] intValue];
        
        //prepare query
        NSString *query = [NSString stringWithFormat:@"Delete from peopleinfo Where ppId = %d", recordIDToDelete];
        
        //exec the query
        [self.dbManager executeQuery:query];
        
        //reload tableview
        [self loadData];
    }
}

#pragma mark - table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self editRecord:(int)indexPath.row];
}

-(void)editRecord:(int)record{
    EditVC *editView = [EditVC new];
    editView.recordIDToEdit = record;
    [self.navigationController pushViewController:editView animated:YES];
}

//reload data when update successful record
-(void)edittingInfoWasFinished{
    [self loadData];
}

- (IBAction)onTapNavButton:(id)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    EditVC *editVC = (EditVC*)[storyBoard instantiateViewControllerWithIdentifier:@"EditVC1"];
    editVC.recordIDToEdit = -1;
    [self.navigationController pushViewController:editVC animated:YES];
}
@end

//
//  DBManager.m
//  SqliteSample
//
//  Created by TaiND on 11/9/15.
//  Copyright (c) 2015 ToanLH. All rights reserved.
//

#import "DBManager.h"
#import <sqlite3.h>

@interface DBManager()

@property (nonatomic, strong) NSString *documentsDirectory;
@property (nonatomic, strong) NSString *databaseFileName;
@property (nonatomic, strong) NSMutableArray *resultsArray;

-(void)copyDatabaseIntoDocumentsDirectory;
-(void)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable;

@end

@implementation DBManager

-(instancetype)initWithDBFileName:(NSString *)dbFileName{
    self = [super init];
    if (self) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.documentsDirectory = [paths objectAtIndex:0];
        self.databaseFileName = dbFileName;
        [self copyDatabaseIntoDocumentsDirectory];
    }
    return self;
}

-(NSArray *)loadDataFromDB:(NSString *)query{
    [self runQuery:[query UTF8String] isQueryExecutable:NO];
    return (NSArray*)self.resultsArray;
}

-(void)executeQuery:(NSString *)query{
    [self runQuery:[query UTF8String] isQueryExecutable:YES];
}

#pragma mark - common function
//copy data from database to file
-(void)copyDatabaseIntoDocumentsDirectory{
    NSString *destinationPath = [[NSBundle mainBundle] pathForResource:@"toanlhDb" ofType:@"sql"];
//    NSString *destinationPath = [self.documentsDirectory stringByAppendingString:[@"/" stringByAppendingString:self.databaseFileName]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
        NSString *sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.databaseFileName];
        NSError *error;
        [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:destinationPath error:&error];
        if (error != nil) {
            NSLog(@"Error: %@", [error localizedDescription]);
        }
    }
}

// execute 1 SQLite Query and return result
-(void)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable{
    //declare sqlite2 object
    sqlite3 *sqlite3Database;
    
    //set database file path
    NSString *databasePath = [[NSBundle mainBundle] pathForResource:@"toanlhDb" ofType:@"sql"];
    
    //reset result array
    if (self.resultsArray != nil) {
        [self.resultsArray removeAllObjects];
        self.resultsArray = nil;
    }
    self.resultsArray = [NSMutableArray new];
    
    //reset column name array
    if (self.columnNamesArray != nil) {
        [self.columnNamesArray removeAllObjects];
        self.columnNamesArray = nil;
    }
    self.columnNamesArray = [NSMutableArray new];
    
    //open database
    BOOL openDBResult = sqlite3_open([databasePath UTF8String], &sqlite3Database);
    if (openDBResult == SQLITE_OK) {
        sqlite3_stmt *compiledStatement;
        
        //load all data from db to memory
        BOOL prepareStmtResult = sqlite3_prepare_v2(sqlite3Database, query, -1, &compiledStatement, NULL);
        
        if (prepareStmtResult == SQLITE_OK) {
            if (!queryExecutable) {
                NSMutableArray *dataRowArray;
                
                //loop results and add to the results array
                while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
                    dataRowArray = [NSMutableArray new];
    
                    int totalColumns = sqlite3_column_count(compiledStatement);
                    
                    for (int i = 0; i < totalColumns; i++) {
                        [self.resultsArray addObject:dataRowArray];
                    }
                }
            }
            else{
                //executable query (insert, update, delete)
                
                //execute query
                if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
                    //keep affected rows
                    self.affectedRows = sqlite3_changes(sqlite3Database);
                    
                    //keep the last inserted row ID
                    self.lastInsertedRowID = sqlite3_last_insert_rowid(sqlite3Database);
                }else{
                    NSLog(@"DB Error: %s", sqlite3_errmsg(sqlite3Database));
                }
            }
        }else{
            NSLog(@"%s", sqlite3_errmsg(sqlite3Database));
        }
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(sqlite3Database);
}

@end

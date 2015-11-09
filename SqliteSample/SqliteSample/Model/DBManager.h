//
//  DBManager.h
//  SqliteSample
//
//  Created by TaiND on 11/9/15.
//  Copyright (c) 2015 ToanLH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBManager : NSObject

@property (nonatomic, strong) NSMutableArray *columnNamesArray;
@property (nonatomic) int affectedRows;
@property (nonatomic) long long lastInsertedRowID;

-(instancetype) initWithDBFileName:(NSString*)dbFileName;
-(NSArray*) loadDataFromDB:(NSString*)query;
-(void) executeQuery:(NSString*)query;

@end

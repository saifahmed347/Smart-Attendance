//
//  Util.m
//  QuranPlus
//
//  Created by Samir on 14/03/2016.
//  Copyright © 2016 com. All rights reserved.
//

#import "Util.h"
#import "AppData.h"

@implementation Util


+(NSString *) getFilePath :(NSString *)fileName
{
    
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
    
    return filePath;
}


+(void) copyFile:(NSString *)file
{
    
    NSString *DB_NAME = AppData.getDatabaseName;
    
    NSString *filePath=[self getFilePath:file];
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *destinationPath = [docPath stringByAppendingPathComponent:file];
    
    NSLog(@"path : %@, destinationPath : %@", filePath, destinationPath);
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSLog(@"is file exist : %d", [fileManager fileExistsAtPath:filePath]);
    
    if(![fileManager fileExistsAtPath:filePath]){
        
        NSString *fromPath=[[NSBundle mainBundle] pathForResource:DB_NAME ofType:@"sqlite"];
        NSLog(@"is file exist : %d", [fileManager fileExistsAtPath:fromPath]);
        
        NSLog(@"SA db copied : %d", [fileManager copyItemAtPath:fromPath toPath:destinationPath error:nil]);
    }
    
}


+(void)deleteFileFromCacheWithFileName:(NSString *)fileName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath =  [documentsDirectory stringByAppendingPathComponent:fileName];
    
    NSLog(@"file path : %@", filePath);
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        BOOL b = [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        NSLog(@"deleted : %d", b);
    }
    
}

@end

//
//  DBManager.m
//  QuranPlus
//
//  Created by Aqeel Ahmed on 14/03/2016.
//  Copyright © 2016 com. All rights reserved.
//

#import "DBManager.h"
#import "AppData.h"
//#define NSLog(...)

@implementation DBManager

static DBManager *instance=nil;

+(DBManager *)getInstance{
    if(!instance)
    {
        NSString *dbFileName = [NSString stringWithFormat:@"%@.sqlite", AppData.getDatabaseName];
        instance=[[DBManager alloc]init];
        instance.database=[FMDatabase databaseWithPath:[Util getFilePath:dbFileName]];
    }
    return instance;
}

+(dispatch_queue_t)getDBInsertionQueue{
    
    static dispatch_queue_t dbInsertionQueue;
    if(dbInsertionQueue == nil){
        static dispatch_once_t once_queue_creation;
        dispatch_once(&once_queue_creation, ^{
            dbInsertionQueue = dispatch_queue_create("dbInsertionQueue",DISPATCH_QUEUE_SERIAL);
        });
    }
    return dbInsertionQueue;
}


#pragma Employee Attendance

/*
 CREATE TABLE "employee_attendance" (
 `_id`	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
 `user_id`	INTEGER,
 `dateof`	DATE,
 `time_in`	TIME,
 `time_out`	TIME,
 `type`	TEXT,
 `location`	TEXT,
 `user_ip`	TEXT,
 `device`	TEXT,
 `imei`	TEXT,
 `created_time`	TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 `updated_time`	TIMESTAMP,
 `user_agent`	TEXT,
 `check_in_image`	TEXT,
 `check_out_image`	TEXT
 , "is_uploaded" INTEGER NOT NULL  DEFAULT 0)
 */


-(NSMutableArray *)getAllAttendanceOfEmployeeWithUserId:(NSString *)user_id {
    
    NSMutableDictionary *dataDic;
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM employee_attendance WHERE user_id = %@", user_id];
    
    [instance.database open];
    FMResultSet *resultSet=[instance.database executeQuery:query];
    
    if(resultSet)
    {
        while([resultSet next]){
            
            dataDic = [[NSMutableDictionary alloc] init];
            
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"_id"]] forKey:@"_id"];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"dateof"]] forKey:@"dateof"];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"time_in"]] forKey:@"time_in"];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"time_out"]] forKey:@"time_out"];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"type"]] forKey:@"type"];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"location"]] forKey:@"location"];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"user_ip"]] forKey:@"user_ip"];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"device"]] forKey:@"device"];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"imei"]] forKey:@"imei"];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"created_time"]] forKey:@"created_time"];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"updated_time"]] forKey:@"updated_time"];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"user_agent"]] forKey:@"user_agent"];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"check_in_image"]] forKey:@"check_in_image"];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"check_out_image"]] forKey:@"check_out_image"];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"is_uploaded"]] forKey:@"is_uploaded"];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"is_on_break"]] forKey:@"is_on_break"];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"time_diff"]] forKey:@"time_diff"];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"location_checkin"]] forKey:@"location_checkin"];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"location_checkout"]] forKey:@"location_checkout"];
            
            [dataArray addObject:dataDic];
            
            dataDic = nil;
        }
        
    }
    [instance.database close];
    
    NSLog(@"getAllEmployeeAttendance : %@", dataArray);
    
    return dataArray;
    
}

-(NSMutableArray *)getAllAttendanceOfEmployeeWithUserId:(NSString *)user_id andIsUploaded:(NSString *)isUploaded {
    
    NSMutableDictionary *dataDic;
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM employee_attendance WHERE user_id = '%@' AND is_uploaded = '%@'", user_id, isUploaded];
    NSLog(@"getAllAttendanceOfEmployeeWithUserId query: %@", query);
    
    [instance.database open];
    FMResultSet *resultSet=[instance.database executeQuery:query];
    
    if(resultSet)
    {
        while([resultSet next]){
            
            dataDic = [[NSMutableDictionary alloc] init];
            
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"_id"]] forKey:@"_id"];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"dateof"]] forKey:@"dateof"];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"time_in"]] forKey:@"time_in"];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"time_out"]] forKey:@"time_out"];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"type"]] forKey:@"type"];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"location"]] forKey:@"location"];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"user_ip"]] forKey:@"user_ip"];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"device"]] forKey:@"device"];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"imei"]] forKey:@"imei"];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"created_time"]] forKey:@"created_time"];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"updated_time"]] forKey:@"updated_time"];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"user_agent"]] forKey:@"user_agent"];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"check_in_image"]] forKey:@"check_in_image"];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"check_out_image"]] forKey:@"check_out_image"];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"is_uploaded"]] forKey:@"is_uploaded"];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"is_on_break"]] forKey:@"is_on_break"];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"time_diff"]] forKey:@"time_diff"];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"location_checkin"]] forKey:@"location_checkin"];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"location_checkout"]] forKey:@"location_checkout"];
            
            [dataArray addObject:dataDic];
            
            dataDic = nil;
        }
        
    }
    [instance.database close];
    
    NSLog(@"getAllEmployeeAttendance : %@", dataArray);
    
    return dataArray;
    
}



-(BOOL)updateAllRecodsIsUploadedColoum {
    
    NSString *query = @"UPDATE employee_attendance SET is_uploaded = '1' WHERE is_uploaded = '0' ";
    NSLog(@"query: %@", query );
    
    [instance.database open];
    
    BOOL success = [instance.database executeUpdate:query];
    
    if (!success) {
        NSLog(@"updateAllRecodsIsUploadedColoum error = %@", [instance.database lastErrorMessage]);
    }else{
        NSLog(@"All record uploaded Successfully");
    }
    
    return success;
}


#pragma Mark Attendance

-(BOOL)markAttendanceWithUserId:(NSString *)user_id andType:(NSString *)type andLocation:(NSString *)location andDevice:(NSString *)device andIMEI:(NSString *)imei andDateOf:(NSString *)dateof andTime:(NSString *)time andAttendanceFor:(NSString *)attendance_for andImageName:(NSString *)imageName andIsUploaded:(NSString *)isUploaded {
    
    NSLog(@"user_id : %@, type : %@, location : %@, device : %@, imei : %@, dateof : %@, attendance_for : %@, isUploaded : %@, time: %@", user_id, type, location, device, imei, dateof, attendance_for, isUploaded, time);
    
    NSString *updated_time = [AppData getDateWithFormateString:@"yyyy-MM-dd HH:mm:ss" andDateObject:[NSDate date]];
    NSLog(@"updated_time: %@", updated_time);
    
    
    BOOL success = false;
    [instance.database open];
    
    if([type isEqualToString:@"checking"]) {
        
        if([attendance_for isEqualToString:@"time_in"]) {
            
            success = [instance.database executeUpdate:@"INSERT INTO employee_attendance(user_id, type, location_checkin, device, imei, dateof, time_in, check_in_image, is_uploaded) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)", user_id, type, location, device, imei, dateof, time, imageName, isUploaded ?: [NSNull null]];
            
        } else if([attendance_for isEqualToString:@"time_out"]) {
            
            NSString *time_in = [self getTimeInWithUserId:user_id andDateOf:dateof andType:@"checking"];
            NSString *time_diff = [self getTimeDiffrenceWithTimeIn:time_in andTimeOut:time];
            
            NSString *query = [NSString stringWithFormat:@"UPDATE employee_attendance SET time_out = '%@', check_out_image = '%@', updated_time = '%@', is_uploaded = '%@', time_diff = '%@', location_checkout = '%@' WHERE user_id = '%@' AND dateof = '%@' AND type = '%@'", time, imageName, updated_time, isUploaded, time_diff, location, user_id, dateof, type];
            NSLog(@"query: %@", query );
            
            success = [instance.database executeUpdate:query];

        }
        
    }else if([type isEqualToString:@"break"]) {
        
        if([attendance_for isEqualToString:@"time_in"]) {
            
            NSString *is_on_break = @"1";
            
            success = [instance.database executeUpdate:@"INSERT INTO employee_attendance(user_id, type, location_checkin, device, imei, dateof, time_in, check_in_image, is_uploaded, is_on_break) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", user_id, type, location, device, imei, dateof, time, imageName, isUploaded, is_on_break ?: [NSNull null]];
            
        } else if([attendance_for isEqualToString:@"time_out"]) {
            
            NSString *time_in = [self getTimeInWithUserId:user_id andDateOf:dateof andType:@"break"];
            NSString *time_diff = [self getTimeDiffrenceWithTimeIn:time_in andTimeOut:time];
            
            NSString *query = [NSString stringWithFormat:@"UPDATE employee_attendance SET time_out = '%@', check_out_image = '%@', updated_time = '%@', is_uploaded = '%@', time_diff = '%@', location_checkout = '%@', is_on_break = 0 WHERE user_id = '%@' AND dateof = '%@' AND type = '%@' AND is_on_break = '1' ", time, imageName, updated_time, isUploaded, time_diff, location, user_id, dateof, type];
            NSLog(@"break time_out query: %@", query );
            
            success = [instance.database executeUpdate:query];
        }
        
    }
    
    if (!success) {
        NSLog(@"markAttendance error = %@", [instance.database lastErrorMessage]);
    }else{
        NSLog(@"Attendance marked Successfully");
    }
    
    [instance.database close];
    
    
    return success;
    
}


-(BOOL)timeOutMarkAttendanceWithUserId:(NSString *)user_id andType:(NSString *)type andLocation:(NSString *)location andDevice:(NSString *)device andIMEI:(NSString *)imei andDateOf:(NSString *)dateof andTime:(NSString *)time andAttendanceFor:(NSString *)attendance_for andImageName:(NSString *)imageName andDayEndedNote:(NSString *)day_ended_note andDayEnded:(BOOL)day_ended andIsUploaded:(NSString *)isUploaded
    {
    
        NSLog(@"user_id : %@, type : %@, location : %@, device : %@, imei : %@, dateof : %@, attendance_for : %@, isUploaded : %@, day_ended_note: %@, day_ended: %hhd time: %@", user_id, type, location, device, imei, dateof, attendance_for, isUploaded, day_ended_note, day_ended, time);
    
    NSString *updated_time = [AppData getDateWithFormateString:@"yyyy-MM-dd HH:mm:ss" andDateObject:[NSDate date]];
    NSLog(@"updated_time: %@", updated_time);
    
    
    BOOL success = false;
    [instance.database open];
    
    if([type isEqualToString:@"checking"]) {
        
        if([attendance_for isEqualToString:@"time_in"]) {
            
            success = [instance.database executeUpdate:@"INSERT INTO employee_attendance(user_id, type, location_checkin, device, imei, dateof, time_in, check_in_image, day_ended_note, day_ended, is_uploaded) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", user_id, type, location, device, imei, dateof, time, imageName, day_ended_note, day_ended, isUploaded ?: [NSNull null]];
            
        } else if([attendance_for isEqualToString:@"time_out"]) {
            
            NSString *time_in = [self getTimeInWithUserId:user_id andDateOf:dateof andType:@"checking"];
            NSString *time_diff = [self getTimeDiffrenceWithTimeIn:time_in andTimeOut:time];
            
            NSString *query = [NSString stringWithFormat:@"UPDATE employee_attendance SET time_out = '%@', check_out_image = '%@', updated_time = '%@', is_uploaded = '%@', time_diff = '%@', location_checkout = '%@', day_ended_note = '%@', day_ended = '%hhd' WHERE user_id = '%@' AND dateof = '%@' AND type = '%@'", time, imageName, updated_time, isUploaded, time_diff, location, day_ended_note, day_ended, user_id, dateof, type];
            NSLog(@"query: %@", query );
            
            success = [instance.database executeUpdate:query];
            
        }
        
    }else if([type isEqualToString:@"break"]) {
        
        if([attendance_for isEqualToString:@"time_in"]) {
            
            NSString *is_on_break = @"1";
            
            success = [instance.database executeUpdate:@"INSERT INTO employee_attendance(user_id, type, location_checkin, device, imei, dateof, time_in, check_in_image, is_uploaded, is_on_break) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", user_id, type, location, device, imei, dateof, time, imageName, isUploaded, is_on_break ?: [NSNull null]];
            
        } else if([attendance_for isEqualToString:@"time_out"]) {
            
            NSString *time_in = [self getTimeInWithUserId:user_id andDateOf:dateof andType:@"break"];
            NSString *time_diff = [self getTimeDiffrenceWithTimeIn:time_in andTimeOut:time];
            
            NSString *query = [NSString stringWithFormat:@"UPDATE employee_attendance SET time_out = '%@', check_out_image = '%@', updated_time = '%@', is_uploaded = '%@', time_diff = '%@', location_checkout = '%@', is_on_break = 0 WHERE user_id = '%@' AND dateof = '%@' AND type = '%@' AND is_on_break = '1' ", time, imageName, updated_time, isUploaded, time_diff, location, user_id, dateof, type];
            NSLog(@"break time_out query: %@", query );
            
            success = [instance.database executeUpdate:query];
        }
        
    }
    
    if (!success) {
        NSLog(@"markAttendance error = %@", [instance.database lastErrorMessage]);
    }else{
        NSLog(@"Attendance marked Successfully");
    }
    
    [instance.database close];
    
    
    return success;
    
}


-(NSString *)getTimeInWithUserId:(NSString *)user_id andDateOf:(NSString *)dateof andType:(NSString *)type{
    
    NSString *time_in = @"";
    
    NSString *query = [NSString stringWithFormat:@"SELECT time_in FROM employee_attendance WHERE user_id = '%@' AND dateof = '%@' AND type = '%@' AND time_out IS NULL", user_id, dateof, type];
    NSLog(@"getTimeIn query: %@", query);
    
    FMResultSet *resultSet=[instance.database executeQuery:query];
    if(resultSet)
    {
        while([resultSet next]){
            time_in = [NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"time_in"]];
        }
    }

    NSLog(@"time_in : %@", time_in);
    return time_in;
}


- (NSString *)getTimeDiffrenceWithTimeIn:(NSString *)time_in andTimeOut:(NSString *)time_out{
    
    NSDate *timeInObj = [AppData getDateObjectFromStringWithTimeString:time_in andDateFormat:@"HH:mm:ss" andTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSDate *timeOutObj = [AppData getDateObjectFromStringWithTimeString:time_out andDateFormat:@"HH:mm:ss" andTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];

    NSTimeInterval secs = [timeOutObj timeIntervalSinceDate:timeInObj];
    NSLog(@"secs : %f", secs);
    
    int totalTimeInSeconds = (int)secs;
    int totalTimeInMinuts = 0;
    int totalTimeInHours = 0;
    
    if (totalTimeInSeconds > 59) {
        int min = (int)(totalTimeInSeconds / 60);
        totalTimeInSeconds = (int)(totalTimeInSeconds % 60);
        totalTimeInMinuts += min;
    }
    
    if (totalTimeInMinuts > 59) {
        int hrs = (int)(totalTimeInMinuts / 60);
        totalTimeInMinuts = (int)(totalTimeInMinuts % 60);
        totalTimeInHours += hrs;
    }
    
    
    NSLog(@"totalTimeInSeconds: %i, totalTimeInMinuts: %i, totalTimeInHours: %i", totalTimeInSeconds, totalTimeInMinuts, totalTimeInHours);
    
    NSString *time_diff_str = [NSString stringWithFormat:@"%i:%i:%i", totalTimeInHours, totalTimeInMinuts, totalTimeInSeconds];
    
    NSDate *time_diff_date = [AppData getDateObjectFromStringWithTimeString:time_diff_str andDateFormat:@"HH:mm:ss" andTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    
    NSString *time_diff = [AppData getDateWithFormateString:@"HH:mm:ss" andDateObject:time_diff_date andTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    
    NSLog(@"time_diff: %@", time_diff);
    
    return time_diff;
}


-(BOOL)isAlreadyCheckinWithUserId:(NSString *)user_id andDateOf:(NSString *)dateof andType:(NSString *)type{
    
    [instance.database open];
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM employee_attendance Where user_id = '%@' AND dateof = '%@' AND type = '%@'", user_id, dateof, type];
    NSLog(@"isAlreadyCheckin Query: %@", query);
    
    FMResultSet *resultSet=[instance.database executeQuery:query];
    
    if(resultSet)
    {
        while([resultSet next]){
            return YES;
        }
        
    }
    [instance.database close];
    
    return NO;
}


-(BOOL)isAlreadyCheckOutWithUserId:(NSString *)user_id andDateOf:(NSString *)dateof andType:(NSString *)type{
    
    [instance.database open];
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM employee_attendance Where user_id = '%@' AND dateof = '%@' AND type = '%@' AND time_out IS NOT NULL", user_id, dateof, type];
    NSLog(@"isAlreadyCheckOut Query: %@", query);
    
    FMResultSet *resultSet=[instance.database executeQuery:query];
    
    if(resultSet)
    {
        while([resultSet next]){
            return YES;
        }
    }
    [instance.database close];
    
    return NO;
}

-(BOOL)isEmployeeAlreadyOnBreakWithUserId:(NSString *)user_id andDateOf:(NSString *)dateof {
    
    [instance.database open];
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM employee_attendance Where user_id = '%@' AND dateof = '%@' AND type = 'break' AND is_on_break = '1'", user_id, dateof];
    NSLog(@"isEmployeeAlreadyOnBreak Query: %@", query);
    
    FMResultSet *resultSet=[instance.database executeQuery:query];
    
    if(resultSet)
    {
        while([resultSet next]){
            return YES;
        }
    }
    [instance.database close];
    
    return NO;
}

-(NSString *)getCheckingTimeWithUserId:(NSString *)user_id andDateOf:(NSString *)dateof andType:(NSString *)type andInOrOut:(NSString *)inOrOut {
    
    [instance.database open];
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM employee_attendance Where user_id = '%@' AND dateof = '%@' AND type = '%@'", user_id, dateof, type];
    NSLog(@"getCheckingTimeWithUserId Query: %@", query);
    
    FMResultSet *resultSet=[instance.database executeQuery:query];
    
    if(resultSet)
    {
        while([resultSet next]){
            NSString *dateof = [NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"dateof"]];
            NSString *time = [NSString stringWithFormat:@"%@", [resultSet stringForColumn:inOrOut]];
            NSLog(@"time: %@", time);
            
            if([time isEqualToString:@"(null)"]) {
                return @"-";
            }
            
            NSString *time_stamp = [NSString stringWithFormat:@"%@ %@", dateof, time];
            NSLog(@"%@", time_stamp);
            return time_stamp;
        }
        
    }
    [instance.database close];
    
    return @"-";
}



#pragma mark Images table

//CREATE TABLE "images" ("_id" INTEGER PRIMARY KEY  NOT NULL ,"user_id" INTEGER,"image_name" TEXT,"is_uploaded" INTEGER NOT NULL  DEFAULT (0))

-(NSMutableArray *)getAllImagesWithUserId:(NSString *)user_id andIsUploaded:(NSString *)isUploaded {
    
    NSMutableDictionary *dataDic;
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM images WHERE user_id = '%@' AND is_uploaded = '%@'", user_id, isUploaded];
    
    [instance.database open];
    FMResultSet *resultSet=[instance.database executeQuery:query];
    
    if(resultSet)
    {
        while([resultSet next]){
            
            dataDic = [[NSMutableDictionary alloc] init];
            
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"_id"]] forKey:@"_id"];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"user_id"]] forKey:@"user_id"];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"image_name"]] forKey:@"image_name"];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [resultSet stringForColumn:@"is_uploaded"]] forKey:@"is_uploaded"];
            
            [dataArray addObject:dataDic];
            
            dataDic = nil;
        }
        
    }
    [instance.database close];
    
    NSLog(@"images : %@", dataArray);
    
    return dataArray;
    
}


-(BOOL)insertImageRecordWithUserId:(NSString *)userId andImageName:(NSString *)imageName andIsUploaded:(NSString *)isUploaded {
    
    [instance.database open];
    
    BOOL success = [instance.database executeUpdate:@"INSERT INTO images (user_id, image_name, is_uploaded) VALUES (?, ?, ?)",userId, imageName, isUploaded ?: [NSNull null]];
    
    if (!success) {
        NSLog(@"error = %@", [instance.database lastErrorMessage]);
    }else{
        NSLog(@"%@ inserted successfully", imageName);
    }
    
    [instance.database close];
    
    return success;
}


-(BOOL)deleteImageWithUserId:(NSString *)userId andImageName:(NSString *)imageName{
    
    [instance.database open];
    
    NSString *query = [NSString stringWithFormat:@"DELETE FROM images WHERE user_id = '%@' AND image_name = '%@'", userId, imageName];
    
    BOOL success = [instance.database executeUpdate:query];
    
    if (!success) {
        NSLog(@"Image Updation error : %@", [instance.database lastErrorMessage]);
    }else{
        NSLog(@"%@ deleted successfully", imageName);
    }
    
    [instance.database close];
    
    return success;
}


-(BOOL)updateImagesUploadStatusWithUserId:(NSString *)userId ImageName:(NSString *)imageName andIsUploaded:(NSString *)isUploaded {
    
    NSString *query = [NSString stringWithFormat:@"UPDATE images SET is_uploaded = '%@' WHERE user_id = '%@' AND image_name = '%@' ", isUploaded, userId, imageName];
    NSLog(@"query: %@", query );
    
    [instance.database open];
    
    BOOL success = [instance.database executeUpdate:query];
    
    if (!success) {
        NSLog(@"updateAllRecodsIsUploadedColoum error = %@", [instance.database lastErrorMessage]);
    }else{
        NSLog(@"All record uploaded Successfully");
    }
    
    [instance.database close];
    
    return success;
}


-(void)deleteAllData{
    
    NSString *query1 = @"DELETE FROM images";
    NSString *query2 = @"DELETE FROM employee_attendance";
    
    [instance.database open];
    
    BOOL success1 = [instance.database executeUpdate:query1];
    BOOL success2 = [instance.database executeUpdate:query2];
    
    if (!success1) {
        NSLog(@"images error = %@", [instance.database lastErrorMessage]);
    }else{
        NSLog(@"All images deleted Successfully");
    }
    
    if (!success2) {
        NSLog(@"employee_attendance error = %@", [instance.database lastErrorMessage]);
    }else{
        NSLog(@"All employee_attendance deleted Successfully");
    }
    
    [instance.database close];
}

/*
 
 "_id": "329",
 "user_id": "22", (done)
 "dateof": "2017-07-19", (done)
 "time_in": "17:48:00", (done)
 "time_out": "18:03:27", (done)
 "time_diff": "00:15:27", (done)
 "type": "checking", (done)
 "location_checkin": "25.3755255971139,68.34933208408879", (done)
 "location_checkout": null, (done)
 "location": null, (done)
 "user_ip": "110.38.134.228",
 "device": "iphone", (done)
 "imei": "9E4EDA82-D93C-4CB7-A260-1", (done)
 "created_time": "2017-07-19 07:48:00", (done)
 "updated_time": "2017-07-19 18:03:27", (done)
 "user_agent": "SmartAttendance/3.0 (com.gexton.SmartAttendance; build:3; iOS 10.2.0) Alamofire/4.4.0",
 "check_in_image": "2017/07/1500468480_employee_img.jpg", (done)
 "check_out_image": "2017/07/1500469407_employee_img.jpg", (done)
 "sync_data": "0"
 
 */


#pragma mark Current day record insertion
-(BOOL)insertRecordWithUserId:(NSString *)user_id andType:(NSString *)type andLocation:(NSString *)location andLocationCheckIn:(NSString *)location_checkin andLocationOut:(NSString *)location_checkout andDevice:(NSString *)device andIMEI:(NSString *)imei andDateOf:(NSString *)dateof andTimeIn:(NSString *)time_in andTimeOut:(NSString *)time_out andTimeDifference:(NSString *)time_diff andCreateTime:(NSString *)created_time andUpdateTime:(NSString *)updated_time andCheckInImage:(NSString *)check_in_image andCheckOutImage:(NSString *)check_out_image andIsUploaded:(NSString *)isUploaded {
    
    NSLog(@"user_id : %@, type : %@, location : %@, location_checkin : %@, location_checkout : %@, device : %@, imei : %@, dateof : %@, time_in: %@, time_out: %@, time_diff: %@, created_time: %@, updated_time: %@, check_in_image : %@, check_out_image: %@, isUploaded : %@", user_id, type, location, location_checkin, location_checkout, device, imei, dateof, time_in, time_out, time_diff, created_time, updated_time, check_in_image, check_out_image, isUploaded);
    
    BOOL success = false;
    [instance.database open];
    
    success = [instance.database executeUpdate:@"INSERT INTO employee_attendance(user_id, type, location_checkin, location_checkout, device, imei, dateof, time_in, time_out, time_diff, created_time, updated_time, check_in_image, check_out_image, is_uploaded) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", user_id, type, location_checkin, location_checkout, device, imei, dateof, time_in, time_out, time_diff, created_time, updated_time, check_in_image, check_out_image, isUploaded ?: [NSNull null]];
    
    if (!success) {
        NSLog(@"today's record insertion error = %@", [instance.database lastErrorMessage]);
    }else{
        NSLog(@"today's record inserted Successfully");
    }
    
    [instance.database close];
    
    return success;
    
}


@end

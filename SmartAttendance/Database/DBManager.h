//
//  DBManager.h
//  QuranPlus
//
//  Created by Aqeel Ahmed on 14/03/2016.
//  Copyright © 2016 com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDatabase.h>
#import "Util.h"

@interface DBManager : NSObject

@property (nonatomic,strong) FMDatabase *database;

+(DBManager *) getInstance;
+(dispatch_queue_t)getDBInsertionQueue;


-(void)deleteAllData;

#pragma mark Employee Attendance

-(NSMutableArray *)getAllAttendanceOfEmployeeWithUserId:(NSString *)user_id;
-(NSMutableArray *)getAllAttendanceOfEmployeeWithUserId:(NSString *)user_id andIsUploaded:(NSString *)isUploaded;
-(BOOL)updateAllRecodsIsUploadedColoum;

-(BOOL)markAttendanceWithUserId:(NSString *)user_id andType:(NSString *)type andLocation:(NSString *)location andDevice:(NSString *)device andIMEI:(NSString *)imei andDateOf:(NSString *)dateof andTime:(NSString *)time andAttendanceFor:(NSString *)attendance_for andImageName:(NSString *)imageName andIsUploaded:(NSString *)isUploaded;

-(BOOL)timeOutMarkAttendanceWithUserId:(NSString *)user_id andType:(NSString *)type andLocation:(NSString *)location andDevice:(NSString *)device andIMEI:(NSString *)imei andDateOf:(NSString *)dateof andTime:(NSString *)time andAttendanceFor:(NSString *)attendance_for andImageName:(NSString *)imageName andDayEndedNote:(NSString *)day_ended_note andDayEnded:(BOOL)day_ended andIsUploaded:(NSString *)isUploaded;

-(NSString *)getTimeInWithUserId:(NSString *)user_id andDateOf:(NSString *)dateof andType:(NSString *)type;
- (NSString *)getTimeDiffrenceWithTimeIn:(NSString *)time_in andTimeOut:(NSString *)time_out;
-(BOOL)isAlreadyCheckinWithUserId:(NSString *)user_id andDateOf:(NSString *)dateof andType:(NSString *)type;
-(BOOL)isAlreadyCheckOutWithUserId:(NSString *)user_id andDateOf:(NSString *)dateof andType:(NSString *)type;
-(BOOL)isEmployeeAlreadyOnBreakWithUserId:(NSString *)user_id andDateOf:(NSString *)dateof;
-(NSString *)getCheckingTimeWithUserId:(NSString *)user_id andDateOf:(NSString *)dateof andType:(NSString *)type andInOrOut:(NSString *)inOrOut;
    
#pragma Images

-(NSMutableArray *)getAllImagesWithUserId:(NSString *)user_id andIsUploaded:(NSString *)isUploaded;
-(BOOL)insertImageRecordWithUserId:(NSString *)userId andImageName:(NSString *)imageName andIsUploaded:(NSString *)isUploaded;
-(BOOL)deleteImageWithUserId:(NSString *)userId andImageName:(NSString *)imageName;
-(BOOL)updateImagesUploadStatusWithUserId:(NSString *)userId ImageName:(NSString *)imageName andIsUploaded:(NSString *)isUploaded;

#pragma mark Current day record insertion
-(BOOL)insertRecordWithUserId:(NSString *)user_id andType:(NSString *)type andLocation:(NSString *)location andLocationCheckIn:(NSString *)location_checkin andLocationOut:(NSString *)location_checkout andDevice:(NSString *)device andIMEI:(NSString *)imei andDateOf:(NSString *)dateof andTimeIn:(NSString *)time_in andTimeOut:(NSString *)time_out andTimeDifference:(NSString *)time_diff andCreateTime:(NSString *)created_time andUpdateTime:(NSString *)updated_time andCheckInImage:(NSString *)check_in_image andCheckOutImage:(NSString *)check_out_image andIsUploaded:(NSString *)isUploaded;

@end

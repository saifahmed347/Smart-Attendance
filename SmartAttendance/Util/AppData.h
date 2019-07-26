//
//  AppData.h
//  QuranIQ
//
//  Created by Samir on 12/01/2016.
//  Copyright © 2016 com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface AppData : NSObject <MFMailComposeViewControllerDelegate>

+ (NSString *)getDatabaseName;
    
//UIVIEW
+(void)setBorderWithView:(UIView *)view andBorderWidth:(float)width andBorderColor:(UIColor *)color andBorderRadius:(CGFloat)radius;
+ (void)drawShadowWithView:(UIView *)view;
+ (void)drawSideShadowWithView:(UIView *)view;

//Color
+ (UIColor *)colorFromHexString:(NSString *)hexString andAlpha:(CGFloat)alpha;

//DATE
+(NSString *)convertDateFormatWithTimeString:(NSString *)timeStr andInitialDateFormat:(NSString *)initialFormat andDesireDateFormat:(NSString *)desireFormat;
+(NSString *)getDateWithFormateString:(NSString *)format andDateObject:(NSDate *)dateObj;+(NSString *)getDateWithFormateString:(NSString *)format andDateObject:(NSDate *)dateObj andTimeZone:(NSTimeZone *)timeZone;
+(NSDate *)getDateObjectFromStringWithTimeString:(NSString *)timeStr andDateFormat:(NSString *)dateFormat;
+(NSDate *)getDateObjectFromStringWithTimeString:(NSString *)timeStr andDateFormat:(NSString *)dateFormat andTimeZone:(NSTimeZone *)timeZone;
+(NSString *)getDateStringBeforeDays:(NSInteger)beforeDays andDateFormat:(NSString *)dateFormat;

//IMAGE
+(NSData *)compressImage:(UIImage *)image;
+ (UIImage *)resizeImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+(UIImage*)resizeImageAccordingToWidthWithImage:(UIImage*)sourceImage scaledToWidth:(float)i_width;
+(UIImage *)imageSnapshotFromText:(NSString *)text backgroundColor:(UIColor *)bgColor foreGroundColor:(UIColor *)textColor circular:(BOOL)isCircular textAttributes:(NSDictionary *)textAttributes andImageView:(UIImageView *)imageView;
+(NSString *)collectFirstLettersFromString:(NSString *)string;
+(UIColor *)randomColor;
+ (UIImage *) imageWithView:(UIView *)view;

//Array
+(NSMutableArray *)filterArrayWithArray:(NSMutableArray *)dataArray andKey:(NSString *)key andSeachText:(NSString *)searchText;

//Validation
+ (BOOL)isValidatePhone:(NSString *)phoneNumber;
+ (BOOL)isValidEmail:(NSString *)email;

//Checking Iphone
+ (BOOL)isIphone5;
+ (BOOL)isIphone6;
+ (BOOL)isIphone6P;


@end

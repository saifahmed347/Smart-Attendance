//
//  AppData.m
//  QuranIQ
//
//  Created by Samir on 12/01/2016.
//  Copyright © 2016 com. All rights reserved.
//


#import "AppData.h"
#import <QuartzCore/QuartzCore.h>

//#define NSLog(...)

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)


@implementation AppData


+ (NSString *)getDatabaseName{
    return @"smart_attendance_db_v1.2";
}

#pragma mark - UIView Operations

+ (void)setBorderWithView:(UIView *)view andBorderWidth:(float)width andBorderColor:(UIColor *)color andBorderRadius:(CGFloat)radius{
    
    view.layer.borderWidth = width;
    view.layer.borderColor = color.CGColor;
    view.layer.cornerRadius = radius;
    view.layer.masksToBounds = YES;
}

+ (void)drawShadowWithView:(UIView *)view{
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    view.layer.shadowOpacity = 0.5f;
    view.layer.shadowPath = shadowPath.CGPath;
}

+ (void)drawSideShadowWithView:(UIView *)view{
    view.layer.shadowColor = [UIColor purpleColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(5, 5);
    view.layer.shadowOpacity = 0.5;
    view.layer.shadowRadius = 1.0;
}

#pragma mark - Colors

+ (UIColor *)colorFromHexString:(NSString *)hexString andAlpha:(CGFloat)alpha {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:alpha];
}


#pragma mark - Date

+(NSString *)convertDateFormatWithTimeString:(NSString *)timeStr andInitialDateFormat:(NSString *)initialFormat andDesireDateFormat:(NSString *)desireFormat{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    dateFormatter.dateFormat = initialFormat; //@"HH:mm:ss";
    
    NSDate *date = [dateFormatter dateFromString:timeStr];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    dateFormatter.dateFormat = desireFormat; //@"hh:mm a";
    NSString *desiredDate = [dateFormatter stringFromDate:date];
    
    return desiredDate;
}

+(NSString *)getDateWithFormateString:(NSString *)format andDateObject:(NSDate *)dateObj{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setTimeZone:[NSTimeZone localTimeZone]];
    df.dateFormat = format;
    return [df stringFromDate:dateObj];
}

+(NSString *)getDateWithFormateString:(NSString *)format andDateObject:(NSDate *)dateObj andTimeZone:(NSTimeZone *)timeZone {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setTimeZone:timeZone];
    df.dateFormat = format;
    return [df stringFromDate:dateObj];
}


+(NSDate *)getDateObjectFromStringWithTimeString:(NSString *)timeStr andDateFormat:(NSString *)dateFormat{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    dateFormatter.dateFormat = dateFormat; //@"HH:mm:ss";
    NSDate *date = [dateFormatter dateFromString:timeStr];
    
    /*
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString *dd = [dateFormatter stringFromDate:date];
    NSLog(@"timeStr: %@, date: %@",timeStr, dd);
     */
    
    return date;
}

+(NSDate *)getDateObjectFromStringWithTimeString:(NSString *)timeStr andDateFormat:(NSString *)dateFormat andTimeZone:(NSTimeZone *)timeZone {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:timeZone];
    dateFormatter.dateFormat = dateFormat; //@"HH:mm:ss";
    NSDate *date = [dateFormatter dateFromString:timeStr];
    
    /*
     [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
     NSString *dd = [dateFormatter stringFromDate:date];
     NSLog(@"timeStr: %@, date: %@",timeStr, dd);
     */
    
    return date;
}


+(NSString *)getDateStringBeforeDays:(NSInteger)beforeDays andDateFormat:(NSString *)dateFormat {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    dateFormatter.dateFormat = dateFormat; //@"HH:mm:ss";
    
    NSInteger beforeSeconds = - ( beforeDays * 24 * 60 * 60 ) ;
    
    NSDate *now = [NSDate date];
    NSDate *someDaysAgoDate = [now dateByAddingTimeInterval:beforeSeconds];
    
    NSString *dateString = [dateFormatter stringFromDate:someDaysAgoDate];
    
    NSLog(@"dateString: %@", dateString);
    
    return dateString;
}


#pragma mark - Image

+(NSData *)compressImage:(UIImage *)image{
    
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    int maxFileSize = 40*1024;
    
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    
    while ([imageData length] > maxFileSize && compression > maxCompression)
    {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    
    return imageData;
}

+ (UIImage *)resizeImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


+(UIImage*)resizeImageAccordingToWidthWithImage:(UIImage*)sourceImage scaledToWidth:(float)i_width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+(UIImage *)imageSnapshotFromText:(NSString *)text backgroundColor:(UIColor *)bgColor foreGroundColor:(UIColor *)textColor circular:(BOOL)isCircular textAttributes:(NSDictionary *)textAttributes andImageView:(UIImageView *)imageView{
    
    if (!textAttributes) {
//        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
//            textAttributes = @{
//                               NSFontAttributeName: [UIFont systemFontOfSize:30.0 weight:0.5],
//                               NSForegroundColorAttributeName: textColor
//                               };
//        }else{
//            textAttributes = @{
//                               NSFontAttributeName: [UIFont systemFontOfSize:50.0 weight:1],
//                               NSForegroundColorAttributeName: textColor
//                               };
//            
//        }
        
        textAttributes = @{
                           NSFontAttributeName: [UIFont systemFontOfSize:30.0 weight:0.5],
                           NSForegroundColorAttributeName: textColor
                           };
    }
    
    CGFloat scale = [UIScreen mainScreen].scale;
    
    CGSize size = imageView.bounds.size;
    
    if (imageView.contentMode == UIViewContentModeScaleToFill ||
        imageView.contentMode == UIViewContentModeScaleAspectFill ||
        imageView.contentMode == UIViewContentModeScaleAspectFit ||
        imageView.contentMode == UIViewContentModeRedraw)
    {
        size.width = floorf(size.width * scale) / scale;
        size.height = floorf(size.height * scale) / scale;
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (isCircular) {
        //
        // Clip context to a circle
        //
        CGPathRef path = CGPathCreateWithEllipseInRect(imageView.bounds, NULL);
        CGContextAddPath(context, path);
        CGContextClip(context);
        CGPathRelease(path);
    }
    
    //
    // Fill background of context
    //
    CGContextSetFillColorWithColor(context, bgColor.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    
    //
    // Draw text in the context
    //
    text = [self collectFirstLettersFromString:text];
    CGSize textSize = [text sizeWithAttributes:textAttributes];
    CGRect bounds = imageView.bounds;
    
    [text drawInRect:CGRectMake(bounds.size.width/2 - textSize.width/2,
                                bounds.size.height/2 - textSize.height/2,
                                textSize.width,
                                textSize.height)
      withAttributes:textAttributes];
    
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return snapshot;
}


+(NSString *)collectFirstLettersFromString:(NSString *)string{
    
    NSMutableString *displayString = [NSMutableString stringWithString:@""];
    
    NSMutableArray *words = [[string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] mutableCopy];
    
    //
    // Get first letter of the first and last word
    //
    if ([words count]) {
        NSString *firstWord = [words firstObject];
        if ([firstWord length]) {
            // Get character range to handle emoji (emojis consist of 2 characters in sequence)
            NSRange firstLetterRange = [firstWord rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, 1)];
            [displayString appendString:[firstWord substringWithRange:firstLetterRange]];
        }
        
        if ([words count] >= 2) {
            NSString *lastWord = [words lastObject];
            
            while ([lastWord length] == 0 && [words count] >= 2) {
                [words removeLastObject];
                lastWord = [words lastObject];
            }
            
            if ([words count] > 1) {
                // Get character range to handle emoji (emojis consist of 2 characters in sequence)
                NSRange lastLetterRange = [lastWord rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, 1)];
                [displayString appendString:[lastWord substringWithRange:lastLetterRange]];
            }
        }
    }
    
    return displayString;
}

+(UIColor *)randomColor {
    
    srand48(arc4random());
    
    float red = 0.0;
    while (red < 0.1 || red > 0.84) {
        red = drand48();
    }
    
    float green = 0.0;
    while (green < 0.1 || green > 0.84) {
        green = drand48();
    }
    
    float blue = 0.0;
    while (blue < 0.1 || blue > 0.84) {
        blue = drand48();
    }
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}

+ (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}


#pragma mark Array

+(NSMutableArray *)filterArrayWithArray:(NSMutableArray *)dataArray andKey:(NSString *)key andSeachText:(NSString *)searchText {
    NSLog(@"dataArray : %@, search : %@", dataArray, searchText);
    
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"%@ CONTAINS[cd] %@", key, searchText];
    return [[dataArray filteredArrayUsingPredicate:resultPredicate] mutableCopy];
}


#pragma mark Validation

+ (BOOL)isValidatePhone:(NSString *)phoneNumber
{
    NSString *phoneRegex = @"^([0])[0-9]{10,10}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    
    return [phoneTest evaluateWithObject:phoneNumber];
}

+ (BOOL)isValidEmail:(NSString *)email {
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex];
    
    return [emailTest evaluateWithObject:email];
}


#pragma mark Check iphone modal

+ (BOOL)isIphone5 {
    return  IS_IPHONE_5;
}

+ (BOOL)isIphone6 {
    return  IS_IPHONE_6;
}

+ (BOOL)isIphone6P {
    return  IS_IPHONE_6P;
}



@end


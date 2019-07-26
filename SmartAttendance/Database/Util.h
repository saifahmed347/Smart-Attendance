//
//  Util.h
//  QuranPlus
//
//  Created by Samir on 14/03/2016.
//  Copyright © 2016 com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Util : NSObject

+(NSString *) getFilePath :(NSString *)fileName;
+(void) copyFile:(NSString *)file;
+(void)deleteFileFromCacheWithFileName:(NSString *)fileName;

@end

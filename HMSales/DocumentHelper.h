//
//  DocumentHelper.h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DocumentHelper : NSObject


+(NSString*)setDocumentPathForImage:(UIImage*)image;
+(NSString*)getDocumentPathForFile:(NSString*)fileName;

@end

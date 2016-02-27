/* -*- objc -*- */
#import <JavaScriptCore/JavaScriptCore.h>
#import <Foundation/Foundation.h>

@class File;

@protocol File_js_export <JSExport>

@property (nonatomic, copy) NSString *path;

+(instancetype)open:(NSString*)file;
-(void)close;

@end

@interface File : NSObject <File_js_export>

@property (nonatomic, copy) NSString *path;

@end

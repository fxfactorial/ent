/* -*- objc -*- */
#import <JavaScriptCore/JavaScriptCore.h>
#import <Foundation/Foundation.h>
#import <iostream>
#import <string>

#import "file.h"

@implementation File

+(instancetype)open:(NSString*)file;
{
  File *handle = [File new];
  std::cout << "Opened file\n";
  return handle;
}

-(void)close
{
  std::cout << "Closed file\n";
}

@end

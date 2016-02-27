/* -*- objc -*- */
#import <dispatch/dispatch.h>
#import <JavaScriptCore/JSValue.h>
#import <Foundation/Foundation.h>
#import <iostream>

int main(int argc, char **argv)
{
  dispatch_async(dispatch_get_main_queue(), ^{
      NSLog(@"Test Test");
      std::cout << "Hello World Again\n";
      exit(0);
    });
  dispatch_main();
}

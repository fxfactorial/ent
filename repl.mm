/* -*- objc -*- */
#import <JavaScriptCore/JavaScriptCore.h>
#import <iostream>
#import <string>

#import "utils.h"
#import "file.h"

using namespace std;

static const string ent_version = "0.0.1";

void start_repl(void)
{
  string line;
  cout << colorize ("Welcome to Ent: " + ent_version) << endl;
  cout << ">> ";

  JSContext *repl_context =
    [[JSContext alloc]
	initWithVirtualMachine:[[JSVirtualMachine alloc] init]];

  repl_context[@"File"] = [File class];
  repl_context[@"require"] = ^id(NSString *mod_wanted) {
    if ([mod_wanted isEqualToString:@"fs"]) {
      return [File class];
    }
    return nil;
  };

  while (std::getline(cin, line)) {
    if (line == "exit") {
      cout << colorize("Thank you goodbye\n");
      exit(0);
    }
    JSValue *result =
      [repl_context evaluateScript:
		      [NSString stringWithUTF8String:line.c_str()]];
    std::cout << [[result toString] UTF8String];
    cout << "\n>> ";
  }
}

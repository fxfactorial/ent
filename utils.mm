/* -*- objc -*- */
#import <iostream>
#import <string>

#import "utils.h"

using namespace std;

string colorize(string message)
{
  string result;
  result += "\033[1;34m";
  result += message;
  result += "\033[0m";
  return result;
}

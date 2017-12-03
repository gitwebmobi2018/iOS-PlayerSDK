#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TRAutocompleteItemsSource.h"

@interface ZixiSuggestion : NSObject <TRSuggestionItem>

@property(nonatomic) NSString *suggestion;

- (id)initWith:(NSString *)address;
- (NSString *)completionText;

@end

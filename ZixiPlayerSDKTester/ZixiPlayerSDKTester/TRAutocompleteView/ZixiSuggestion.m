#import "ZixiSuggestion.h"

@implementation ZixiSuggestion

- (id)initWith:(NSString *)suggestion
{
    self = [super init];
    if (self)
        self.suggestion = suggestion;

    return self;
}

- (NSString *)completionText
{
    return self.suggestion;
}

@end

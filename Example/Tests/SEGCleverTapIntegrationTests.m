
@import Quick;
@import Nimble;
@import OCMock;
@import CleverTapSDK;
@import Segment_CleverTap;


@interface SEGCleverTapIntegration (UnitTests)
- (void)launchWithAccountId:(NSString *)accountID token:(NSString *)accountToken region:(NSString *)region;
- (void)identify:(SEGIdentifyPayload *)payload;
- (void)onUserLogin:(NSDictionary *)profile;
@end


QuickSpecBegin(SEGCleverTapIntegrationSpec)

describe(@"a Segment CleverTap integration class", ^{
   
    it(@"is initialized with settings", ^{

        NSDictionary *settingsDict = @{ @"clevertap_account_id": @"ABC",
                                        @"clevertap_account_token": @"001",
                                        @"region": @"Region" };

        SEGCleverTapIntegration *integration = [[SEGCleverTapIntegration alloc] initWithSettings:settingsDict];

        expect(integration.settings).to(equal(settingsDict));
    });

    it(@"returns nil for nil settings values", ^{

        NSDictionary *settingsDict = @{ @"key": @"value" };

        SEGCleverTapIntegration *integration = [[SEGCleverTapIntegration alloc] initWithSettings:settingsDict];

        expect(integration.settings).to(beNil());
    });

    it(@"initialized from non-main threads", ^{

        NSDictionary *settingsDict = @{ @"clevertap_account_id": @"ABC",
                                        @"clevertap_account_token": @"001",
                                        @"region": @"Region" };

        __block SEGCleverTapIntegration *integration;

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            integration = [[SEGCleverTapIntegration alloc] initWithSettings:settingsDict];
        });

        expect(integration.settings).toEventually(equal(settingsDict));
    });
});

describe(@"a Segment CleverTap integration  conforming to SEGIntegration protocol", ^{
    
    __block  SEGCleverTapIntegration *integration;
    beforeEach(^{
        NSDictionary *settingsDict = @{ @"clevertap_account_id": @"ABC",
                                        @"clevertap_account_token": @"001",
                                        @"region": @"Region" };

       integration = [[SEGCleverTapIntegration alloc] initWithSettings:settingsDict];
    });
    
    afterEach(^{
        integration = nil;
    });
    
    context(@"when a user is identified", ^{
        
        it(@"performs user login with payload", ^{
            
            id mock = OCMPartialMock(integration);
            
            OCMExpect([mock onUserLogin:[OCMArg any]]);
            
             NSDictionary * mockTraits = @{ @"address": @{ @"city": @"Mumbai", @"country": @"India" },
                                            @"anonymousId": @"C790B642-DC43-4345-AA40-82D6074BEF94",
                                            @"bool": @(YES),
                                            @"double": @"3.14159",
                                            @"email": @"support@clevertap.com",
                                            @"floatAttribute": @"12.3",
                                            @"gender": @"female",
                                            @"intAttributes": @18,
                                            @"integerAttribute": @200,
                                            @"name": @"Segment CleverTap",
                                            @"phone": @"+91981234567",
                                            @"shortAttribute": @2,
                                            @"stringInt": @1,
                                            @"birthday": @"01-Mar-1990",
                                            @"testArr": @[ @1, @2, @3 ]
                                          };
            
            SEGIdentifyPayload *payload = [[SEGIdentifyPayload alloc] initWithUserId:@"userID"
                                                                         anonymousId:@"C790B642-DC43-4345-AA40-82D6074BEF94"
                                                                              traits:mockTraits
                                                                             context:@{ @"key": @"value" }
                                                                        integrations:@{ @"key": @"value" }];
            
            [mock identify:payload];
            
            OCMVerifyAll(mock);
        });
        
        it(@"does not performs user login if no traits in payload", ^{
            
            id mock = OCMPartialMock(integration);
            
            OCMReject([mock onUserLogin:[OCMArg any]]);
            
            id mockPayload = OCMClassMock([SEGIdentifyPayload class]);
            
            [mock identify:mockPayload];
            
            OCMVerifyAll(mock);
        });
    });
    
    context(@"when a screen is tracked", ^{
        
        it(@"should fire recordScreenView on CleverTap instance", ^{
            
            id mockIntegration = OCMPartialMock(integration);
            id mockCleverTap = OCMPartialMock([CleverTap sharedInstance]);
            
            OCMExpect([mockCleverTap recordScreenView:@"root_screen"]);
            
            SEGScreenPayload *payload = [[SEGScreenPayload alloc] initWithName:@"root_screen"
                                                                    properties:nil
                                                                       context:@{ @"key": @"value" }
                                                                  integrations:@{ @"key": @"value" }];
            
            [mockIntegration screen:payload];
            
            OCMVerifyAll(mockIntegration);
            OCMVerifyAll(mockCleverTap);
        });
        
        it(@"if screen name is empty, should not fire recordScreenView", ^{
            
            id mockIntegration = OCMPartialMock(integration);
            id mockCleverTap = OCMPartialMock([CleverTap sharedInstance]);
            
            OCMReject([mockCleverTap recordScreenView:[OCMArg any]]);
            
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wnonnull"
            
            SEGScreenPayload *payload = [[SEGScreenPayload alloc] initWithName:nil
                                                                    properties:nil
                                                                       context:@{ @"key": @"value" }
                                                                  integrations:@{ @"key": @"value" }];

            #pragma clang diagnostic pop
            
            [mockIntegration screen:payload];
            
            OCMVerifyAll(mockIntegration);
            OCMVerifyAll(mockCleverTap);
        });
    });
});

QuickSpecEnd

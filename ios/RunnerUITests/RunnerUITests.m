@import XCTest;
@import patrol;
@import ObjectiveC.runtime;

#if !defined(PATROL_INTEGRATION_TEST_IOS_RUNNER)
#import "PatrolIntegrationTestIosRunner.h"
#endif

// CF-123 — runner XCTest do Patrol (SPM / FlutterGeneratedPluginSwiftPackage).
PATROL_INTEGRATION_TEST_IOS_RUNNER(RunnerUITests)

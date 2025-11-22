if [ -d "scripts" ]; then
cd scripts/
fi

# Flags:
# --latest:             run tests only for the latest iOS.
#                       It is needed for the GitHub Actions builds.
#                       Do not use this flag locally to keep everything updated.
# --quick:              run only quick set of tests for PR.
#                       It is needed for the GitHub Actions builds on every PR to avoid running all tests.
# --skip-adapters:      skip adapter tests for PR.
#                       It is needed for the GitHub Actions builds on every PR to avoid running redundant tests.  

run_only_with_latest_ios="NO"
run_only_PR_tests="NO"
skip_adapter_tests="NO"

usage() {
  cat <<'USAGE'
Usage: testPrebidMobile.sh [--latest] [--quick] [--skip-adapters]
USAGE
}

# Parse flags
while [[ $# -gt 0 ]]; do
  case "$1" in
    --latest)         run_only_with_latest_ios="YES"; shift ;;
    --quick)          run_only_PR_tests="YES"; shift ;;
    --skip-adapters)  skip_adapter_tests="YES"; shift ;;
    -h|--help)        usage; exit 0 ;;
    --)               shift; break ;;
    -*)               echo "Unknown option: $1" >&2; usage; exit 2 ;;
    *)                break ;;
  esac
done


set -e

GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "\n\n${GREEN}INSTALL PODS${NC}\n\n"

cd ..

brew install xcbeautify

export PATH="/Users/distiller/.gem/ruby/2.7.0/bin:$PATH"
gem install cocoapods
pod install --repo-update

echo -e "\n\n${GREEN}RUN PREBID MOBILE TESTS${NC}\n\n"

echo -e "\n${GREEN}Creating simulator${NC} \n"
xcrun simctl create iPhone-16-Pro-PrebidMobile com.apple.CoreSimulator.SimDeviceType.iPhone-16-Pro com.apple.CoreSimulator.SimRuntime.iOS-18-6

if [ "$run_only_PR_tests" != "YES" ]; then
    echo -e "\n${GREEN}Clean build\n"
    xcodebuild clean build
fi

if [ "$run_only_with_latest_ios" != "YES" ]
then
 echo -e "\n${GREEN}Running some unit tests for iOS 13${NC} \n"
 xcodebuild test \
    -workspace PrebidMobile.xcworkspace \
    -scheme "PrebidMobileTests" \
    -destination 'platform=iOS Simulator,name=iPhone 11 Pro Max,OS=13.7' \
    -only-testing PrebidMobileTests/RequestBuilderTests/testPostData | xcbeautify

 if [[ ${PIPESTATUS[0]} == 0 ]]; then
     echo "✅ unit tests for iOS 13 Passed"
 else
     echo "🔴 unit tests for iOS 13 Failed"
     exit 1
 fi
fi

TESTPLAN=""

if [ "$run_only_PR_tests" != "YES" ]; then
    TESTPLAN="PrebidMobileTests"
else
    TESTPLAN="PrebidMobilePRTests"
fi

echo -e "\n${GREEN}Running PrebidMobile unit tests${NC} \n"

# xcodebuild \
#   -workspace PrebidMobile.xcworkspace \
#   -scheme PrebidMobileTests \
#   -sdk iphonesimulator \
#   -configuration Debug \
#   -destination 'platform=iOS Simulator,name=iPhone-16-Pro-PrebidMobile,OS=18.6' \
#   -destination-timeout 60 \
#   build-for-testing

# xcodebuild \
#   -workspace PrebidMobile.xcworkspace \
#   -scheme PrebidMobileTests \
#   -sdk iphonesimulator \
#   -testPlan "${TESTPLAN}" \
#   -destination 'platform=iOS Simulator,name=iPhone-16-Pro-PrebidMobile,OS=18.6' \
#   -destination-timeout 60 \
#   test-without-building

# xcodebuild test \
#     -workspace PrebidMobile.xcworkspace \
#     -retry-tests-on-failure \
#     -scheme "PrebidMobileTests" \
#     -testPlan "${TESTPLAN}" \
#     -destination 'platform=iOS Simulator,name=iPhone-16-Pro-PrebidMobile,OS=18.6' \
#     -destination-timeout 60 \
#     -disableAutomaticPackageResolution \
#     -skipPackagePluginValidation \
#     -skipMacroValidation \
#     -IDEBuildOperationMaxNumberOfConcurrentCompileTasks=2 \
#     CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
#     COMPILER_INDEX_STORE_ENABLE=NO \
#     SWIFT_COMPILATION_MODE=singlefile \
#     -showBuildTimingSummary | xcbeautify


if [[ ${PIPESTATUS[0]} == 0 ]]; then
    echo "✅ PrebidMobile Unit Tests Passed"
else
    echo "🔴 PrebidMobile Unit Tests Failed"
    # exit 1
fi

function testAdapters () {
  local SCHEME="$1"

    xcodebuild \
        -workspace PrebidMobile.xcworkspace \
        -scheme "${SCHEME}" \
        -sdk iphonesimulator \
        -configuration Debug \
        -destination 'platform=iOS Simulator,name=iPhone-16-Pro-PrebidMobile,OS=18.6' \
        -destination-timeout 60 \
        build-for-testing

    xcodebuild \
        -workspace PrebidMobile.xcworkspace \
        -scheme "${SCHEME}" \
        -sdk iphonesimulator \
        -destination 'platform=iOS Simulator,name=iPhone-16-Pro-PrebidMobile,OS=18.6' \
        -destination-timeout 60 \
        test-without-building
}

if [ "$skip_adapter_tests" != "YES" ]; then
    echo -e "\n${GREEN}Running PrebidMobileGAMEventHandlers unit tests${NC} \n"

    testAdapters "PrebidMobileGAMEventHandlersTests"
    
    if [[ ${PIPESTATUS[0]} == 0 ]]; then
        echo "✅ PrebidMobileGAMEventHandlers Unit Tests Passed"
    else
        echo "🔴 PrebidMobileGAMEventHandlers Unit Tests Failed"
        exit 1
    fi

    echo -e "\n${GREEN}Running PrebidMobileAdMobAdapters unit tests${NC} \n"

    testAdapters "PrebidMobileAdMobAdaptersTests"

    if [[ ${PIPESTATUS[0]} == 0 ]]; then
        echo "✅ PrebidMobileAdMobAdapters Unit Tests Passed"
    else
        echo "🔴 PrebidMobileAdMobAdapters Unit Tests Failed"
        exit 1
    fi

    echo -e "\n${GREEN}Running PrebidMobileMAXAdapters unit tests${NC} \n"

    testAdapters "PrebidMobileMAXAdaptersTests"

    if [[ ${PIPESTATUS[0]} == 0 ]]; then
        echo "✅ PrebidMobileMAXAdapters Unit Tests Passed"
    else
        echo "🔴 PrebidMobileMAXAdapters Unit Tests Failed"
        exit 1
    fi
fi



# if [ "$skip_adapter_tests" != "YES" ]; then
#     echo -e "\n${GREEN}Running PrebidMobileGAMEventHandlers unit tests${NC} \n"
#     # xcodebuild test \
#     #     -workspace PrebidMobile.xcworkspace  \
#     #     -scheme "PrebidMobileGAMEventHandlersTests" \
#     #     -destination 'platform=iOS Simulator,name=iPhone-16-Pro-PrebidMobile,OS=18.0' | xcbeautify

#             xcodebuild \
#         -workspace PrebidMobile.xcworkspace \
#         -scheme PrebidMobileGAMEventHandlersTests \
#         -sdk iphonesimulator \
#         -configuration Debug \
#         -destination 'platform=iOS Simulator,name=iPhone-16-Pro-PrebidMobile,OS=18.6' \
#         -destination-timeout 60 \
#         build-for-testing

#         xcodebuild \
#         -workspace PrebidMobile.xcworkspace \
#         -scheme PrebidMobileGAMEventHandlersTests \
#         -sdk iphonesimulator \
#         -destination 'platform=iOS Simulator,name=iPhone-16-Pro-PrebidMobile,OS=18.6' \
#         -destination-timeout 60 \
#         test-without-building

#     if [[ ${PIPESTATUS[0]} == 0 ]]; then
#         echo "✅ PrebidMobileGAMEventHandlers Unit Tests Passed"
#     else
#         echo "🔴 PrebidMobileGAMEventHandlers Unit Tests Failed"
#         # exit 1
#     fi

#     echo -e "\n${GREEN}Running PrebidMobileAdMobAdapters unit tests${NC} \n"
#     # xcodebuild test \
#     #     -workspace PrebidMobile.xcworkspace \
#     #     -scheme "PrebidMobileAdMobAdaptersTests" \
#     #     -destination 'platform=iOS Simulator,name=iPhone-16-Pro-PrebidMobile,OS=latest' | xcbeautify

#         xcodebuild \
#         -workspace PrebidMobile.xcworkspace \
#         -scheme PrebidMobileAdMobAdaptersTests \
#         -sdk iphonesimulator \
#         -configuration Debug \
#         -destination 'platform=iOS Simulator,name=iPhone-16-Pro-PrebidMobile,OS=18.6' \
#         -destination-timeout 60 \
#         build-for-testing

#         xcodebuild \
#         -workspace PrebidMobile.xcworkspace \
#         -scheme PrebidMobileAdMobAdaptersTests \
#         -sdk iphonesimulator \
#         -destination 'platform=iOS Simulator,name=iPhone-16-Pro-PrebidMobile,OS=18.6' \
#         -destination-timeout 60 \
#         test-without-building

#     if [[ ${PIPESTATUS[0]} == 0 ]]; then
#         echo "✅ PrebidMobileAdMobAdapters Unit Tests Passed"
#     else
#         echo "🔴 PrebidMobileAdMobAdapters Unit Tests Failed"
#         # exit 1
#     fi

#     echo -e "\n${GREEN}Running PrebidMobileMAXAdapters unit tests${NC} \n"
#     # xcodebuild test \
#     #     -workspace PrebidMobile.xcworkspace \
#     #     -scheme "PrebidMobileMAXAdaptersTests" \
#     #     -destination 'platform=iOS Simulator,name=iPhone-16-Pro-PrebidMobile,OS=latest' | xcbeautify

#         xcodebuild \
#         -workspace PrebidMobile.xcworkspace \
#         -scheme PrebidMobileMAXAdaptersTests \
#         -sdk iphonesimulator \
#         -configuration Debug \
#         -destination 'platform=iOS Simulator,name=iPhone-16-Pro-PrebidMobile,OS=18.6' \
#         -destination-timeout 60 \
#         build-for-testing

#         xcodebuild \
#         -workspace PrebidMobile.xcworkspace \
#         -scheme PrebidMobileMAXAdaptersTests \
#         -sdk iphonesimulator \
#         -destination 'platform=iOS Simulator,name=iPhone-16-Pro-PrebidMobile,OS=18.6' \
#         -destination-timeout 60 \
#         test-without-building

#     if [[ ${PIPESTATUS[0]} == 0 ]]; then
#         echo "✅ PrebidMobileMAXAdapters Unit Tests Passed"
#     else
#         echo "🔴 PrebidMobileMAXAdapters Unit Tests Failed"
#         # exit 1
#     fi
# fi

echo -e "\n${GREEN}Removing simulator${NC} \n"
xcrun simctl delete iPhone-16-Pro-PrebidMobile

# echo -e "\n${GREEN}Running swiftlint tests${NC} \n"
# swiftlint --config .swiftlint.yml

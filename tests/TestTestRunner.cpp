#include <juce_unit_test/juce_unit_test.h>

class TestTestRunner : public juce::UnitTest {
public:
    TestTestRunner() : juce::UnitTest("TestTestRunner") {}

    void runTest() override {
        beginTest("Basic assertion");
        expectEquals(1 + 1, 2);
        expect(2 > 1);
        expectEquals(std::string("abc"), std::string("abc"));
    }
};

static TestTestRunner testTestRunnerInstance;

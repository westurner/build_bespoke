cmake_minimum_required(VERSION 3.10)
project(BespokeSynthTests)

set(CMAKE_CXX_STANDARD 17)

# JUCE modules path (adjust as needed)
set(JUCE_MODULES_PATH "../BespokeSynth/libs/JUCE/modules")

add_definitions(-DJUCE_GLOBAL_MODULE_SETTINGS_INCLUDED=1)
add_executable(TestRunner TestRunner.cpp SavestatePathTest.cpp JuceLibraryCode.cpp)
target_link_libraries(TestRunner pthread dl curl)

# Add stub test modules here as they are created

# JUCE include directories
include_directories(
    ${JUCE_MODULES_PATH}
    ../BespokeSynth/Source
)

# Link JUCE modules (adjust as needed)
target_link_libraries(TestRunner
    # juce_core juce_events juce_unit_test
)


#include <juce_core/juce_core.h>

// Mock ofToDataPath for testing
std::string ofToDataPath(const std::string& path) {
    // strict mock: assume root is /mock_root/
    if (path.empty()) return "/mock_root/";
    
    // Check if absolute (simple check for / or start)
    if (path.front() == '/') return path;
    
    // Append to root
    if (path.back() == '/') return "/mock_root/" + path;
    return "/mock_root/" + path;
}

#define BESPOKE_UNIT_TESTS
#include "../BespokeSynth/Source/FileUtils.cpp"

using namespace juce;

class SavestatePathTest : public UnitTest
{
public:
    SavestatePathTest() : UnitTest("SavestatePathTest") {}

    void runTest() override
    {
        beginTest("Default Path");
        {
            String result = getDirectoryOrDefault("", "savestate/");
            expectEquals(result, String("/mock_root/savestate/"));
        }

        beginTest("Current Savestate Path Exists");
        {
            // Simulate a current savestate at "savestate/autosave/autosave.bsk"
            // ofToDataPath("savestate/autosave/autosave.bsk") -> "/mock_root/savestate/autosave/autosave.bsk"
            // getParentDirectory -> "/mock_root/savestate/autosave"
            String result = getDirectoryOrDefault("savestate/autosave/autosave.bsk", "savestate/");
            expectEquals(result, String("/mock_root/savestate/autosave"));
        }
        
        beginTest("Current Savestate Path in Subfolder");
        {
             String result = getDirectoryOrDefault("projects/my_song.bsk", "savestate/");
             expectEquals(result, String("/mock_root/projects"));
        }
        
        beginTest("Current Savestate Path is Absolute");
        {
            // If absolute path is passed
            String result = getDirectoryOrDefault("/abs/path/song.bsk", "savestate/");
            expectEquals(result, String("/abs/path"));
        }
    }
};

static SavestatePathTest test;

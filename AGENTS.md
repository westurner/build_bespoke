# Build Bespoke Agents

This document describes the available agents, automation tasks, and build targets for the BespokeSynth development environment.

## Development Environment

### Dev Container Configuration

**Container Name:** `buildbespoke_devcontainer`  
**Container Image:** `westurner/bespokesynthsrc:44`  
**Reference:** [devcontainer.json](.devcontainer/devcontainer.json)

#### Build Requirements:
- CMake 3.10+
- C++17 compiler
- JUCE framework (v7.0.12)
- ALSA, FreeType2, X11, XExt, Xinerama, XRandR, XCursor (Linux)
- pthread, libdl, libcurl
- Code coverage tools: `lcov`, `genhtml` (for coverage reports)


## Build Agents

### Core Build Targets

#### `make build`
Builds BespokeSynth from source using the build script.
```bash
sh ./build_bespoke.sh --build
```

#### `make podman-build`
Builds the Docker/Podman container image.
```bash
podman build -t westurner/bespokesynthsrc:43 -f Dockerfile.bespoke
```

---

## Runtime Agents

### Application Execution

#### `make run`
Runs the compiled BespokeSynth application.
```bash
./BespokeSynth/ignore/build/Source/BespokeSynth_artefacts/Release/BespokeSynth
```

#### `make runhelp`
Displays BespokeSynth command-line help.
```bash
./BespokeSynth/ignore/build/Source/BespokeSynth_artefacts/Release/BespokeSynth --help
```

---

## Test Agents

### Test Infrastructure

**Location:** [BespokeSynth/tests/CMakeLists.txt](BespokeSynth/tests/CMakeLists.txt)  
**Test Binary:** `BespokeSynth/tests/build/TestRunner`  
**Configuration:** CMake (C++17, JUCE modules)

#### Included Test Suites:
- **FileUtilsTest.cpp** - File utility functions testing
- **ArgsParserTest.cpp** - Command-line argument parsing tests
- **LoggingTest.cpp** - Logging system tests
- **TestTestRunner.cpp** - Test framework verification
- **VSTScannerTest.cpp** - VST plugin scanner tests

### Local Testing

#### `make test`
Builds and runs all tests in the TestRunner.
```bash
$(MAKE) -C BespokeSynth/tests/build
$(MAKE) runtest
```

#### `make runtest`
Executes the test runner.
```bash
BespokeSynth/tests/build/TestRunner
```

#### `make runtest-v`
Runs tests in verbose mode with detailed output.
```bash
BespokeSynth/tests/build/TestRunner -v
```

#### `make runtesthelp`
Displays TestRunner help information and available options.
```bash
BespokeSynth/tests/build/TestRunner -h
```

#### `make test-xunit`
Runs tests and generates JUnit XML test results for CI/CD integration.
```bash
$(MAKE) -C BespokeSynth/tests/build
BespokeSynth/tests/build/TestRunner --xunit-xml=test_results.xml
```
Output: `test_results.xml` (JUnit XML format)

#### `make test-coverage`
Runs tests with code coverage analysis and generates HTML report.
- Enables `-DENABLE_COVERAGE=ON` CMake flag
- Compiles with coverage instrumentation (`-fprofile-instr-generate -fcoverage-mapping` for Clang or `--coverage` for GCC)
- Generates coverage info with `lcov --capture`
- Creates HTML coverage report with `genhtml`
- **Output:** `coverage_report/index.html` (HTML coverage report)

---

## Container Management Agents

### Podman Container Execution

#### `make podman-run`
Launches an interactive bash shell in the container with development environment configured.
- Rootless container configuration
- Volume mounts for workspace access
- GPU, audio, and display support
- User context preservation

#### `make podman-run-run`
Runs BespokeSynth inside the Podman container.
- Automatically sets up savestate directory symlinks
- Parameters:
  - `BS_ARGS`: Additional arguments for BespokeSynth
  - `BS_FILE`: Path to BespokeSynth project file
  - `BS_BIN_PATH`: Path to BespokeSynth executable

#### `make podman-run-buildbespoke`
Builds BespokeSynth inside a Podman container using the origin repository.
```bash
GIT_REPO_URL=https://github.com/bespokesynth/bespokesynth
GIT_REPO_BRANCH=main
```

#### `make podman-run-buildbespoke-westurner`
Builds BespokeSynth inside a Podman container using the westurner fork.
```bash
GIT_REPO_URL=https://github.com/westurner/bespokesynth
GIT_REPO_BRANCH=main
```

---

## Configuration & Customization

### CMake Configuration

**Build Directory:** `BespokeSynth/tests/build/`

#### CMake Flags:
- `ENABLE_COVERAGE`: Enable code coverage instrumentation (default: OFF)
  - GCC: Uses `--coverage` flag
  - Clang: Uses `-fprofile-instr-generate -fcoverage-mapping` flags

### Makefile Variables

Key variables that can be customized:

- `CONTAINER_NAME`: Docker/Podman image name (default: `westurner/bespokesynthsrc:43`)
- `PODMAN`: Container runtime command (default: `podman`)
- `BS_REPO_URL`: Git repository URL for building BespokeSynth
- `BS_REPO_BRANCH`: Git branch to build (default: `main`)
- `PODMAN_VOLUMES_EXTRA`: Additional volume mounts for containers
- `BS_ARGS`: Additional BespokeSynth command-line arguments
- `BS_FILE`: BespokeSynth project file path

---

## Quick Reference

| Task | Command | Purpose |
|------|---------|---------|
| **Build** | `make build` | Build BespokeSynth from source |
| **Run** | `make run` | Execute BespokeSynth |
| **Test** | `make test` | Run full test suite |
| **Coverage** | `make test-coverage` | Generate code coverage report |
| **Container Build** | `make podman-build` | Build container image |
| **Container Shell** | `make podman-run` | Interactive container shell |
| **GPU Setup** | `make nvidia-ctk-cdi-generate` | Configure GPU access |

---

## Helper Commands

- `make` or `make help`: Display this Makefile
- `make runhelp`: Show BespokeSynth command-line options
- `make runtesthelp`: Show test runner options

---

## Build Artifacts

### Application
- **Executable:** `./BespokeSynth/ignore/build/Source/BespokeSynth_artefacts/Release/BespokeSynth`

### Testing
- **Test Binary:** `./BespokeSynth/tests/build/TestRunner`
- **Test Results (XUnit):** `test_results.xml` (JUnit XML format)
- **Coverage Data:** `coverage.info` (LCOV format)
- **Coverage Report:** `coverage_report/index.html` (HTML report)

### Build System
- **CMake Files:** [CMakeLists.txt](BespokeSynth/tests/CMakeLists.txt)
- **Build Configuration:** `BespokeSynth/tests/build/` (generated after cmake)

---

## Documentation References

- [Makefile](Makefile)
- [Dev Container Configuration](.devcontainer/devcontainer.json)
- [Docker Configuration](Dockerfile.bespoke)
- [Build Script](build_bespoke.sh)
- [Test CMake Configuration](BespokeSynth/tests/CMakeLists.txt)
- [BespokeSynth Repository](https://github.com/bespokesynth/bespokesynth)

---

## Notes

- Build artifacts are stored in the `ignore/` directory structure
- All test modules (JUCE modules) are compiled as part of the TestRunner build
- Coverage support requires either GCC or Clang compiler with coverage instrumentation
- Tests are built separately from the main application in `BespokeSynth/tests/build/`
- Linux builds require system dependencies: ALSA, FreeType2, X11 libraries, and XRandR


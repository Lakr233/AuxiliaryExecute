@testable import AuxiliaryExecute
import XCTest

final class AuxiliaryExecuteTests: XCTestCase {
    func testMain() throws {
        XCTAssertNotNil(Int(exactly: AuxiliaryExecute.maxTimeoutValue))
        XCTAssertNotNil(Int32(exactly: AuxiliaryExecute.maxTimeoutValue))
        XCTAssertNotNil(Double(exactly: AuxiliaryExecute.maxTimeoutValue))
        XCTAssertNotNil(TimeInterval(exactly: AuxiliaryExecute.maxTimeoutValue))

        do {
            let result = AuxiliaryExecute.local.bash(command: "printf \"\nnya\n\"")
            print(result)
            XCTAssert(result.exitCode == 0)
            XCTAssertNil(result.error)
            XCTAssert(result.stdout == "\nnya\n")
            XCTAssert(result.stderr == "")
        }

        do {
            let result = AuxiliaryExecute.local.shell(
                command: "bash",
                args: ["-c", "echo $mua"],
                environment: ["mua": "nya"],
                timeout: 0
            ) { stdout in
                print(stdout)
            } stderrBlock: { stderr in
                print(stderr)
            }

            XCTAssert(result.exitCode == 0)
            XCTAssertNil(result.error)
            XCTAssert(result.stdout.trimmingCharacters(in: .whitespacesAndNewlines) == "nya")
            XCTAssert(result.stderr == "")
        }

        do {
            let result = AuxiliaryExecute.local.shell(
                command: "bash",
                args: ["-c", "echo $mua"],
                environment: ["mua": "nya=nya="],
                timeout: 0
            ) { stdout in
                print(stdout)
            } stderrBlock: { stderr in
                print(stderr)
            }

            XCTAssert(result.exitCode == 0)
            XCTAssertNil(result.error)
            XCTAssert(result.stdout.trimmingCharacters(in: .whitespacesAndNewlines) == "nya=nya=")
            XCTAssert(result.stderr == "")
        }

        do {
            let result = AuxiliaryExecute.local.shell(
                command: "tail",
                args: ["-f", "/dev/null"],
                timeout: 1
            ) { stdout in
                print(stdout)
            } stderrBlock: { stderr in
                print(stderr)
            }

            XCTAssert(result.exitCode == SIGKILL)
            XCTAssert(result.error == .timeout)
        }
        
        do {
            chdir("/")
            let name = "test_\(UUID().uuidString)"
            let url = URL(fileURLWithPath: "/tmp")
                .appendingPathComponent(name)
            try? FileManager.default.removeItem(at: url)
            let result = AuxiliaryExecute.spawn(command: "/bin/mkdir", args: [name], workingDirectory: "/tmp")
            print(result)
            XCTAssert(result.exitCode == 0)
            XCTAssertNil(result.error)
            XCTAssert(FileManager.default.fileExists(atPath: url.path))
            try? FileManager.default.removeItem(at: url)
        }
    }

    @available(macOS 12.0.0, *)
    func testAsync() async throws {
        do {
            if #available(iOS 15.0, *) {
                let result = await AuxiliaryExecute.spawnAsync(
                    command: "/usr/bin/uname",
                    args: ["-a"],
                    timeout: 1
                ) { stdout in
                    print(stdout)
                } stderrBlock: { stderr in
                    print(stderr)
                }
                
                XCTAssertEqual(result.exitCode, 0)
                XCTAssert(result.stdout.contains("Darwin Kernel"))
            }
        }

        do {
            if #available(iOS 15.0, *) {
                let result = await AuxiliaryExecute.spawnAsync(
                    command: "/usr/bin/tail",
                    args: ["-f", "/dev/null"],
                    timeout: 1
                ) { stdout in
                    print(stdout)
                } stderrBlock: { stderr in
                    print(stderr)
                }
                
                XCTAssertEqual(result.exitCode, Int(SIGKILL))
                XCTAssertEqual(result.error, .timeout)
            }
        }
    }
}

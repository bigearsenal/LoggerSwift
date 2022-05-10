import XCTest
@testable import LoggerSwift

final class LoggerSwiftTests: XCTestCase {
    
    override func setUpWithError() throws {
        Logger.isOn = true
        Logger.filters = .init()
        Logger.dateFormat = "yyyy-MM-dd hh:mm:ssSSS"
    }
    
    func testEmptyFilters() throws {
        XCTAssertEqual(Logger.shouldLog(event: .error, message: ""), true)
        XCTAssertEqual(Logger.shouldLog(event: .info, message: ""), true)
        XCTAssertEqual(Logger.shouldLog(message: "test12345"), true)
        XCTAssertEqual(Logger.shouldLog(message: "tes12334"), true)
        XCTAssertEqual(Logger.shouldLog(message: "df1234test5"), true)
        XCTAssertEqual(Logger.shouldLog(message: "", fileName: #file), true)
        XCTAssertEqual(Logger.shouldLog(message: "", funcName: #function), true)
        XCTAssertEqual(Logger.shouldLog(event: .error, message: "test2324"), true)
        XCTAssertEqual(Logger.shouldLog(event: .info, message: "test2324"), true)
        XCTAssertEqual(Logger.shouldLog(event: .error, message: "2324"), true)
        XCTAssertEqual(Logger.shouldLog(event: .error, message: "2324", fileName: "Test.swift"), true)
    }
    
    func testEventFilters() throws {
        Logger.filters = .init(event: .init(includes: [.error]))
        XCTAssertEqual(Logger.shouldLog(event: .error, message: ""), true)
        XCTAssertEqual(Logger.shouldLog(event: .info, message: ""), false)
        
        Logger.filters = .init(event: .init(includes: [.error], notIncludes: [.info]))
        XCTAssertEqual(Logger.shouldLog(event: .error, message: ""), true)
        XCTAssertEqual(Logger.shouldLog(event: .info, message: ""), false)
        
        Logger.filters = .init(event: .init(notIncludes: [.error]))
        XCTAssertEqual(Logger.shouldLog(event: .error, message: ""), false)
        XCTAssertEqual(Logger.shouldLog(event: .info, message: ""), true)
        
        // Conflicted filter
        Logger.filters = .init(event: .init(includes: [.error], notIncludes: [.error, .info]))
        XCTAssertEqual(Logger.shouldLog(event: .error, message: ""), false)
        XCTAssertEqual(Logger.shouldLog(event: .info, message: ""), false)
    }
    
    func testMessageFilters() throws {
        Logger.filters = .init(messageContains: .init(includes: ["test"]))
        XCTAssertEqual(Logger.shouldLog(message: "test12345"), true)
        XCTAssertEqual(Logger.shouldLog(message: "tes12334"), false)
        XCTAssertEqual(Logger.shouldLog(message: "df1234test5"), true)
     
        Logger.filters = .init(messageContains: .init(notIncludes: ["test"]))
        XCTAssertEqual(Logger.shouldLog(message: "test12345"), false)
        XCTAssertEqual(Logger.shouldLog(message: "tes12334"), true)
        XCTAssertEqual(Logger.shouldLog(message: "df1234test5"), false)
        
        // conflicted
        Logger.filters = .init(messageContains: .init(includes: ["test", "tes"], notIncludes: ["test"]))
        XCTAssertEqual(Logger.shouldLog(message: "test12345"), false)
        XCTAssertEqual(Logger.shouldLog(message: "tes12334"), true)
        XCTAssertEqual(Logger.shouldLog(message: "df1234test5"), false)
    }
    
    func testFileNameFilters() throws {
        Logger.filters = .init(filename: .init(includes: [#file]))
        XCTAssertEqual(Logger.shouldLog(message: "", fileName: #file), true)
        
        Logger.filters = .init(filename: .init(notIncludes: [#file]))
        XCTAssertEqual(Logger.shouldLog(message: "", fileName: #file), false)
    }
    
    func testFuncNameFilters() throws {
        Logger.filters = .init(functionName: .init(includes: [#function]))
        XCTAssertEqual(Logger.shouldLog(message: "", funcName: #function), true)
        
        Logger.filters = .init(filename: .init(notIncludes: [#function]))
        XCTAssertEqual(Logger.shouldLog(message: "", fileName: #function), false)
    }
    
    func testCombinedFilters() throws {
        Logger.filters = .init(
            event: .init(includes: [.info, .error], notIncludes: [.info]),
            messageContains: .init(includes: ["test"]),
            filename: .init(includes: [#file]),
            functionName: .init(includes: [#function])
        )
        XCTAssertEqual(Logger.shouldLog(event: .error, message: "test2324"), true)
        XCTAssertEqual(Logger.shouldLog(event: .info, message: "test2324"), false)
        XCTAssertEqual(Logger.shouldLog(event: .error, message: "2324"), false)
        XCTAssertEqual(Logger.shouldLog(event: .error, message: "2324", fileName: "Test.swift"), false)
        XCTAssertEqual(Logger.shouldLog(event: .error, message: "test2324", funcName: "testCombinedFilters()"), true)
    }
}

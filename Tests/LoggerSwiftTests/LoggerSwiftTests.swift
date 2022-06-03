import XCTest
@testable import LoggerSwift

final class LoggerSwiftTests: XCTestCase {
    let logger = Logger()
    
    override func setUpWithError() throws {
        logger.isOn = true
        logger.filters = .init()
        logger.dateFormat = "yyyy-MM-dd hh:mm:ssSSS"
    }
    
    func testEmptyFilters() throws {
        XCTAssertEqual(logger.shouldLog(event: .error, message: ""), true)
        XCTAssertEqual(logger.shouldLog(event: .info, message: ""), true)
        XCTAssertEqual(logger.shouldLog(message: "test12345"), true)
        XCTAssertEqual(logger.shouldLog(message: "tes12334"), true)
        XCTAssertEqual(logger.shouldLog(message: "df1234test5"), true)
        XCTAssertEqual(logger.shouldLog(message: "", fileName: #file), true)
        XCTAssertEqual(logger.shouldLog(message: "", funcName: #function), true)
        XCTAssertEqual(logger.shouldLog(event: .error, message: "test2324"), true)
        XCTAssertEqual(logger.shouldLog(event: .info, message: "test2324"), true)
        XCTAssertEqual(logger.shouldLog(event: .error, message: "2324"), true)
        XCTAssertEqual(logger.shouldLog(event: .error, message: "2324", fileName: "Test.swift"), true)
    }
    
    func testEventFilters() throws {
        logger.filters = .init(event: .init(includes: [.error]))
        XCTAssertEqual(logger.shouldLog(event: .error, message: ""), true)
        XCTAssertEqual(logger.shouldLog(event: .info, message: ""), false)
        
        logger.filters = .init(event: .init(includes: [.error], notIncludes: [.info]))
        XCTAssertEqual(logger.shouldLog(event: .error, message: ""), true)
        XCTAssertEqual(logger.shouldLog(event: .info, message: ""), false)
        
        logger.filters = .init(event: .init(notIncludes: [.error]))
        XCTAssertEqual(logger.shouldLog(event: .error, message: ""), false)
        XCTAssertEqual(logger.shouldLog(event: .info, message: ""), true)
        
        // Conflicted filter
        logger.filters = .init(event: .init(includes: [.error], notIncludes: [.error, .info]))
        XCTAssertEqual(logger.shouldLog(event: .error, message: ""), false)
        XCTAssertEqual(logger.shouldLog(event: .info, message: ""), false)
    }
    
    func testMessageFilters() throws {
        logger.filters = .init(messageContains: .init(includes: ["test"]))
        XCTAssertEqual(logger.shouldLog(message: "test12345"), true)
        XCTAssertEqual(logger.shouldLog(message: "tes12334"), false)
        XCTAssertEqual(logger.shouldLog(message: "df1234test5"), true)
     
        logger.filters = .init(messageContains: .init(notIncludes: ["test"]))
        XCTAssertEqual(logger.shouldLog(message: "test12345"), false)
        XCTAssertEqual(logger.shouldLog(message: "tes12334"), true)
        XCTAssertEqual(logger.shouldLog(message: "df1234test5"), false)
        
        // conflicted
        logger.filters = .init(messageContains: .init(includes: ["test", "tes"], notIncludes: ["test"]))
        XCTAssertEqual(logger.shouldLog(message: "test12345"), false)
        XCTAssertEqual(logger.shouldLog(message: "tes12334"), true)
        XCTAssertEqual(logger.shouldLog(message: "df1234test5"), false)
    }
    
    func testFileNameFilters() throws {
        logger.filters = .init(filename: .init(includes: [#file]))
        XCTAssertEqual(logger.shouldLog(message: "", fileName: #file), true)
        
        logger.filters = .init(filename: .init(notIncludes: [#file]))
        XCTAssertEqual(logger.shouldLog(message: "", fileName: #file), false)
    }
    
    func testFuncNameFilters() throws {
        logger.filters = .init(functionName: .init(includes: [#function]))
        XCTAssertEqual(logger.shouldLog(message: "", funcName: #function), true)
        
        logger.filters = .init(filename: .init(notIncludes: [#function]))
        XCTAssertEqual(logger.shouldLog(message: "", fileName: #function), false)
    }
    
    func testCombinedFilters() throws {
        logger.filters = .init(
            event: .init(includes: [.info, .error], notIncludes: [.info]),
            messageContains: .init(includes: ["test"]),
            filename: .init(includes: [#file]),
            functionName: .init(includes: [#function])
        )
        XCTAssertEqual(logger.shouldLog(event: .error, message: "test2324"), true)
        XCTAssertEqual(logger.shouldLog(event: .info, message: "test2324"), false)
        XCTAssertEqual(logger.shouldLog(event: .error, message: "2324"), false)
        XCTAssertEqual(logger.shouldLog(event: .error, message: "2324", fileName: "Test.swift"), false)
        XCTAssertEqual(logger.shouldLog(event: .error, message: "test2324", funcName: "testCombinedFilters()"), true)
    }
}

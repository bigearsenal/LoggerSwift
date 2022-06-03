import Foundation

// MARK: - Log events
public enum LoggerEvent: String {
    case error      =   "[‼️]"
    case info       =   "[ℹ️]"          // for guard & alert & route
    case debug      =   "[💬]"          // tested values & local notifications
    case verbose    =   "[🔬]"          // current values
    case warning    =   "[⚠️]"
    case severe     =   "[🔥]"          // tokens & keys & init & deinit
    case request    =   "[⬆️]"
    case response   =   "[⬇️]"
    case event      =   "[🎇]"
}

// MARK: - Filter types
public struct LoggerFilter: Equatable {
    public var event = LoggerFilterType<LoggerEvent>()
    public var messageContains = LoggerFilterType<String>()
    public var filename = LoggerFilterType<String>()
    public var functionName = LoggerFilterType<String>()
}

public struct LoggerFilterType<T: Equatable>: Equatable {
    public var includes: [T] = []
    public var notIncludes: [T] = []
    public var isEmpty: Bool {
        includes.isEmpty && notIncludes.isEmpty
    }
    
    public init(includes: [T] = [], notIncludes: [T] = []) {
        self.includes = includes
        self.notIncludes = notIncludes
    }
}

public enum LoggerFilterEntityType: Equatable {
    case messageContains(String)
    case event(LoggerEvent)
    case filename(String)
    case functionName(String)
}

// MARK: - Logger
public class Logger {
    // MARK: - Properties
    public var isOn = true
    public var filters = LoggerFilter()
    
    // MARK: - Date formatter
    public var dateFormat = "yyyy-MM-dd hh:mm:ssSSS"
    var dateFormatter: DateFormatter {
        let formatter           =   DateFormatter()
        formatter.dateFormat    =   dateFormat
        formatter.locale        =   Locale.current
        formatter.timeZone      =   TimeZone.current
        
        return formatter
    }
    
    // MARK: - Methods
    public func log(
        domain: String,
        event: LoggerEvent = .info,
        message: String,
        fileName: String = #file,
        line: Int = #line,
        column: Int = #column,
        funcName: String = #function
    ) {
        // check isOn
        guard isOn else { return }
        
        // check filter
        guard shouldLog(event: event, message: message, fileName: fileName, funcName: funcName) else { return }
        
        // log
        #if DEBUG
            print("\(dateFormatter.string(from: Date())) \(event.rawValue)[\(domain)][\(sourceFileName(filePath: fileName))]:\(line) \(column) \(funcName) -> \(message)")
        #endif
    }
    
    /// Indicate if should log the message or not, last condition will override sooner condition
    func shouldLog(
        event: LoggerEvent = .info,
        message: String,
        fileName: String = #file,
        funcName: String = #function
    ) -> Bool {
        // log only if all condition are met
        let shouldLogEvent = shouldLog(entity: event, filter: filters.event)
        let shouldLogMessage = shouldLogMessage(message, filter: filters.messageContains)
        let shouldLogFilename = shouldLog(entity: fileName, filter: filters.filename)
        let shouldLogFuncname = shouldLog(entity: funcName, filter: filters.functionName)
        
        return shouldLogEvent && shouldLogMessage && shouldLogFilename && shouldLogFuncname
    }
    
    // MARK: - Helpers
    private func shouldLog<T: Equatable>(entity: T, filter: LoggerFilterType<T>) -> Bool {
        var shouldLog = true
        if !filter.includes.isEmpty {
            shouldLog = filter.includes.contains(entity)
        }
        
        if !filter.notIncludes.isEmpty {
            shouldLog = !filter.notIncludes.contains(entity)
        }
        return shouldLog
    }
    
    private func shouldLogMessage(_ message: String, filter: LoggerFilterType<String>) -> Bool {
        var shouldLog = true
        if !filter.includes.isEmpty {
            shouldLog = filter.includes.contains(where: {message.contains($0)})
        }
        
        if !filter.notIncludes.isEmpty {
            shouldLog = !filter.notIncludes.contains(where: {message.contains($0)})
        }
        return shouldLog
    }
    
    private func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
}

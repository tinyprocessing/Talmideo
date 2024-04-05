import Foundation
import SQLite3

protocol DataDatabase {}

extension DispatchQueue {
    static let database = DispatchQueue(label: "tinyprocessing.com.database")
}

final class SQLiteDataDatabase: DataDatabase {
    public struct Query {
        public let tableName: String

        public init(tableName: String) {
            self.tableName = tableName
        }

        enum QueryType {
            case search(columns: [String], value: String, limit: Int?)
        }

        func prepare(_ queryType: QueryType) -> (String, [Any?]) {
            switch queryType {
            case .search(let columns, let value, let limit):
                let placeholders = columns.map { "\($0) LIKE ?" }.joined(separator: " OR ")
                let values = columns.map { _ in "%\(value)%" }
                var query = "SELECT * FROM \(tableName) WHERE \(placeholders)"
                if let limit = limit {
                    query += " LIMIT \(limit)"
                }
                return (query, values)
            }
        }
    }

    private var database: OpaquePointer!
    public let query: Query

    init(name: String, tableName: String) {
        query = .init(tableName: tableName)
        open(name: name)
    }

    public func search(_ query: (String, [Any?])) -> [[String: Any?]] {
        DispatchQueue.database.sync {
            var results: [[String: Any?]] = []
            var stmt: OpaquePointer?

            let (queryString, queryValues) = query
            let SQLITE_TRANSIENT = unsafeBitCast(
                OpaquePointer(bitPattern: -1),
                to: sqlite3_destructor_type.self
            )

            if sqlite3_prepare_v2(
                database,
                queryString,
                -1,
                &stmt,
                nil
            ) == SQLITE_OK {
                for (index, value) in queryValues.enumerated() {
                    if let stringValue = value as? String {
                        let bindResult = sqlite3_bind_text(
                            stmt,
                            Int32(index + 1),
                            stringValue.lowercased(),
                            -1,
                            SQLITE_TRANSIENT
                        )
                        if bindResult != SQLITE_OK {
                            print("Failed to bind value: \(stringValue) at index: \(index + 1)")
                        }
                    }
                }
                while sqlite3_step(stmt) == SQLITE_ROW {
                    var row = [String: Any?]()
                    for i in 0..<sqlite3_column_count(stmt) {
                        let columnName = String(cString: sqlite3_column_name(stmt, i))
                        row[columnName] = getColumnValue(index: i, stmt: stmt)
                    }
                    results.append(row)
                }
                sqlite3_finalize(stmt)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(database))
                print("error preparing select: \(errmsg)")
            }
            return results
        }
    }

    private func getColumnValue(index: Int32, stmt: OpaquePointer?) -> Any? {
        switch sqlite3_column_type(stmt, index) {
        case SQLITE_INTEGER:
            return Int(sqlite3_column_int(stmt, index))
        case SQLITE_FLOAT:
            return Double(sqlite3_column_double(stmt, index))
        case SQLITE_TEXT:
            return String(cString: sqlite3_column_text(stmt, index))
        case SQLITE_NULL:
            return nil
        default:
            return nil
        }
    }

    deinit {
        close()
    }
}

extension SQLiteDataDatabase {
    private func open(name: String) {
        DispatchQueue.database.sync {
            var db: OpaquePointer?
            if let url = Bundle.main.url(forResource: name, withExtension: "db") {
                if sqlite3_open(url.path, &db) == SQLITE_OK {
                    print("Successfully opened connection to database at \(name)")
                } else {
                    print("Unable to open database. Verify that you created the directory correctly")
                }
            } else {
                print("Database file not found in the app bundle.")
            }
            database = db
        }
    }

    private func close() {
        DispatchQueue.database.sync {
            sqlite3_close(database)
            database = nil
        }
    }
}

// MARK: - Querying

extension SQLiteDataDatabase {
    private func execute(_ query: String, shouldLogError: Bool = true, command: ((OpaquePointer) -> Void)? = nil) {
        var statement: OpaquePointer?
        defer {
            sqlite3_finalize(statement)
        }

        guard sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK else {
            if shouldLogError {
                print("sqlite3_prepare_v2 result does not equal `SQLITE_OK` for query \(query)")
            }
            return
        }

        command?(statement!)

        guard sqlite3_step(statement) == SQLITE_DONE else {
            if shouldLogError {
                print("sqlite3_step result does not equal `SQLITE_DONE` for query \(query)")
            }
            return
        }
    }
}

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
            case word(value: Int)
            case index(value: String, limit: Int?, accurate: Bool)
            case id(value: String, limit: Int?)
            case export(value: String)
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
            case .word(let value):
                return ("SELECT * FROM \(tableName) WHERE id = \(value)", [])
            case .index(let value, let limit, let accurate):
                var query = """
                WITH RankedTokens
                AS (SELECT t.word_data_id,
                           t.id,
                           t.token,
                           t.position,
                           w.initial_form,
                           w.meaning_en,
                           w.meaning_ru,
                           w.meaning_es,
                           ROW_NUMBER() OVER (PARTITION BY t.word_data_id ORDER BY t.position) AS rn
                    FROM token t
                        JOIN worddata w
                            ON t.word_data_id = w.id
                    WHERE t.token LIKE ? )
                SELECT word_data_id,
                       id,
                       token,
                       position,
                       initial_form,
                       meaning_en,
                       meaning_ru,
                       meaning_es
                FROM RankedTokens
                WHERE rn = 1
                ORDER BY
                    LENGTH(initial_form),
                    id
                """
                if let limit = limit {
                    query += " LIMIT \(limit)"
                }
                if accurate {
                    return (query, ["\(value)"])
                }
                return (query, ["%\(value)%"])
            case .id(let value, let limit):
                var query = """
                SELECT * FROM worddata WHERE id LIKE ?
                """
                if let limit = limit {
                    query += " LIMIT \(limit)"
                }
                return (query, ["\(value)"])
            case .export(let value):
                let query = """
                SELECT id FROM word WHERE data LIKE ?
                """
                return (query, ["%\(value)%"])
            }
        }
    }

    private var database: OpaquePointer!
    public let query: Query

    init(name: String, tableName: String) {
        let start = DispatchTime.now()
        query = .init(tableName: tableName)
        open(name: name)
        let milliseconds = Double(DispatchTime.now().uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000
        print("Function \(#function) took \(milliseconds) milliseconds to run")
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

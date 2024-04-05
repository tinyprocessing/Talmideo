import Foundation

enum HTTPMethod: String {
    case delete = "DELETE"
    case get = "GET"
    case patch = "PATCH"
    case post = "POST"
    case put = "PUT"
}

enum NetworkError: Error {
    case networkLayerError(error: Error)
    case invalidResponse(error: Error?)
    case unauthorized
    case urlValidationFailed
}

enum Header: String {
    case authorization = "Authorization"
}

enum QueryItem: String {
    case secret
}

protocol APIRoute: CaseIterable {}

protocol APIConfiguration {
    associatedtype Route: APIRoute
    var initialURL: URL? { get }
    var route: Route { get }
    var requiresAuthorization: Bool { get }
    var method: HTTPMethod { get }
    var headers: [Header: String]? { get }
    var path: String? { get }
    var body: Data? { get }
    var queryComponents: [String: String]? { get }
    var queryItems: [URLQueryItem]? { get }

    func asURLRequest() throws -> URLRequest

    init(routeType: Route, requiresAuthorization: Bool)
}

extension APIConfiguration {
    func asURLRequest() throws -> URLRequest {
        let endpointURL = URL(string: Constants.CalibrationEndpointUrl)
        let rawUrl = initialURL ?? endpointURL

        guard var url = rawUrl else { throw NetworkError.urlValidationFailed }
        if let path = path {
            url = url.appendingPathComponent(path, conformingTo: .url)
        }
        var comps = URLComponents(url: url, resolvingAgainstBaseURL: true)
        if let queryItems = queryItems, !queryItems.isEmpty {
            comps?.queryItems = []
            queryItems.forEach { comps?.queryItems?.append($0) }
        }
        if let queryComponents = queryComponents {
            comps?.queryItems = queryComponents.compactMap {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }
        guard let finalUrl = comps?.url else { throw NetworkError.urlValidationFailed }
        var urlRequest = URLRequest(url: finalUrl)
        urlRequest.httpMethod = method.rawValue
        urlRequest.timeoutInterval = TimeInterval(Constants.ServerTimeoutMin)
        headers?.forEach { header in
            urlRequest.setValue(header.value, forHTTPHeaderField: header.key.rawValue)
        }
        if let body = body {
            urlRequest.httpBody = body
        }
        return urlRequest
    }
}

protocol NetworkServiceProtocol {
    func request<T: Decodable>(configuration: any APIConfiguration) async throws -> Result<T, Error>
    func request(configuration: any APIConfiguration) async throws -> Result<Data, Error>
}

class NetworkService: NetworkServiceProtocol {
    func request<T: Decodable>(configuration: any APIConfiguration) async throws -> Result<T, Error> {
        do {
            let result = try await request(configuration: configuration)
            switch result {
            case .success(let data):
                return try .success(JSONDecoder().decode(T.self, from: data))
            case .failure(let error):
                return .failure(error)
            }
        } catch {
            return .failure(error)
        }
    }

    func request(configuration: any APIConfiguration) async throws -> Result<Data, Error> {
        do {
            var request = try configuration.asURLRequest()
            let (data, response) = try await URLSession.shared.data(for: request)
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            if let statusCode, Constants.UnauthorizedErrorCodeRange ~= statusCode {
                return try await self.request(configuration: configuration)
            }
            return .success(data)
        } catch {
            return .failure(error)
        }
    }
}

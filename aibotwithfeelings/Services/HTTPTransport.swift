//
//  HTTPTransport.swift
//  aibotwithfeelings
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct HTTPTransportRequest: Sendable, Equatable {
    let url: URL
    let method: String
    let headers: [String: String]
    let body: Data?

    init(
        url: URL,
        method: String = "GET",
        headers: [String: String] = [:],
        body: Data? = nil
    ) {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
    }

    func makeURLRequest() -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        for (name, value) in headers {
            request.setValue(value, forHTTPHeaderField: name)
        }
        return request
    }
}

struct HTTPTransportResponse: Sendable, Equatable {
    let statusCode: Int
    let headers: [String: String]
    let body: Data

    init(statusCode: Int, headers: [String: String] = [:], body: Data) {
        self.statusCode = statusCode
        self.headers = headers
        self.body = body
    }
}

enum HTTPTransportError: Error, Equatable, Sendable {
    case invalidResponse
    case statusCode(Int)
}

protocol HTTPTransporting: Sendable {
    func send(_ request: HTTPTransportRequest) async throws -> HTTPTransportResponse
}

struct URLSessionHTTPTransport: HTTPTransporting {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func send(_ request: HTTPTransportRequest) async throws -> HTTPTransportResponse {
        let (data, response) = try await session.data(for: request.makeURLRequest())

        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPTransportError.invalidResponse
        }

        let headerFields = httpResponse.allHeaderFields.reduce(into: [String: String]()) { result, entry in
            guard let key = entry.key as? String, let value = entry.value as? String else { return }
            result[key] = value
        }

        return HTTPTransportResponse(
            statusCode: httpResponse.statusCode,
            headers: headerFields,
            body: data
        )
    }
}

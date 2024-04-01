//
//  ErrorHandler.swift
//  SwiftUIAsyncAPIProject
//
//  Created by Guillermo Kramsky on 01/04/24.
//

import Foundation

enum GHError: Error {
    case invalidUrl
    case invalidResponse
    case invalidData
}


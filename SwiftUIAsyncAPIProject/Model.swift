//
//  Model.swift
//  SwiftUIAsyncAPIProject
//
//  Created by Guillermo Kramsky on 01/04/24.
//

import Foundation

struct GitHubUser: Codable {
    let login: String
    let avatarUrl: String?
    let bio: String?
    let createdAt: String
    let publicRepos: Int
}

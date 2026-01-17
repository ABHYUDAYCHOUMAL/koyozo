//
//  GameDTO.swift
import Foundation

/// Data Transfer Object for Game from iOS Games API
/// Maps to the response format defined in IOS_GAMES_API.md
struct GameDTO: Codable {
    let id: String
    let title: String
    let category: String?
    let customURLScheme: String?
    let thumbnailURL: String?
    let backgroundURL: String?
    let description: String?
    let launchURL: String?
    let appStoreID: String
    let rating: Double?
    let ratingCount: Int?
    let popularityScore: Double?
    let createdAt: FirestoreTimestampDTO?
    let updatedAt: FirestoreTimestampDTO?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case category = "category"
        case customURLScheme = "custom_url_scheme"
        case thumbnailURL = "thumbnail_url"
        case backgroundURL = "background_url"
        case description
        case launchURL = "launch_url"
        case appStoreID = "app_store_id"
        case rating
        case ratingCount = "rating_count"
        case popularityScore = "popularity_score"
        case createdAt
        case updatedAt
    }
    
    init(
        id: String,
        title: String,
        category: String?,
        customURLScheme: String?,
        thumbnailURL: String?,
        backgroundURL: String?,
        description: String?,
        launchURL: String?,
        appStoreID: String,
        rating: Double?,
        ratingCount: Int?,
        popularityScore: Double?,
        createdAt: FirestoreTimestampDTO?,
        updatedAt: FirestoreTimestampDTO?
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.customURLScheme = customURLScheme
        self.thumbnailURL = thumbnailURL
        self.backgroundURL = backgroundURL
        self.description = description
        self.launchURL = launchURL
        self.appStoreID = appStoreID
        self.rating = rating
        self.ratingCount = ratingCount
        self.popularityScore = popularityScore
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let idString = try? container.decode(String.self, forKey: .id) {
            id = idString
        } else if let idInt = try? container.decode(Int.self, forKey: .id) {
            id = String(idInt)
        } else {
            let context = DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Expected id as String or Int"
            )
            throw DecodingError.dataCorrupted(context)
        }
        
        title = try container.decode(String.self, forKey: .title)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        customURLScheme = try container.decodeIfPresent(String.self, forKey: .customURLScheme)
        thumbnailURL = try container.decodeIfPresent(String.self, forKey: .thumbnailURL)
        backgroundURL = try container.decodeIfPresent(String.self, forKey: .backgroundURL)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        launchURL = try container.decodeIfPresent(String.self, forKey: .launchURL)
        appStoreID = try container.decode(String.self, forKey: .appStoreID)
        rating = try container.decodeIfPresent(Double.self, forKey: .rating)
        ratingCount = try container.decodeIfPresent(Int.self, forKey: .ratingCount)
        popularityScore = try container.decodeIfPresent(Double.self, forKey: .popularityScore)
        createdAt = try container.decodeIfPresent(FirestoreTimestampDTO.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(FirestoreTimestampDTO.self, forKey: .updatedAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(category, forKey: .category)
        try container.encodeIfPresent(customURLScheme, forKey: .customURLScheme)
        try container.encodeIfPresent(backgroundURL, forKey: .backgroundURL)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(launchURL, forKey: .launchURL)
        try container.encode(appStoreID, forKey: .appStoreID)
        try container.encodeIfPresent(rating, forKey: .rating)
        try container.encodeIfPresent(ratingCount, forKey: .ratingCount)
        try container.encodeIfPresent(popularityScore, forKey: .popularityScore)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
    }
}

/// Handles Firestore-style timestamp objects from the API:
/// { "_seconds": 1765265511, "_nanoseconds": 479000000 }
struct FirestoreTimestampDTO: Codable {
    let seconds: Int?
    let nanoseconds: Int?
    
    enum CodingKeys: String, CodingKey {
        case seconds = "_seconds"
        case nanoseconds = "_nanoseconds"
    }
}

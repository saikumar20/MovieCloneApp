

import Foundation

struct MovieResponse: Codable {
    let results: [Movie]?
}

struct Movie: Codable {
    let id: Int
    let backdrop_path: String?
    let original_title: String?
    let overview: String?
    let popularity: Double?
    let poster_path: String?
    let release_date: String?
    let title: String?
    let name: String?
    let original_name: String?
}


struct YoutubeResponse: Codable {
    let items: [VideoElement]?
}

struct VideoElement: Codable {
    let id: VideoID?
}

struct VideoID: Codable {
    let videoId: String?
}

//
//  ApiHandler.swift
//  MovieCloneApp
//
//  Created by Test on 06/05/25.
//

import Foundation

struct Constant {
    
    static let movieBaseUrl = "https://api.themoviedb.org"
    static let youtubeBaseUrl = "https://youtube.googleapis.com/youtube/v3"
    static let movieApiKey = "a36da165c50e17c94a917299f1eea83f"
    static let youtubeApiKey = "AIzaSyDyus2vBmql-mpGJTMLAZqS3nLeQKVupgE"
    static let trendingMovies = "/3/trending/movie/day?api_key="
    static let trendingTv = "/3/trending/tv/day?api_key="
    static let popular = "/3/movie/popular?api_key="
    static let topRatedTv = "/3/tv/top_rated?api_key="
    static let upcomingMovies = "/3/movie/upcoming?api_key="
    static let mulit = "&language=en-US&page=1"
    static let search = "/3/search/movie?api_key="
    static let query = "&query="
    static let youtubesearch = "/3/search/movie?api_key="
    static let youtubesearchquery = "/search?q="
    static let youtubequerykey = "&key="
}

class serviceHandler {
    enum Httpmethods : String {
        case get
        case post
        var method : String {rawValue.capitalized}
    }

    enum networkError : Error {
        case Invalidresponse
        case InvalidStatusCode(Int)
    }
    
   
    
    static let shared = serviceHandler()


    func movieListApiCall<T : Decodable>(url : String?, httpmethod :Httpmethods = .get,query : String = "", completion : @escaping(Result<T,Error>) -> Void) {
        
        guard let ApiUrl = URL(string: url ?? "") else {return}
        
        let urlrequest = URLRequest(url: ApiUrl)
        
        let task = URLSession.shared.dataTask(with: urlrequest) { data, response, error in
            
            guard let data = data else {
                completion(.failure(networkError.Invalidresponse))
                return
            }
            
            
            
            let httpMethod = response as! HTTPURLResponse
            
            if !(200...300).contains(httpMethod.statusCode) {
                completion(.failure(networkError.InvalidStatusCode(httpMethod.statusCode)))
            }else {
                
                let jsonDecoder = JSONDecoder()
                do{
                    let result = try jsonDecoder.decode(T.self, from: data)
                    completion(.success(result))
                }
                catch {
                    print(error.localizedDescription)
                }
                
            }
        }
        
        task.resume()
        
    }

}


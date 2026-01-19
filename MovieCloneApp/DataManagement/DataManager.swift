

import Foundation
import CoreData
import UIKit

// MARK: - Database Errors
enum DatabaseError: LocalizedError {
    case failedToSave
    case failedToFetch
    case failedToDelete
    case contextUnavailable
    
    var errorDescription: String? {
        switch self {
        case .failedToSave: return "Failed to save data to database"
        case .failedToFetch: return "Failed to fetch data from database"
        case .failedToDelete: return "Failed to delete data from database"
        case .contextUnavailable: return "Core Data context is unavailable"
        }
    }
}

// MARK: - Downloaded Data Manager
final class DownloadedData {
    
    // MARK: - Singleton
    static let shared = DownloadedData()
    
    private init() {}
    
    // MARK: - Core Data Context
    private var context: NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }
    
    // MARK: - Save Movie
    func saveData(_ movie: Movie?, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let movie = movie else {
            completion(.failure(DatabaseError.failedToSave))
            return
        }
        
        guard let context = context else {
            completion(.failure(DatabaseError.contextUnavailable))
            return
        }
        
        // Check if movie already exists
        let fetchRequest: NSFetchRequest<MovieDownloadData> = MovieDownloadData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", movie.id)
        
        do {
            let existingMovies = try context.fetch(fetchRequest)
            
            if !existingMovies.isEmpty {
                // Movie already downloaded
                completion(.success(()))
                return
            }
            
            // Create new movie entity
            let movieEntity = MovieDownloadData(context: context)
            movieEntity.id = Int64(movie.id)
            movieEntity.name = movie.name
            movieEntity.backdrop_path = movie.backdrop_path
            movieEntity.original_name = movie.original_name
            movieEntity.original_title = movie.original_title
            movieEntity.overview = movie.overview
            movieEntity.popularity = movie.popularity ?? 0.0
            movieEntity.poster_path = movie.poster_path
            movieEntity.release_date = movie.release_date
            movieEntity.title = movie.title
            
            try context.save()
            completion(.success(()))
            
        } catch {
            completion(.failure(DatabaseError.failedToSave))
        }
    }
    
    // MARK: - Fetch All Movies
    func getData(completion: @escaping (Result<[MovieDownloadData], Error>) -> Void) {
        guard let context = context else {
            completion(.failure(DatabaseError.contextUnavailable))
            return
        }
        
        let fetchRequest: NSFetchRequest<MovieDownloadData> = MovieDownloadData.fetchRequest()
        
        // Sort by most recently added
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        
        do {
            let movies = try context.fetch(fetchRequest)
            completion(.success(movies))
        } catch {
            completion(.failure(DatabaseError.failedToFetch))
        }
    }
    
    // MARK: - Delete Movie
    func deleteData(_ movie: MovieDownloadData, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let context = context else {
            completion(.failure(DatabaseError.contextUnavailable))
            return
        }
        
        context.delete(movie)
        
        do {
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(DatabaseError.failedToDelete))
        }
    }
    
    // MARK: - Check if Movie is Downloaded
    func isMovieDownloaded(_ movieID: Int, completion: @escaping (Bool) -> Void) {
        guard let context = context else {
            completion(false)
            return
        }
        
        let fetchRequest: NSFetchRequest<MovieDownloadData> = MovieDownloadData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", movieID)
        fetchRequest.fetchLimit = 1
        
        do {
            let count = try context.count(for: fetchRequest)
            completion(count > 0)
        } catch {
            completion(false)
        }
    }
    
    // MARK: - Delete All Downloads
    func deleteAllDownloads(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let context = context else {
            completion(.failure(DatabaseError.contextUnavailable))
            return
        }
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = MovieDownloadData.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(DatabaseError.failedToDelete))
        }
    }
}

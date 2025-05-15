//
//  DataManager.swift
//  MovieCloneApp
//
//  Created by Test on 13/05/25.
//

import Foundation
import CoreData
import UIKit

class DownloadedData {
    
    enum dataBaseErrors : Error {
        case failToSave
        case failToFetch
        case failToDelete
    }
    
    
    static let shared = DownloadedData()
    
    
    func saveData(_ movieData : Movie?, completion : @escaping((Result<Void,Error>) -> Void)) {
        
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate
        else {return}
        
        let context = appdelegate.persistentContainer.viewContext
        
        let item = MovieDownloadData(context: context )
        item.id = Int64(movieData?.id ?? 0)
        item.name = movieData?.name
        item.backdrop_path = movieData?.backdrop_path
        item.original_name = movieData?.original_name
        item.original_title =  movieData?.original_title
        item.overview = movieData?.overview
        item.popularity = movieData?.popularity ?? 0
        item.poster_path = movieData?.poster_path
        item.release_date = movieData?.release_date
        item.title = movieData?.title
        
        do{
            try context.save()
            completion(.success(()))
        }catch{
            completion(.failure(dataBaseErrors.failToSave))
        }
    }
    
    
    
    func getData(competion : @escaping((Result<[MovieDownloadData],Error>)->Void)) {

        let request = MovieDownloadData.fetchRequest()
        let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        
        do{
            let data = try context?.fetch(request)
            if let result = data {
                competion(.success(result))
            }
        }catch {
            competion(.failure(dataBaseErrors.failToFetch))
        }
       
    }
    
    
    func deleteData(_ data: MovieDownloadData,completion : @escaping((Result<Void,Error>)->Void)) {
        
        let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        context?.delete(data)
        do {
            try context?.save()
            completion(.success(()))
        }catch {
            completion(.failure(dataBaseErrors.failToDelete))
        }
       
        
    }
    
}


extension DownloadedData {
    
    
    func savelocalData(_ data : Movie? , completion : @escaping((Result<Void,Error>) -> Void)) {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let item = MovieDownloadData(context: context)
        item.id = Int64(data?.id ?? 0)
        item.name = data?.name
        item.original_name = data?.original_name
        item.original_title = data?.original_title
        item.overview = data?.overview
        item.popularity = data?.popularity ?? 0
        item.poster_path = data?.poster_path
        item.release_date = data?.release_date
        item.title = data?.title
      
        do {
            try context.save()
        }catch {
            print("error")
        }
        
        
    }
    
    
    func getlocalData(completion : ((Result<[MovieDownloadData],Error>)->())) {
        
        let contextrequest = MovieDownloadData.fetchRequest()
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
          let data =   try context.fetch(contextrequest)
            completion(.success(data))
        }catch {
            print("error")
            completion(.failure(error))
        }
    }
    
    
    func deleteLocalData(_ data :MovieDownloadData, completion : @escaping((Result<Void,Error>)-> Void) ) {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        context.delete(data)
        do{
            try context.save()
            completion(.success(()))
        }catch {
            completion(.failure(error))
        }
    }
    
    
}

//
//  MagnetManager.swift
//  kAR
//
//  Created by Tomas Vajdicka on 18/06/2019.
//  Copyright © 2019 rebel.io. All rights reserved.
//

import UIKit
import ARKit

class MagnetManager: NSObject {
    
    let rest = RestManager()
    
    init(_ apiKey: String) {
        rest.requestHttpHeaders.add(value: "Api-Key \(apiKey)", forKey: "Authorization")
    }
    
    func save(key: String, photoWidth: Double, completion: @escaping () -> Void) {
        print("Saving...", key)
        print("Downloading image:", key)
        downloadImage(photoKey: key) {
                self.update(key: key, physicalSize: photoWidth)
                completion()
        }
    }
    
    
    func update(key: String, physicalSize: Double) {
        MagnetDB.shared.insert(kValue: key , psValue: physicalSize)
    }
    
    private func downloadImage(photoKey: String, completion: @escaping () -> Void) {
        if let photoUrl = URL(string: NetworkConstants.apiURL+NetworkConstants.refsEP+photoKey) {
            getData(from: photoUrl) { data, response, error in
                guard let data = data, error == nil else { return }
                self.save(file: self.clearKey(named: photoKey), data: data)
                completion()
            }
        }
    }
    
    private func downloadVideo(videoKey: String, completion: @escaping () -> Void) {
        if let videoUrl = URL(string:NetworkConstants.apiURL+NetworkConstants.mediaEP+videoKey) {
            getData(from: videoUrl) { data, response, error in
                guard let data = data, error == nil else { return }
                self.save(file: self.clearKey(named: videoKey)+".mp4", data: data)
                completion()
            }
        }
    }
    
    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    
    func save(file: String, data: Data) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documentsDirectory.appendingPathComponent(file)
        
        //Checks if file exists, removes it if so.
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Removed old file:", fileURL.path)
            } catch let removeError {
                print("couldn't remove file at path", removeError)
            }
            
        }
        
        do {
            try data.write(to: fileURL)
            print("Data written to file:", fileURL.path)
        } catch let error {
            print("error saving file with error", error)
        }
    }
    
    private func clearKey(named: String) -> String {
        var fileName = named.replacingOccurrences(of: "uploads/", with: "")
        fileName = fileName.replacingOccurrences(of: "videos/", with: "")
        return fileName
    }
    
    // TODO: filters
    func getMagnetReferences() -> Set<ARReferenceImage>?{
        
        var customReferenceSet = Set<ARReferenceImage>()
        let documentsDirectory = PathHelper.getDocumentsDirectory()
        
        do {
            let magnets = MagnetDB.shared.all()//realm.objects(MagnetRecord.self)

            magnets.forEach { (magnetRecord) in
                do{
                    //1. Create A Data Object From Our URL
                    let fileUrl = documentsDirectory.appendingPathComponent(magnetRecord.key)
                    let imageData = try Data(contentsOf: fileUrl)

                    guard let image = UIImage(data: imageData) else { return }

                    //2. Convert The UIImage To A CGImage
                    guard let cgImage = image.cgImage else { return }

                    //4. Create A Custom AR Reference Image With A Unique Name
                    let customARReferenceImage = ARReferenceImage(cgImage, orientation: CGImagePropertyOrientation.up, physicalWidth: CGFloat(magnetRecord.physicalSize))
                    customARReferenceImage.name = magnetRecord.key

                    //4. Insert The Reference Image Into Our Set
                    customReferenceSet.insert(customARReferenceImage)
                    //print("customReference", customReferenceSet)
                    //print("ARReference Image == \(customARReferenceImage)")
                }catch{
                    print("Error Generating Images == \(error)")
                }
            }
        } catch {
            print("Error Reading Directory Contents == \(error)")
        }
        //5. Return The Set
        return customReferenceSet
    }
    
    public func synchronize() {
        guard let url = URL(string: NetworkConstants.apiURL+NetworkConstants.magnetEP) else { return }
        
        rest.makeRequest(toURL: url, withHttpMethod: .get) { (results) in
            let downloadGroup = DispatchGroup()
            if let data = results.data {
                let decoder = JSONDecoder()
                do {
                    let decoder = JSONDecoder()
                    let magnetRoot = try decoder.decode(MagneticField.self, from: data)
                    
                    magnetRoot.magnets.filter{ !$0.exists() }.forEach({ (magnet) in
                        downloadGroup.enter()
                        self.save(key: magnet.key, photoWidth: magnet.physicalSize, completion: {
                            downloadGroup.leave()
                        })
                    })
                    
                } catch let error {
                    print(error)
                }
            }
            downloadGroup.wait()
        }
    }
}

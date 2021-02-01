//
//  ViewController.swift
//  dummyApp
//
//  Created by Raju Gupta on 01/02/21.
//  Copyright © 2021 Raju Gupta. All rights reserved.
//

import UIKit
import Zip
import PDFKit

class ViewController: UIViewController, PDFViewDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var openPDFBtn: UIButton!
    
    var PDFPath = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
            self.loadFileAsync(url: URL(string: "https://download.wetransfer.com//eu2/1edcf28c10d0ac276ca3f531748f12cb20210201050149/f5bc9ff9fcebeff1db589da9416b558b58ae0b48/Asset.zip?cf=y&token=eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjE2MTIxNTc2MjUsInVuaXF1ZSI6IjFlZGNmMjhjMTBkMGFjMjc2Y2EzZjUzMTc0OGYxMmNiMjAyMTAyMDEwNTAxNDkiLCJmaWxlbmFtZSI6IkFzc2V0LnppcCIsIndheWJpbGxfdXJsIjoiaHR0cDovL3Byb2R1Y3Rpb24uYmFja2VuZC5zZXJ2aWNlLmV1LXdlc3QtMS53dDo5MjkyL3dheWJpbGwvdjEvc2Fya2FyL2Y2ZjM1ZTA2Zjk3ZDNjZGE0MWMwMDcyZTc0OTA5NjM4YTg3NDFhMjJlMTJjYzlkMjcxMjBlODM1NzE5NWIyMWUzOWVmYzU0ZGU1ODA0OGFlYzNlOThlIiwiZmluZ2VycHJpbnQiOiJmNWJjOWZmOWZjZWJlZmYxZGI1ODlkYTk0MTZiNTU4YjU4YWUwYjQ4IiwiY2FsbGJhY2siOiJ7XCJmb3JtZGF0YVwiOntcImFjdGlvblwiOlwiaHR0cDovL3Byb2R1Y3Rpb24uZnJvbnRlbmQuc2VydmljZS5ldS13ZXN0LTEud3Q6MzAwMC93ZWJob29rcy9iYWNrZW5kXCJ9LFwiZm9ybVwiOntcInRyYW5zZmVyX2lkXCI6XCIxZWRjZjI4YzEwZDBhYzI3NmNhM2Y1MzE3NDhmMTJjYjIwMjEwMjAxMDUwMTQ5XCIsXCJkb3dubG9hZF9pZFwiOjExMzQ1NDQ5NjIwLFwicmVjaXBpZW50X2lkXCI6XCI4YTJlYjQ2NDJlNmE2MDQ3YzRjNGRkMDNhNWM4YTAwZTIwMjEwMjAxMDUwMjA1XCJ9fSJ9.3kukG-EOwPAqI1LNDrVOMqxeJPjRsoMyGz9kUQJeF3g")!, completion: { (path, error) in
                print("File downloaded to : \(path!)")
                
                do {
                    let unzipDirectory = try Zip.quickUnzipFile(URL(string: path!)!) // Unzip
                    let destinationUrl = unzipDirectory.appendingPathComponent("Asset", isDirectory: true)
                    let delayInSeconds = 0.0
                    DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds)
                    {
                        
                        if FileManager.default.fileExists(atPath: destinationUrl.appendingPathComponent("image/pin.png").path)
                        {
                            print("FILE IS there at \n\(destinationUrl.appendingPathComponent("image/pin.png").path)!)\n")
                            self.imageView.image =  UIImage(contentsOfFile: destinationUrl.appendingPathComponent("image/pin.png").path)
                            
                        }else
                        {
                            print("No File")
                        }
                        
                    }
                    print("UNZIPED Directory: ", destinationUrl)
                    
                    let fm = FileManager.default
                    do {
                        let items = try fm.contentsOfDirectory(atPath: destinationUrl.path)

                        for item in items {
                            print("Found \(item)")

                        }
                    } catch {
                        print("error ")
                    }

                }
                catch {
                  print("Something went wrong")
                }
            })
        
        }
        
    @IBAction func openPDFButtonPressed(_ sender: UIButton) {
//    let pdfViewController = PDFViewController()
//    pdfViewController.pdfURL = self.pdfURL
//    present(pdfViewController, animated: false, completion: nil)
    }
    
        func loadFileAsync(url: URL, completion: @escaping (String?, Error?) -> Void)
        {
            let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

            let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)

            if FileManager().fileExists(atPath: destinationUrl.path)
            {
                print("File already exists [\(destinationUrl.path)]")
                completion(destinationUrl.path, nil)
            }
            else
            {
                let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                let task = session.dataTask(with: request, completionHandler:
                {
                    data, response, error in
                    if error == nil
                    {
                        if let response = response as? HTTPURLResponse
                        {
                            if response.statusCode == 200
                            {
                                print("MIME TYPE: ", response.mimeType!)
                                if let data = data
                                {
                                    if let _ = try? data.write(to: destinationUrl, options: Data.WritingOptions.atomic)
                                    {
                                        completion(destinationUrl.path, error)
                                    }
                                    else
                                    {
                                        completion(destinationUrl.path, error)
                                    }
                                }
                                else
                                {
                                    completion(destinationUrl.path, error)
                                }
                            }
                        }
                    }
                    else
                    {
                        completion(destinationUrl.path, error)
                    }
                })
                task.resume()
            }
        }


}


//
//  PdfViewerViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 14/07/23.
//

import UIKit
import PDFKit

class PdfViewerViewController: UIViewController {
    
    @IBOutlet weak var pdfView: PDFView!
    
    var pdfUrl: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        
        print("pdfURL: \(pdfUrl ?? "URL  not found")")
        if let pdfUrl = pdfUrl {
            showPdf(from: pdfUrl)
        }
    }
    
    func showPdf(from url: String) {
        
        if let url = URL(string: url) {
            URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
                guard let pdfData = data else { return }
                DispatchQueue.main.async {
                    let pdfDOC = PDFDocument(data: pdfData)
                    self.pdfView.document = pdfDOC
                    self.pdfView.autoScales = true
                }
            }.resume()
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
//        savePdf(pdfView.document)
    }
    
//    func savePdf(_ data: Data) {
//        do {
//            FileManager.default.co
//            try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
//            do {
//                //Show UIActivityViewController to save the downloaded file
//                let contents  = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
//                for indexx in 0..<contents.count {
//                    if contents[indexx].lastPathComponent == destinationFileUrl.lastPathComponent {
//                        let activityViewController = UIActivityViewController(activityItems: [contents[indexx]], applicationActivities: nil)
//                        DispatchQueue.main.async {
//                            self.present(activityViewController, animated: true, completion: nil)
//                        }
//                    }
//                }
//            }
//            catch (let err) {
//                print("error: \(err)")
//            }
//        } catch (let writeError) {
//            print("Error creating a file \(destinationFileUrl) : \(writeError)")
//        }
//    }
    
    
    func savePdf2(_ url: String) {
        self.showIndicator()
        let urlString = url
        let url = URL(string: urlString)
        let fileName = String((url!.lastPathComponent)) as NSString
        // Create destination URL
        let documentsUrl:URL =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?)!
        let destinationFileUrl = documentsUrl.appendingPathComponent("\(fileName)")
        //Create URL to the source file you want to download
        let fileURL = URL(string: urlString)
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url:fileURL!)
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            self.hideIndicator()
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Successfully downloaded. Status code: \(statusCode)")
                }
                do {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                    do {
                        //Show UIActivityViewController to save the downloaded file
                        let contents  = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                        for indexx in 0..<contents.count {
                            if contents[indexx].lastPathComponent == destinationFileUrl.lastPathComponent {
                                let activityViewController = UIActivityViewController(activityItems: [contents[indexx]], applicationActivities: nil)
                                DispatchQueue.main.async {
                                    self.present(activityViewController, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                    catch (let err) {
                        print("error: \(err)")
                    }
                } catch (let writeError) {
                    print("Error creating a file \(destinationFileUrl) : \(writeError)")
                }
            } else {
                print("Error took place while downloading a file. Error description: \(error?.localizedDescription ?? "")")
            }
        }
        task.resume()
    }
}

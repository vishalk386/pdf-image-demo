//
//  ViewController.swift
//  PDFImageDemo
//
//  Created by Murugan Krishnan on 06/12/21.
//

import UIKit
import AVFoundation
import AssetsLibrary
import MobileCoreServices
import AVKit
import PDFKit
import Vision
import VisionKit
import Photos
import CoreGraphics



class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIDocumentPickerDelegate,UIDocumentInteractionControllerDelegate,VNDocumentCameraViewControllerDelegate{
    // MARK: - Global declarations
    @IBOutlet weak var btnSelectPDF: UIButton!
    @IBOutlet weak var btnSavePDF: UIButton!
    //PDF to UIImage array
    var arrayPDFImages = [UIImage]()
    var arrPDFCompressedImgs = [UIImage]()
    //Userdefaults
    let defaults = UserDefaults.standard

    // MARK: - ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    // MARK: - documentPicker delegate methods
    @objc func documentPicker(_ picker: UIDocumentPickerViewController, didPickDocumentAtURL url: NSURL){
        
//    private func documentPicker(controller: UIDocumentPickerViewController, didPickDocumentAtURL url: NSURL) {
        print("documentPickerurl@btnPDF = \(url)")
//        let request = URLRequest(url: url)
//        self.drawPDFfromURL(url: url as URL)
//        defaults.set(url, forKey: "OriginalPDFPath")
//        self.drawPDFfromURL(url: url as URL)
        let urlString: String = url.path!
        print("urlStringdocumentPicker\(urlString)")
        self.fileSizeOriginal(fromPath: urlString)
        self.drawOnPDF(path: urlString)
        defaults.setValue(urlString, forKey: "OriginalPath")
//        self.getEmbeddedImage(ofPDFAt: url as URL, pageIndex: 0)
    }
    @objc func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            dismiss(animated: true, completion: nil)
        }
    // MARK: - documentInteractionController delegate
     func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }

    func documentInteractionControllerViewForPreview(_ controller: UIDocumentInteractionController) -> UIView? {
        return self.view
    }

    func documentInteractionControllerRectForPreview(_ controller: UIDocumentInteractionController) -> CGRect {
        return self.view.frame
    }
    // MARK: - PDF size identification
    func fileSizeOriginal(fromPath : String) -> String? {
        guard let size = try? FileManager.default.attributesOfItem(atPath: fromPath)[FileAttributeKey.size],
            let fileSize = size as? UInt64 else {
            return nil
        }

        // bytes
        if fileSize < 1023 {
            return String(format: "%lu bytes", CUnsignedLong(fileSize))
        }
        // KB
        var floatSize = Float(fileSize / 1024)
        if floatSize < 1023 {
            return String(format: "%.1f KB", floatSize)
        }
        // MB
        floatSize = floatSize / 1024
        if floatSize < 1023 {
            return String(format: "%.1f MB", floatSize)
        }
        // GB
        floatSize = floatSize / 1024
        defaults.setValue(floatSize, forKey: "original_imageSize")
        print("floatSize\(floatSize)")
        return String(format: "%.1f GB", floatSize)
    }
    // MARK: -  watermark for image
    func drawText(_ text: String?, in image: UIImage?,textcolor:UIColor?, at point: CGPoint) -> UIImage? {
//        let font = UIFont(name: "Helvetica Bold", size: 50)
        let font = UIFont(name: "Helvetica", size: 40)

//        let textcolor = UIColor.blue
        UIGraphicsBeginImageContext((image?.size)!)
        image?.draw(in: CGRect(x: 0, y: 0, width: image?.size.width ?? 0.0, height: image?.size.height ?? 0.0))
        let rect = CGRect(x: image!.size.width / 2.5, y: image!.size.height / 2, width: image!.size.width / 2, height: image!.size.height / 2)

        if let aFont = font {
            text?.draw(in: rect.integral, withAttributes: [NSAttributedString.Key.font : aFont,NSAttributedString.Key.foregroundColor: textcolor])
        }
        //[text drawInRect:CGRectIntegral(rect) withAttributes:@{NSFontAttributeName:font}];
        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    // MARK: -  PDF->Image->PDF
    func drawOnPDF(path: String)
    {
        var imageFinal = UIImage()
        let pdfDocument = PDFDocument()
        var img2:UIImage? = nil
        let urlstr: NSURL = NSURL.fileURL(withPath: path) as NSURL
        let pdf: CGPDFDocument = CGPDFDocument(urlstr)!
        var page: CGPDFPage;
        let pageCount: Int = pdf.numberOfPages;
    for i in 0..<pageCount {

//            var mypage: CGPDFPage = pdf.page(at: i+1)!
//                frame = CGPDFPageGetBoxRect(mypage, kCGPDFMediaBox)
//            UIGraphicsBeginImageContext(CGRect(origin: 600, size: 600*(frame.size.height/frame.size.width)))
//        let ctx: CGContext = UIGraphicsGetCurrentContext()!
//        ctx.saveGState()
//        ctx.translateBy(x: 0.0, y: frame.size.height)
//        ctx.scaleBy(x: 1.0, y: -1.0)
//        ctx.setFillColor(gray: 1.0, alpha: 1.0)
//        ctx.fill(frame)
        page = pdf.page(at: i + 1)!
//                var pdfTransform: CGAffineTransform = CGPDFPageGetDrawingTransform(page, kCGPDFMediaBox, frame, 0, true)
//            ctx.concatenate(pdfTransform);
        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        var imgPDF = UIImage()

                    imgPDF = renderer.image { ctx in
            UIColor.white.set()

        ctx.fill(pageRect)
        ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
        ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
        ctx.cgContext.drawPDFPage(page)

//                CGContextSetInterpolationQuality(ctx, kCTBaselineClassIdeographicHigh)
//                CGContextSetRenderingIntent(ctx, kCGRenderingIntentDefault)
//            ctx.drawPDFPage(page)
        var thumbnailImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
//            ctx.restoreGState()
            var documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        documentsPath = documentsPath.appendingFormat("/Page%d.png", i+1)
            UIGraphicsEndImageContext()
                        let imagedata = thumbnailImage.jpegData(compressionQuality: 0.3)
//                imagedata.writeToFile(documentsPath, atomically: true)
//                arrayPDFImages.append(documentsPath)
        }
//            let dirPath = arrayPDFImages.objectAtIndex(0) as? String
//            let image    = UIImage(contentsOfFile: dirPath!)
    defaults.set(arrayPDFImages, forKey: "arrayPDF")
        print("arrayPDFImages \(arrayPDFImages)")
//        UIImageWriteToSavedPhotosAlbum(imgPDF, nil, nil, nil)
        let img2 = self.drawText("AdStringO", in: imgPDF, textcolor: UIColor.blue, at: CGPoint(x: 25, y: 25))

        let imageData3 = img2!.jpegData(compressionQuality: 0.7)
        imageFinal = UIImage(data: imageData3!)!
    UIImageWriteToSavedPhotosAlbum(imageFinal, nil, nil, nil)
        arrPDFCompressedImgs.append(imageFinal)
        

      

    }
        self.createPDF(images: arrPDFCompressedImgs)

//        let yourPDF = arrayPDFImages.makePDF()
//        for i in 0..<pageCount {
//        let pdfPage = PDFPage(image: imageFinal)
//        pdfDocument.insert(pdfPage!, at: i)
//        let data = pdfDocument.dataRepresentation()
//
//        let documentDirectory = NSTemporaryDirectory()
//        let docURL = documentDirectory.appending("Assignment-Docs.pdf")
//        FileManager.default.createFile(atPath: docURL, contents: data, attributes: nil)
//        let fileData = try? Data(contentsOf: URL(fileURLWithPath: docURL))
//        print("PDF SIZE: \(fileData!.count) Bytes")
//        let fileUrl = URL(string: docURL)
//        if let pdfData = NSData(contentsOf: fileUrl!) {
//            let resourceDocPath = NSHomeDirectory().appending("/Documents/yourPDF.pdf")
//            unlink(resourceDocPath)
//            pdfData.write(toFile: resourceDocPath, atomically: true)
//
//            let url = UserDefaults.standard.set(docURL, forKey: "Linka")
//
//        }
//}
    }
    // MARK: - drawPDFfromURL
    func drawPDFfromURL(url: URL) -> UIImage? {
        guard let document = CGPDFDocument(url as CFURL) else { return nil }
        guard let page = document.page(at: 1) else { return nil }
        let pageCount: Int = document.numberOfPages;
        print("pageCount-PDF\(pageCount)")
        var arrayOfImages = [UIImage]()

        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img = renderer.image { ctx in
            for __ in 0..<pageCount {
             UIColor.white.set()
            ctx.fill(pageRect)

            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

            ctx.cgContext.drawPDFPage(page)
        }
        }
        UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
        let imageData3 = img.jpegData(compressionQuality: 0.1)
            let image2 = UIImage(data: imageData3!)!
        UIImageWriteToSavedPhotosAlbum(image2, nil, nil, nil)


        return img
    }
    func compressImagefromPDF(image:UIImage){
        let imageData3 = image.jpegData(compressionQuality: 0.3)
            let image2 = UIImage(data: imageData3!)!
        UIImageWriteToSavedPhotosAlbum(image2, nil, nil, nil)

    }
    // MARK: - createPDF
    func createPDF(images: [UIImage]) {
        let count:Int = images.count
        print("createPDF_count\(count)")
            let pdfData = NSMutableData()
            UIGraphicsBeginPDFContextToData(pdfData, CGRect.zero, nil)
            for image in images {
                let imgView = UIImageView.init(image: image)
                UIGraphicsBeginPDFPageWithInfo(imgView.bounds, nil)
                let context = UIGraphicsGetCurrentContext()
                imgView.layer.render(in: context!)
            }
            UIGraphicsEndPDFContext()
            //try saving in doc dir to confirm:
            let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
            let path = dir?.appendingPathComponent("ADS_PDFCompressed.pdf")

            do {
                try pdfData.write(to: path!, options: NSData.WritingOptions.atomic)
            } catch {
                print("error catched")
            }

            let documentViewer = UIDocumentInteractionController(url: path!)
            documentViewer.name = "ADSTRINGO"
            documentViewer.delegate = self
            documentViewer.presentPreview(animated: true)

        }
    
    func createPDF2(image: UIImage)  {

         let pdfData = NSMutableData()
         let pdfConsumer = CGDataConsumer(data: pdfData as CFMutableData)!

         var mediaBox = CGRect.init(x: 0, y: 0, width: image.size.width, height: image.size.height)

         let pdfContext = CGContext(consumer: pdfConsumer, mediaBox: &mediaBox, nil)!

         pdfContext.beginPage(mediaBox: &mediaBox)
         pdfContext.draw(image.cgImage!, in: mediaBox)
         pdfContext.endPage()

     }
    // MARK: - IBActions
    @IBAction func btnSelectPDF(_ sender: UIButton) {
        let documentPicker : UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF)], in: .import)

        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
        
    }
    
    @IBAction func btnSavePDF(_ sender: UIButton) {
        let pdfView = PDFView()

        pdfView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pdfView)

        pdfView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        
//        guard let path = Bundle.main.url(forResource: "example", withExtension: "pdf") else { return }
        let path = UserDefaults.standard.string(forKey: "Link")
        let url = URL(string: path!)
        if let document = PDFDocument(url: url!) {
            pdfView.document = document
        }
    }
    

}

extension Array where Element: UIImage {
    
      func makePDF()-> PDFDocument? {
        let pdfDocument = PDFDocument()
        for (index,image) in self.enumerated() {
            let pdfPage = PDFPage(image: image)
            pdfDocument.insert(pdfPage!, at: index)
        }
                  let data = pdfDocument.dataRepresentation()
          
                  let documentDirectory = NSTemporaryDirectory()
                  let docURL = documentDirectory.appending("AdstringoTrialPDF.pdf")
                  FileManager.default.createFile(atPath: docURL, contents: data, attributes: nil)
          let url = UserDefaults.standard.set(docURL, forKey: "Linka")


        return pdfDocument
    }
}

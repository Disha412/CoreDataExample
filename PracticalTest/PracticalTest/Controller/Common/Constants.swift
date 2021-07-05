
import Foundation
import UIKit
import Kingfisher
import Alamofire
import SVProgressHUD
import MapKit

extension UIAlertController {
    func alertViewWithTitleAndMessage(_ viewController: UIViewController, message: String) -> Void {
        let alert: UIAlertController = UIAlertController.init(title: "", message: message, preferredStyle: .alert)
        let hideAction: UIAlertAction = UIAlertAction.init(title: "Ok", style: .default, handler: nil)
        alert.addAction(hideAction)
        viewController.present(alert, animated: true, completion: nil)
    }
    
}

extension NSObject {
    func Decode<T: Decodable>(modelClass: T.Type, from inputData: Data) -> T?{
        do {
            let resultData = try JSONDecoder().decode(modelClass.self, from: inputData)
            return resultData
        } catch let message {
            print("JSON serialization error:" + "\(message)")
            return nil
        }
    }
}
extension UIImageView {
    func setImage(with urlString: String){
        guard let url = URL.init(string: urlString) else {
            return
        }
        let resource = ImageResource(downloadURL: url, cacheKey: urlString)
        var kf = self.kf
        kf.indicatorType = .activity
        self.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "PlaceHolder-1.png"))
    }
    //how to use
    //    self.imgVw.setImage(with: your image url)
}

extension Data {
    func hexString() -> String {
        var bytesPointer: UnsafeBufferPointer<UInt8> = UnsafeBufferPointer(start: nil, count: 0)
        self.withUnsafeBytes { (bytes) in
            bytesPointer = UnsafeBufferPointer<UInt8>(start: UnsafePointer(bytes), count:self.count)
        }
        let hexBytes = bytesPointer.map { return String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
    
}
extension MKMapView {
    func fitAllAnnotations() {
        var zoomRect = MKMapRect.null;
        for annotation in annotations {
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.1, height: 0.1);
            zoomRect = zoomRect.union(pointRect);
        }
        setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
    }
}


import UIKit
import Alamofire
import SVProgressHUD
import CoreData
import MapKit

class UserListViewController: UIViewController,UINavigationBarDelegate{
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var tblView: UITableView!
    var arrUsers = [UserDetails]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var isOfflineData = false
    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.delegate = self
        
        fetchFromDB()
        
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if Reachability.isConnectedToNetwork(){
            
            self.getUserList()
            print("Internet Connection Available!")
        }else{
            //fetchFromDB()
            UIAlertController().alertViewWithTitleAndMessage(self, message: "Internet Connection not Available!")
            print("Internet Connection not Available!")
        }
    }
}

//MARK:- -Tableview Data source and Delegates-

extension UserListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrUsers.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "UserInfoCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! UserInfoCell
        cell.selectionStyle = .none
        
        DispatchQueue.main.async {
            cell.imgUser.layer.cornerRadius = 8
            cell.mapView.layer.cornerRadius = 8
            cell.bgView.layer.cornerRadius = 8
        }
        let obj = self.arrUsers[indexPath.row]
        
        if let picture = obj.picture{
            cell.imgUser.setImage(with: picture.large ?? "")
        }
        if let name = obj.name{
            cell.lblUserName.text = "Name : \(name.title ?? "") \(name.first ?? "") \(name.last ?? "")"
        }
        cell.lblGender.text = "Gender : \(obj.gender ?? "")"
        
        if self.isOfflineData{
            cell.mapView.isHidden = true
            UIView.performWithoutAnimation {
                self.tblView.beginUpdates()
                self.tblView.endUpdates()
            }
        }else{
            // DispatchQueue.main.async {
            
            let obj = self.arrUsers[indexPath.row]
            cell.mapView.isHidden = false
            let allAnnotations = cell.mapView.annotations
            cell.mapView.removeAnnotations(allAnnotations)
            let annotation = MKPointAnnotation()
            
            var address = ""
            
            if let data = obj.location?.street?.number{
                address = "\(data),"
            }
            
            if let data = obj.location?.street?.name{
                address = "\(address)\(data),"
            }
            
            if let data = obj.location?.city{
                address = "\(address)\(data),"
            }
            if let data = obj.location?.state{
                address = "\(address)\(data),"
            }
            if let data = obj.location?.country{
                address = "\(address)\(data)"
            }
            
            annotation.title = "Tap to see address"
            annotation.subtitle = address
            
            
            let lat = Double(obj.location?.coordinates?.latitude ?? "0") ?? 0
            let long = Double(obj.location?.coordinates?.longitude ?? "0") ?? 0
            annotation.coordinate =  CLLocationCoordinate2D(latitude: lat, longitude: long)
            cell.mapView.addAnnotation(annotation)
            cell.mapView.centerCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            // newCell.mapView.fitAllAnnotations()
            
            UIView.performWithoutAnimation {
                self.tblView.beginUpdates()
                self.tblView.endUpdates()
            }
            //                        }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
 
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension UserListViewController{
    
    //MARK:- -API CALL-
    func getUserList()  {
        //        currentPage += 1
        let apiToContact = "https://randomuser.me/api/?results=1000"
        
        print("================================================")
        print("Api : \(apiToContact)")
        print("================================================")
        DispatchQueue.main.async {
            SVProgressHUD.show()
            
            AF.request(apiToContact, method: .get)
                .responseJSON { response in
                    print("================================================")
                    print(response)
                    print("================================================")
                    SVProgressHUD.dismiss()
                    switch response.result {
                    case .success:
                        if let modelObject = self.Decode(modelClass: UserListHandlerClass.self, from: response.data!) {
                            if let data = modelObject.results{
                                self.arrUsers = data
                                //                                self.arrUsers.append(contentsOf: data)
                                self.deleteAllData()
                                self.storeInDB()
                                self.isOfflineData = false
                            }
                            self.tblView.reloadData()
                        }
                        break
                    case .failure(let err):
                        UIAlertController().alertViewWithTitleAndMessage(self, message: err.localizedDescription)
                    }
            }
            
        }
    }
    
    //MARK:- SAVE AND FETCH DATA-
    
    func storeInDB() {
        let context = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "User", in: context)
        
        for i in arrUsers {
            
            let user = NSManagedObject(entity: entity!, insertInto: context)
            
            user.setValue(i.gender, forKey: "gender")
            if let name = i.name{
                user.setValue(name.first ?? "", forKey: "first_name")
                user.setValue(name.last ?? "", forKey: "last_name")
                user.setValue(name.title ?? "", forKey: "title")
            }
            
            if let picture = i.picture{
                user.setValue(picture.large ?? "", forKey: "user_image")
            }
            
            
            do {
                try context.save()
                print("Saved Successfully")
            } catch {
                print("Failed saving")
            }
        }
        
    }
    func fetchFromDB() {
        isOfflineData = true
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        //request.predicate = NSPredicate(format: "age = %@", "12")
        request.returnsObjectsAsFaults = false
        let context = appDelegate.persistentContainer.viewContext
        do {
            
            let result = try context.fetch(request)
            print("Fetched results: ", result.count)
            arrUsers.removeAll()
            for data in result as! [NSManagedObject] {
                
                let gender = data.value(forKey: "gender") as! String
                let first_name = data.value(forKey: "first_name") as! String
                let last_name = data.value(forKey: "last_name") as! String
                let title = data.value(forKey: "title") as! String
                let user_image = data.value(forKey: "user_image") as! String
                
                let obj = UserDetails()
                obj.gender = gender
                let name = Name()
                name.first = first_name
                name.last = last_name
                name.title = title
                obj.name = name
                
                let picure = Picture()
                picure.large = user_image
                obj.picture = picure
                self.arrUsers.append(obj)
                //                    arrMovies.append(ObjLocations(name: name, lat: lat, long: long, vicinity: vicinity))
            }
            tblView.reloadData()
            
        } catch {
            print("Failed")
        }
    }
    
    func deleteAllData()
    {
        
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        fetchRequest.returnsObjectsAsFaults = false
        
        do
        {
            let results = try context.fetch(fetchRequest)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                context.delete(managedObjectData)
            }
        } catch let error as NSError {
            print("Detele all data in User error : \(error) \(error.userInfo)")
        }
    }
}


class UserInfoCell: UITableViewCell {
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var bgView: UIView!
}

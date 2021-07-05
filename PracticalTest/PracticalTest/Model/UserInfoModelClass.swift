
import Foundation

class UserListHandlerClass : Decodable {
    let info : Info?
    let results : [UserDetails]?
}


class Info : Decodable {
    
    let page : Int?
    let results : Int?
    let seed : String?
    let version : String?
}

class UserDetails : Decodable {
    
    var cell : String?
    var dob : DateOfBirth?
    var email : String?
    var gender : String?
    var id : Id?
    var location : Location?
    var login : Login?
    var name : Name?
    var nat : String?
    var phone : String?
    var picture : Picture?
    var registered : Registered?
}

class DateOfBirth : Decodable {
    
    let age : Int?
    let date : String?
}
class Id : Decodable {
    
    let name : String?
    let value : String?
}

class Registered : Decodable {
    
    let age : Int?
    let date : String?
}
class Picture : Decodable {
    
    var large : String?
    var medium : String?
    var thumbnail : String?
}
class Name : Decodable {
    
    var first : String?
    var last : String?
    var title : String?
}

class Login : Decodable {
    
    let md5 : String?
    let password : String?
    let salt : String?
    let sha1 : String?
    let sha256 : String?
    let username : String?
    let uuid : String?
}


class Location : Decodable {
    
    let city : String?
    let coordinates : Coordinate?
    let country : String?
//    let postcode : Int?
    let state : String?
    let street : Street?
    let timezone : Timezone?
    
}


class Timezone : Decodable {
    
    let descriptionField : String?
    let offset : String?
}


class Street : Decodable {
    
    let name : String?
    let number : Int?
}


class Coordinate : Decodable {
    
    let latitude : String?
    let longitude : String?
}

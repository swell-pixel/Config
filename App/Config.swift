//
//  Config.swift
//
//  Created by Alexey Yakovlev on 04/29/2017.
//

import UIKit

let loginBackgroundColor  = 0xe8f5e9; //green 50
let confgiBackgroundColor = 0xffebee; //red 50
let buttonTextColor       = 0x007aff; //Apple blue button

let textColor       = "textColor"
let backgroundColor = "backgroundColor"

class LoginForm: NSObject, FXForm
{
    var timestamp = ""
    var username  = ""
    var password  = ""
    var remember  = false
    
    func fields() -> [Any]
    {
        let b = UIColor(loginBackgroundColor)
        return [
            [
                FXFormFieldHeader: timestamp,
                FXFormFieldKey: "username",
                FXFormFieldPlaceholder: "name@example.com",
                FXFormFieldType: FXFormFieldTypeEmail,
                backgroundColor: b,
            ],
            [
                FXFormFieldKey: "password",
                FXFormFieldPlaceholder: "password",
                backgroundColor: b,
            ],
            [
                FXFormFieldKey: "remember",
                FXFormFieldAction: "login:",
                FXFormFieldType: FXFormFieldTypeBoolean,
                backgroundColor: b,
            ],
            [
                FXFormFieldTitle: "Login",
                FXFormFieldAction: "login:",
                textColor: uiColor(buttonTextColor),
                backgroundColor: b,
            ],
        ]
    }
}

class ConfigForm: NSObject, FXForm
{
    var country   = ""
    var operation = 0
    var features  = 0
    var menu1     = 0
    var menu2     = 0
    var login: LoginForm?
    var trace: Trace?
    
    func fields() -> [Any]
    {
        let b = UIColor(confgiBackgroundColor)
        return [
            [
                FXFormFieldKey: "login",
                backgroundColor: uiColor(loginBackgroundColor),
            ],
            [
                FXFormFieldHeader: "",
                FXFormFieldKey: "country",
                FXFormFieldOptions: ["US","BR","CA","GB","IN", "MX"],
                FXFormFieldAction: "country:",
                backgroundColor: b,

            ],
            [
                FXFormFieldKey: "operation",
                FXFormFieldType: FXFormFieldTypeBitfield,
                FXFormFieldOptions: ["No Service"],
                backgroundColor: b,
            ],
            [
                FXFormFieldKey: "features",
                FXFormFieldType: FXFormFieldTypeBitfield,
                FXFormFieldOptions: ["Track", "Estimate", "Locate", "Menu", "Send", "Pay", "Receive"],
                backgroundColor: b,
            ],
            [
                FXFormFieldKey: "menu1",
                FXFormFieldType: FXFormFieldTypeBitfield,
                FXFormFieldOptions: ["Log In", "Contact Us", "FAQ", "Our Services", "Legal"],
                backgroundColor: b,
            ],
            [
                FXFormFieldKey: "menu2",
                FXFormFieldType: FXFormFieldTypeBitfield,
                FXFormFieldOptions: ["Log Out", "My Account", "Contact Us", "FAQ", "Our Services", "Legal"],
                backgroundColor: b,
            ],
            [
                FXFormFieldTitle: "Save",
                FXFormFieldAction: "save:",
                textColor: UIColor(buttonTextColor),
                backgroundColor: b,
            ],
        ]
    }
    
    func extraFields() -> [Any]
    {
        let split = App.rootViewController
        if split.isCollapsed
        {
            return [
                [
                    FXFormFieldHeader: "Debug",
                    FXFormFieldKey: "trace",
                    FXFormFieldViewController: Trace.self,
                    FXFormFieldInline: NSNumber(value: true),
                    backgroundColor: UIColor(traceBackgroundColor),
                ]
            ]
        }
        return []
    }
    
    var loginFieldDescription:String
    {   return login?.timestamp == nil ? "" : login!.timestamp   }
    
    var countryFieldDescription:String
    {   return country.isEmpty ? "" :
            String(format:"%@(%ld, %ld, %ld, %ld)",
                country,
                operation,
                features,
                menu1,
                menu2)
    }
}

class Config: FXFormViewController, UIAlertViewDelegate
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let c = ConfigForm()
        let l = LoginForm()
        c.login = l;
        
        let d = l.fields()[2] as! NSDictionary //remember
        let k = d["key"] as? String ?? ""
        let s = UserDefaults.standard.string(forKey: k) ?? "0"
        l.remember = !s.hasPrefix("0") //TODO: Swift Bool does not flip FXForm switch

        title = "Configuration"
        formController.form = ConfigForm()
        
        let a = FIRAuth.auth()
        if a?.currentUser != nil //authenticated?
        {
            load()
        }
        else
        {
            let ip = IndexPath(row: 0, section: 0)
            let ff = formController.field(for: ip)
            let vc = FXFormViewController()
            vc.field = ff
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func login(_ fc: FXFormTextFieldCell)
    {
        let f = fc.field
        let l = f?.form as! LoginForm
        if let k = f?.key
        {
            if  k.hasPrefix("r") //remember?
            {
                let d = UserDefaults.standard
                d.set(l.remember ? "1":"0", forKey: k)
                d.synchronize()
                Trace.print(String(format:"%@ %@", k, l.remember ? "YES" : "NO"))
            }
        }
        else if l.username.characters.count == 0 ||
                l.password.characters.count == 0 //empty?
        {
            Alert.show(self.title, "Please enter username and password.", "OK")
        }
        else //perform login
        {
            FIRAuth.auth()?.signIn(withEmail: l.username, password: l.password)
            {
                (usr, err) in
                if err == nil
                {
                    l.username = ""
                    l.password = ""
                    l.timestamp = Trace.now()
                    
                    let d = UserDefaults.standard
                    d.set(l.timestamp, forKey: "login.timestamp")
                    d.synchronize()
                    Trace.print("login successful")
                    self.tableView.reloadData()
                    self.load()
                }
                else
                {
                    Alert.show(self.title, err?.localizedDescription, "OK")
                }
            }
        }
    }
    
    func country(_ fc: Any)
    {
        let f = formController.form as! ConfigForm
        let d = UserDefaults.standard
        d.set(f.country, forKey: "country")
        d.synchronize()
        load()
    }

    func load()
    {
        let c = formController.form as! ConfigForm
        let s = UserDefaults.standard.string(forKey: "country")
        c.country = s ?? "US"
        c.login?.timestamp = UserDefaults.standard.string(forKey: "login.timestamp") ?? ""
        
        let path = "config/" + c.country
        let r = FIRDatabase.database().reference(withPath: path)
        r.observeSingleEvent(of: .value, with:
        {
            (snapshot) in
            if let s = snapshot.value as? NSDictionary
            {
                c.operation = s["of"] as! Int
                c.features  = s["ff"] as! Int
                c.menu1     = s["m1"] as! Int
                c.menu2     = s["m2"] as! Int
            }
            else
            {
                c.operation = 0
                c.features  = 0
                c.menu1     = 0
                c.menu2     = 0
            }
            
            Trace.print("load \(c.countryFieldDescription)")
            self.tableView.reloadData();
        })
        {
            (err) in
            Alert.show(self.title, err.localizedDescription, "Close")
        }
    }
    
    func save(_ fc: Any)
    {
        let c = formController.form as! ConfigForm
        let path = "config/" + c.country;
        let r = FIRDatabase.database().reference(withPath: path)
        r.child("of").setValue(c.operation);
        r.child("ff").setValue(c.features);
        r.child("m1").setValue(c.menu1);
        r.child("m2").setValue(c.menu2);
        
        Trace.print("save \(c.countryFieldDescription)")
    }
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt button: Int)
    {
        LOG("Alert.clickedButtonAtIndex %ld", button);
    }
}

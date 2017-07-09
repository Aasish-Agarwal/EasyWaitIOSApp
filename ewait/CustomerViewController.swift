//
//  CustomerViewController.swift
//  ewait
//
//  Created by Aakansha on 20/05/17.
//  Copyright © 2017 Smart Creatives. All rights reserved.
//

import UIKit

class CustomerViewController: UIViewController , UITextFieldDelegate , UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var appointmentsTableView: UITableView!
    @IBOutlet var bookingRefTextFld: UITextField!

    @IBOutlet var queueIdTextField: UITextField!
    
    @IBOutlet var qViewControl: QueueViewerControl!
    
    let  queueStateRetriever = QueueStateRetriever()
    var queue :Queue
    var _mQueueId: String = ""
    private var _appointments: NSMutableArray = []

    //MARK: Actions

    @IBAction func makeAppointment(_ sender: UIButton) {
        var reference : String = self.bookingRefTextFld.text!
        reference = reference.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
        reference = reference.replacingOccurrences(of: "^\\s+", with: "", options: .regularExpression)

        if ( reference.characters.count >= 3 )
        {
            queue.makeAppointment(reference: reference)
            bookingRefTextFld.text = nil
            bookingRefTextFld.resignFirstResponder()
        }
        else
        {
            let alert = UIAlertController(title: "Error", message: "Please provide Booking Reference with 3 or more characters", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func observeQueue(_ sender: UITextField) {
        
    }
    @IBAction func fetchQueueStatus(_ sender: UIButton) {
        let qidtextval : String = self.queueIdTextField.text!
        if ( qidtextval.characters.count > 0 )
        {
            self._mQueueId = qidtextval
            self._appointments.removeAllObjects()
            self.appointmentsTableView.reloadData()

            self.queue.setQueueId(queueId: self._mQueueId)
        }
        
        if ( self._mQueueId.characters.count > 0 ) {
            self.queueStateRetriever.setQueueId(qId: self._mQueueId)
        }
        self.queueIdTextField.text = nil
        self.queueIdTextField.resignFirstResponder()
        
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int
    {
        return _appointments.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:UITableViewCell = self.appointmentsTableView.dequeueReusableCell(withIdentifier: "cell")!

        var cellText = String((_appointments[indexPath.row] as! NSDictionary)["position"] as! Int)
        
        cellText = cellText + ": " + String((_appointments[indexPath.row] as! NSDictionary)["reference"] as! String)
        
        cell.textLabel?.text = cellText
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NSLog("observeValue: keyPath=%@", "\(indexPath.row)")
    }

    override func viewDidDisappear(_ animated: Bool) {
        self.queue.removeObserver(self, forKeyPath: "status")
    }

    override func viewDidAppear(_ animated: Bool) {
        self.queue.addObserver(self, forKeyPath: "status", options: .new, context:nil)
        DispatchQueue.main.async {
            self._appointments = self.queue.getAppointmentList()
            self.appointmentsTableView.reloadData()
        }
    }
    // MARK: - View Life Cycle
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    required init?(coder aDecoder: NSCoder) {
        self.queue = Queue(queueId: self._mQueueId, authenticationService: AuthenticationServiceSingleton.sharedInstance)
        super.init(coder: aDecoder)
    }

    func updateQueueStatusView()
    {
        DispatchQueue.main.async {
            self.qViewControl.queuePosition = self.queueStateRetriever.getQueuePosition()
            self.qViewControl.QueueName = self.queueStateRetriever.getQueueName()
            self.qViewControl.QueueId = self.queueStateRetriever.getQueueId()
            self.qViewControl.QueueServiceRate = self.queueStateRetriever.getQueueServiceRate()
            self.qViewControl.AcceptingAppointments = self.queueStateRetriever.isAcceptingAppointments()
            self.qViewControl.NextPosition = self.queueStateRetriever.availablePosition()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        queueIdTextField.delegate = self
        bookingRefTextFld.delegate = self
        
        queueStateRetriever.addObserver(self, forKeyPath: "position", options: .new, context: nil)
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        //print(keyPath! + " \(String(describing: change?[NSKeyValueChangeKey.newKey]))" )
        
        updateQueueStatusView()
        
        let blank:String  = ""
        let newKeyValue = "\(change?[NSKeyValueChangeKey.newKey] ?? blank)"

        if ( newKeyValue == "AppointmentListUpdated")
        {
            _appointments = queue.getAppointmentList()
            DispatchQueue.main.async {
                self.appointmentsTableView.reloadData()
            }
            NSLog("\(self._appointments.count)")
        } else if (newKeyValue == AuthenticationEvents.TokenExpired)
        {
            let alert = UIAlertController(title: StringsLib.AuthFailTitle, message: StringsLib.AuthMsgTokenExpired, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
  
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

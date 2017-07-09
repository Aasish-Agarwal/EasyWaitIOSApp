//
//  ActiveQueueViewController.swift
//  ewait
//
//  Created by Aakansha on 01/07/17.
//  Copyright © 2017 Smart Creatives. All rights reserved.
//

import UIKit

class ActiveQueueViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
    let  queueStateRetriever = QueueStateRetriever()
    var queue : Queue
    private var _appointments: NSMutableArray = []
    
    @IBOutlet var appointmentsTableView: UITableView!

    @IBOutlet var acceptAppointmentsSwitch: UISwitch!
    
    @IBAction func toggleAppointments(_ sender: UISwitch) {
       queue.acceptAppointments(state: sender.isOn)
        DispatchQueue.main.async {
            self.qViewControl.AcceptingAppointments = sender.isOn
        }
        
        
    }

    @IBAction func refreshAppointmentList(_ sender: UIButton) {
        _appointments.removeAllObjects()
        queue.refreshAppointmentList()
        DispatchQueue.main.async {
            self.appointmentsTableView.reloadData()
        }
    }

    @IBAction func stopSession(_ sender: UIButton) {
        queue.reset()
        queue.resetAllAppointments()
    }
    @IBAction func moveNext(_ sender: UIButton) {
        queue.moveNext()
    }
    private var queueStateChanged = 0
    private var queueStateRefreshed = 1
    
    @IBOutlet var qViewControl: QueueViewerControl!
    
    required init?(coder aDecoder: NSCoder) {
        self.queue = Queue(queueId: EasyWaitApp.sharedInstance.getActiveQueueId(), authenticationService: AuthenticationServiceSingleton.sharedInstance)
        super.init(coder: aDecoder)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.

    }
    
    override func viewDidAppear(_ animated: Bool) {
        queueStateRetriever.addObserver(self, forKeyPath: "position", options: .new, context: &queueStateRefreshed)
        queueStateRetriever.setQueueId(qId: EasyWaitApp.sharedInstance.getActiveQueueId())
        queue.addObserver(self, forKeyPath: "status", options: .new, context: &queueStateChanged)
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        queueStateRetriever.removeObserver(self, forKeyPath: "position")
        queue.removeObserver(self, forKeyPath: "status")
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

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print(keyPath! + " \(String(describing: change?[NSKeyValueChangeKey.newKey]))" )
        if ( context == &queueStateChanged) {
            queueStateRetriever.setQueueId(qId: EasyWaitApp.sharedInstance.getActiveQueueId())

            let blank:String  = ""
            let newKeyValue = "\(change?[NSKeyValueChangeKey.newKey] ?? blank)"
            
            if ( newKeyValue == "AppointmentListUpdated")
            {
                _appointments = queue.getAppointmentList()
                DispatchQueue.main.async {
                    self.appointmentsTableView.reloadData()
                }
                NSLog("\(self._appointments.count)")
            }
        }
        
        if ( context == &queueStateRefreshed)
        {
            DispatchQueue.main.async {

                self.acceptAppointmentsSwitch.isOn = self.queueStateRetriever.isAcceptingAppointments()
            }
            updateQueueStatusView()
            
        }
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

//
//  ViewController.swift
//  Tamawatchi
//
//  Created by Morgan Steffy on 3/15/16.
//  Copyright © 2016 Morgan Steffy. All rights reserved.
//

import UIKit
import SwiftChart
import Firebase

class HomeViewController: UIViewController, ChartDelegate {
    
    @IBOutlet weak var mediaView: UIWebView!
    @IBOutlet weak var chart: Chart!
    
    var myAnimal: String?
    var url: NSString = NSString()
    let ref = Firebase(url: "https://brilliant-fire-4695.firebaseio.com")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref.childByAppendingPath("animals/\(myAnimal!)/url").observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if(snapshot.exists()){
                let requestObj = NSURLRequest(URL: NSURL(string: snapshot.value as! String)!)
                self.mediaView.allowsInlineMediaPlayback = true;
                self.mediaView.loadRequest(requestObj)

            }
            else{
                print("animal: \(self.myAnimal!) doesnt exisit")
            }
            
        })

        chart.delegate = self
        
        // Simple chart
        let series = ChartSeries([0, 6, 6, 5, 7, 4, 1, 4, 5])
        series.color = ChartColors.greenColor()
        chart.areaAlphaComponent = 0.3
        series.area = true
        chart.addSeries(series)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //MARK: Chart delegate
    func didTouchChart(chart: Chart, indexes: Array<Int?>, x: Float, left: CGFloat) {
        for (seriesIndex, dataIndex) in indexes.enumerate() {
            if let _ = chart.valueForSeries(seriesIndex, atIndex: dataIndex) {
              //  print("Touched series: \(seriesIndex): data index: \(dataIndex!); series value: \(value); x-axis value: \(x) (from left: \(left))")
            }
        }
    }
    
    func didFinishTouchingChart(chart: Chart) {
        
    }
    
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        // Redraw chart on rotation
        chart.setNeedsDisplay()
        
    }
}
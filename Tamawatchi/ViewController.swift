//
//  ViewController.swift
//  Tamawatchi
//
//  Created by Morgan Steffy on 3/15/16.
//  Copyright © 2016 Morgan Steffy. All rights reserved.
//

import UIKit
import SwiftChart

class ViewController: UIViewController, ChartDelegate {
    
    @IBOutlet weak var mediaView: UIWebView!
    @IBOutlet weak var chart: Chart!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let requestObj = NSURLRequest(URL: NSURL(string: "https://portal.hdontap.com/s/embed?stream=eagle1_skidaway-HDOT")!)
        mediaView.allowsInlineMediaPlayback = true;
  
        mediaView.loadRequest(requestObj)
        
        
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
            if let value = chart.valueForSeries(seriesIndex, atIndex: dataIndex) {
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
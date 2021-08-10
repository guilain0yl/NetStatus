//
//  AppDelegate.swift
//  PCStatus
//
//  Created by guilain yl on 2021/8/9.
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var menu: NSMenu!
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    let interval = 3
    
    var g_ibytes:UInt32 = 0
    var g_obytes:UInt32 = 0

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        statusItem.menu = menu
        let observer = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        Timer.scheduledTimer(withTimeInterval: TimeInterval(interval), repeats: true){ (ktimer) in
            request_net_speed({ (name,ibytes,obytes,obj) in
                guard obj != nil else { return }
                let myself = Unmanaged<AppDelegate>.fromOpaque(UnsafeMutableRawPointer(obj!)).takeUnretainedValue()
                myself.showText(name: name!, ibytes: ibytes, obytes: obytes)
            }, observer)
        }
    }
    
    func showText(name:UnsafePointer<Int8>,ibytes:UInt32,obytes:UInt32){
        let str:String? = String(validatingUTF8: name)?.trimmingCharacters(in: .whitespaces)
        
        if(str != "en0"){
            return
        }
        
        let text = generateText(ibytes: ibytes, obytes: obytes)

        if let button=statusItem.button{
            button.font=NSFont.systemFont(ofSize: 10)
            button.title=text
        }
    }
    
    private func generateText(ibytes:UInt32,obytes:UInt32)->String{
        var text:String = ""
        
        if(g_ibytes == 0 && g_obytes == 0){
            text = "↑ 0 B/s\n↓ 0 B/s"
        }else{
            let iText = judgeUnit(bytes: ibytes,t_bytes: g_ibytes)
            let oText = judgeUnit(bytes: obytes,t_bytes: g_obytes)
            text = "↑ \(oText)\n↓ \(iText)"
        }
        
        g_ibytes = ibytes
        g_obytes = obytes
        
        return text
    }
    
    private func judgeUnit(bytes:UInt32,t_bytes:UInt32) -> String{
        var i:Double = Double(bytes - t_bytes)/Double(interval)
        if(i < 1024){
            let t = String(format:"%.2f",i)
            return "\(t) B/s"
        }else{
            i /= 1024
        }
        
        if(i < 1024){
            let t = String(format:"%.2f",i)
            return "\(t) KB/s"
        }else{
            i /= 1024
        }
        
        if(i < 1024){
            let t = String(format:"%.2f",i)
            return "\(t) MB/s"
        }else{
            i /= 1024
        }
        
        let t = String(format:"%.2f",i)
        return "\(t) GB/s"
    }
    
    @IBAction func quitApp(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}


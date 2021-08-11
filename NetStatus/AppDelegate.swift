//
//  AppDelegate.swift
//  NetStatus
//
//  Created by guilain yl on 2021/8/11.
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let interval = 3
    private var g_ibytes:UInt32 = 0
    private var g_obytes:UInt32 = 0
    private var g_fontSize:CGFloat = 11
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let barHeight = NSApplication.shared.mainMenu?.menuBarHeight
        testCalcFontSize(barHeight:barHeight!)
        
        let menu = NSMenu()
        menu.addItem(withTitle: "退出", action: #selector(quitApp), keyEquivalent: "")
        statusItem.menu = menu
        
        start();
    }
    
    private func testCalcFontSize(barHeight:CGFloat){
        for i in stride(from: g_fontSize, through: 0, by: -0.1) {
            let textAttr = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: i)]
            let iText = NSAttributedString(string: "↑ 0 B/s\n↓ 0 B/s", attributes: textAttr)
            let iRect = iText.boundingRect(with: NSSize(width: 100, height: 100), options: .usesLineFragmentOrigin)
            if(iRect.height <= barHeight){
                g_fontSize = i
                break
            }
        }
    }
    
    private func start(){
        let observer = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        Timer.scheduledTimer(withTimeInterval: TimeInterval(interval), repeats: true){ (ktimer) in
            request_net_speed({ (name,ibytes,obytes,obj) in
                guard obj != nil else { return }
                let myself = Unmanaged<AppDelegate>.fromOpaque(UnsafeMutableRawPointer(obj!)).takeUnretainedValue()
                myself.showText(name: name!, ibytes: ibytes, obytes: obytes)
            }, observer)
        }
    }
    
    private func showText(name:UnsafePointer<Int8>,ibytes:UInt32,obytes:UInt32){
        let str:String? = String(validatingUTF8: name)?.trimmingCharacters(in: .whitespaces)
        
        if(str != "en0"){
            return
        }
        
        let text = generateText(ibytes: ibytes, obytes: obytes)

        if let button=statusItem.button{
            button.font = NSFont.systemFont(ofSize: g_fontSize)
            button.title = text
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

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @objc func quitApp(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
}


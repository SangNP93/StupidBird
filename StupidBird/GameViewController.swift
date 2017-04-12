//
//  ViewController.swift
//  StupidBird
//
//  Created by SangNP on 4/3/17.
//  Copyright © 2017 SangNP. All rights reserved.
//

import UIKit
import SpriteKit
import GoogleMobileAds

class GameViewController: UIViewController, GADInterstitialDelegate {

    //ADMobBanner
    var banner: GADBannerView!
    var interstitial: GADInterstitial!
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let view = self.view as! SKView? {
            if view.scene == nil {
                if kDebug {
                    view.showsFPS = false
                    view.showsDrawCount = false
                    view.showsNodeCount = false
                    view.showsPhysics = false
                }
                
                let scene = MenuScene(size: kViewSize)
                let transition = SKTransition.fade(with: SKColor.black, duration: 0.5)
                
                view.presentScene(scene, transition: transition)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //Load the banner
        loadAdMobBanner()
        interstitial = createAndLoadInterstitial()
    }
    
    //Load ADMOB banner
    func loadAdMobBanner() {
        banner = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        banner.adUnitID = admobBannerUnitID
        banner.rootViewController = self
        let request = GADRequest()
        //To avoid clicking on your own banner you need to set test devices. To set your test device (one or more), take your phone, go to Settings -> Privacy -> advertising -> and disable limit advertising. Then launch the app in xcode. In the log you will see the ID that adMob give to your phone. Copy and past here the ID. If everything is ok, you will see on your app the test banner.
        //NOTE: NEVER CLICK ON OUR OWN BANNER!!! GOOGLE BAN YOU FOREVER
        request.testDevices = ["XXXXXXXXXXXXXXXXXXXXXXX","YYYYYYYYYYYYYYYYYYYYYYYYYY", "ZZZZZZZZZZZZZZZZZZZZZZZZ"]
        banner.load(request)
        banner.frame = CGRect(origin: CGPoint(x: 0,y :self.view.frame.size.height-self.banner.frame.size.height), size: CGSize(width: self.banner.frame.size.width, height: self.banner.frame.size.height))
        self.view.addSubview(banner)
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: admobInterstitialUnitID)
        interstitial.delegate = self
        let request = GADRequest()
        // Requests test ads on test devices.
        request.testDevices = ["XXXXXXXXXXXXXXXXXXXXXXX","YYYYYYYYYYYYYYYYYYYYYYYYYY", "ZZZZZZZZZZZZZZZZZZZZZZZZ"]
        interstitial.load(request)
        return interstitial
    }
    
    func interstitialDidDismissScreen(ad: GADInterstitial!) {
        interstitial = createAndLoadInterstitial()
    }
    
    //show the interstitial
    func showInterstitialAds() {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}


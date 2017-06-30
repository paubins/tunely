//
//  LoadingViewController.swift
//  Stutter
//
//  Created by Patrick Aubin on 5/30/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import UIKit
import LLSpinner
import AVFoundation
import AnimatablePlayButton
import VIMVideoPlayer
import DynamicButton

class ExportViewController : UIViewController {
    
    let playButton:AnimatablePlayButton = {
        let button = AnimatablePlayButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.bgColor = .black
        button.color = .white
        button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        
        return button
    }()
    
    let resetButtons:UIView = {
        let containerView:UIView = UIView(frame: .zero)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let playStopBackButton:DynamicButton = DynamicButton(style: .close)
        playStopBackButton.strokeColor         = .black
        playStopBackButton.highlightStokeColor = .gray
        playStopBackButton.translatesAutoresizingMaskIntoConstraints = false
        
        playStopBackButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        
        containerView.addSubview(playStopBackButton)
        
        playStopBackButton.heightAnchor.constraint(equalToConstant: 50)
        playStopBackButton.widthAnchor.constraint(equalToConstant: 50)
        
        playStopBackButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        playStopBackButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        return containerView
    }()
    
    let videoPlayerView:VIMVideoPlayerView = {
        let vimPlayer:VIMVideoPlayerView = VIMVideoPlayerView()
        vimPlayer.translatesAutoresizingMaskIntoConstraints = false
        return vimPlayer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.playButton.backgroundColor = UIColor.black
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(screenTapped))
        
        self.videoPlayerView.addGestureRecognizer(tapGestureRecognizer)
        self.videoPlayerView.backgroundColor = UIColor.clear
        
        self.videoPlayerView.player.isLooping = false
        self.videoPlayerView.player.disableAirplay()
        self.videoPlayerView.setVideoFillMode(AVLayerVideoGravityResizeAspectFill)
        
        self.videoPlayerView.delegate = self
        
        self.view.addSubview(self.videoPlayerView)
        self.view.addSubview(self.resetButtons)
        
        self.resetButtons.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.resetButtons.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.resetButtons.heightAnchor.constraint(equalToConstant: 120).isActive = true
        self.resetButtons.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        self.videoPlayerView.addSubview(self.playButton)
        
        self.videoPlayerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.videoPlayerView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.videoPlayerView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.videoPlayerView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        
        self.playButton.centerXAnchor.constraint(equalTo: self.videoPlayerView.centerXAnchor).isActive = true
        self.playButton.centerYAnchor.constraint(equalTo: self.videoPlayerView.centerYAnchor).isActive = true
        self.playButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        self.playButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        self.view.backgroundColor = UIColor.black
        
        self.playButton.select()
    }
    
    func tapped(sender: AnimatablePlayButton) {
        if sender.isSelected {
            sender.deselect()
            self.videoPlayerView.player.play()
            UIView.animate(withDuration: 0.3, animations: {
                self.playButton.alpha = 0
            })
        } else {
            sender.select()
            self.videoPlayerView.player.pause()
            UIView.animate(withDuration: 0.3, animations: {
                self.playButton.alpha = 1
            })
        }
    }
    
    
    func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func screenTapped(sender: UITapGestureRecognizer) {
        self.tapped(sender: self.playButton)
    }
}

extension ExportViewController : VIMVideoPlayerViewDelegate {
    
    func videoPlayerViewDidReachEnd(_ videoPlayerView: VIMVideoPlayerView!) {
        self.tapped(sender: self.playButton)
    }
}

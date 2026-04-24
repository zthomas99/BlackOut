//
//  VideoViewController.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 12/5/19.
//  Copyright © 2019 FervorWare. All rights reserved.
//

import UIKit
import FirebaseStorage
import AVFoundation
import AVKit


class VideoViewController: UIViewController {

    let player:AVPlayer = AVPlayer(playerItem: nil)
    var avpController:AVPlayerViewController?
    var mediaFileName:String?
    var storage:FireStorage = FireStorage()
    
    @IBOutlet weak var playerView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let alphaDimBlack = UIColor.black.withAlphaComponent(0.75)
        self.view.backgroundColor = alphaDimBlack
        
        //Configure AV Player and Layer
        avpController = AVPlayerViewController()
        avpController!.player = player
		player.isMuted = true
        avpController!.view.frame = playerView.bounds
        avpController!.showsPlaybackControls = true
        playerView.addSubview(avpController!.view)
        playerView.autoresizesSubviews = true
        
		do{
			try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
		}
		catch{
			print("Unable to set audio session category to playback.")
		}
        storage.mediaReference.child(mediaFileName!).downloadURL { (URL, Error) in
            if(Error == nil)
            {
                self.avpController?.player?.replaceCurrentItem(with: AVPlayerItem(url: URL!))
                self.avpController?.player?.play()
            }
            else
            {
                print(Error?.localizedDescription)
            }
        }
    }
    
    
    @IBAction func DoneButtonTapped(_ sender: Any)
    {
        avpController?.player?.replaceCurrentItem(with: nil)
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

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

    let player: AVPlayer = AVPlayer(playerItem: nil)
    var avpController: AVPlayerViewController?
    var mediaFileName: String?
    var storage: FireStorage = FireStorage()

    @IBOutlet weak var playerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.75)

        let controller = AVPlayerViewController()
        controller.player = player
        controller.view.frame = playerView.bounds
        controller.showsPlaybackControls = true
        playerView.addSubview(controller.view)
        playerView.autoresizesSubviews = true
        avpController = controller

		do {
			try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
		} catch {
			print("Unable to set audio session category to playback.")
		}

        guard let fileName = mediaFileName else { return }
        storage.mediaReference.child(fileName).downloadURL { (url, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let url = url else { return }
            self.avpController?.player?.replaceCurrentItem(with: AVPlayerItem(url: url))
            self.avpController?.player?.play()
        }
    }

    @IBAction func DoneButtonTapped(_ sender: Any)
    {
        avpController?.player?.replaceCurrentItem(with: nil)
        dismiss(animated: true, completion: nil)
    }
}

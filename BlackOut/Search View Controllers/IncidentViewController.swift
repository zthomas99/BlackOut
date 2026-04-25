//
//  IncidentViewController.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 11/1/18.
//  Copyright © 2018 FervorWare. All rights reserved.
//

import UIKit
import FirebaseStorage
import AVFoundation
import AVKit
import QuartzCore

class IncidentViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextViewDelegate{
   
    //MARK: - Outlet variables
    @IBOutlet var PicVideoCollectionView: UICollectionView!
    @IBOutlet var navigationView: UIImageView!
	@IBOutlet weak var backgroundView: UIImageView!
	@IBOutlet weak var doneButton: UIButton!
	//MARK: - Variables
    var incident:IncidentReport?
    var storage:FireStorage = FireStorage()
    var detailsTableViewController : IncidentDetailsTableViewController?
    var videoController : VideoViewController?
    var imageViewList = [UIImageView]()
    var mediaArry : [String] = []
    var imageDictionary: [Int:UIImageView] = [:]
    var blackBackGroundView:UIView?
    var startingFrame: CGRect?
	var selectedRow : Int = 0
    var mediaFileName:String?
	var minimumBorderSpace : CGFloat = 0.5
    //MARK: - ViewDidLoad Function

    override func viewDidLoad() {
        super.viewDidLoad()
        collectMedia()

		doneButton.backgroundColor = UIColor.black.withAlphaComponent(0.3)
		let borderFrame = CGRect(x: 0, y: navigationView.bounds.size.height - minimumBorderSpace, width: navigationView.frame.width, height: navigationView.frame.height)
		let borderView = UIView(frame: borderFrame)
		borderView.backgroundColor = UIColor(displayP3Red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.3)
		navigationView.addSubview(borderView)

        if mediaArry.count > 0 {
            PicVideoCollectionView.delegate = self
            PicVideoCollectionView.dataSource = self
        } else {
            PicVideoCollectionView.isHidden = true
            for constraint in PicVideoCollectionView.constraints {
                if constraint.firstAttribute == .height {
                    constraint.constant = 0
                }
            }
        }
    }
    
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		guard let businessPhoto = incident?.businessPhoto, businessPhoto != "default.JPG" else {
			navigationView.contentMode = .scaleAspectFit
			navigationView.backgroundColor = .black
			navigationView.image = UIImage(named: "NavigationView.png")
			return
		}
		storage.mediaReference.child(businessPhoto).getData(maxSize: 100000000 * 10000000) { (data, error) in
			if let error = error {
				print(error.localizedDescription)
				return
			}
			guard let data = data, let backgroundImage = UIImage(data: data) else { return }
			self.navigationView.image = backgroundImage
			self.navigationView.contentMode = .scaleAspectFit
			self.backgroundView.image = backgroundImage
			self.backgroundView.contentMode = .scaleAspectFill
			self.backgroundView.addBlurToView()
		}
	}
	
    func collectMedia()
    {
        guard let media = incident?.incidentMedia else { return }
        for (_, value) in media
        {
            if value.count > 0
            {
                mediaArry.append(value[0])
            }
        }
    }
    //Mark: Navigation Function

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "IncidentViewToIncidentDetails")
        {
            detailsTableViewController = segue.destination as? IncidentDetailsTableViewController
            detailsTableViewController?.incident = incident
        }
        else if(segue.identifier == "ToVideo")
        {
            videoController = segue.destination as? VideoViewController
            videoController?.mediaFileName = mediaFileName
        }
    }
    
    @IBAction func DoneButtonHasBeenTapped(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Collection View Functions

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if mediaArry.count < 1
        {
			collectionView.setEmptyMessage("No media uploaded for this report")
        }
        else
        {
            collectionView.restore()
        }
        //return count for number of media in incident media, if incident media is nil return 0
		return mediaArry.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let mediaFileName:String = (mediaArry[indexPath.row])
		let extensionName = FireStorage.shared.RetrieveExtension(fileName: mediaFileName)
        guard let cellAttributes = collectionView.layoutAttributesForItem(at: indexPath),
              let zoomImage = imageDictionary[indexPath.row] else { return }
		let zoomImageInSuperView = collectionView.convert(cellAttributes.frame, to: zoomImage.superview)

		zoomImage.frame = CGRect(x: zoomImageInSuperView.origin.x, y: zoomImageInSuperView.origin.y, width: zoomImageInSuperView.width, height: zoomImageInSuperView.height)

		selectedRow = indexPath.row
        if(extensionName == "JPG")
        {
			self.performStartingZoomInForImageView(startingImageView: zoomImage)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaCell", for: indexPath) as! MediaCollectionViewCell
		cell.contentView.layer.cornerRadius = 10.0
		cell.contentView.layer.masksToBounds = true
        cell.originalImage.frame = cell.frame
        cell.playButton.centerXAnchor.constraint(equalTo: cell.mediaThumbnail.centerXAnchor)
        cell.playButton.centerYAnchor.constraint(equalTo: cell.mediaThumbnail.centerYAnchor)
        cell.playButton.widthAnchor.constraint(equalToConstant: cell.frame.width * 0.95).isActive = true
        cell.playButton.heightAnchor.constraint(equalToConstant: cell.frame.height * 0.95).isActive = true
        cell.playButton.frame = cell.frame
        cell.playButton.tag = indexPath.row
        cell.playButton.addTarget(self, action: #selector(HandlePlayClicks), for: .touchUpInside)
		cell.layer.cornerRadius = 10.0
		cell.layer.borderColor = UIColor(displayP3Red: 254.0/255.0, green: 208.0/255.0, blue: 28.0/255.0, alpha: 0.6).cgColor
		cell.layer.masksToBounds = true
		cell.layer.borderWidth = 0.5
        let mediaFileName = (mediaArry[indexPath.row])
		let ext = FireStorage.shared.RetrieveExtension(fileName: mediaFileName)
		if ext == "JPG"
		{
			cell.playButton.isHidden = true
			cell.mediaThumbnail.loadImage(file: mediaFileName, view:"incident")
			cell.originalImage.loadImage(file: mediaFileName, view: "incident_original")
			self.imageDictionary.updateValue(cell.originalImage, forKey: indexPath.row)
		}
		else if ext == "MOV"
		{
			cell.addSubview(cell.playButton)
			cell.playButton.isHidden = false
			cell.mediaThumbnail.loadThumbnail(file: mediaFileName, view:"incdient")
			cell.originalImage.image = UIImage(named: "video.png")
			self.imageDictionary.updateValue(cell.originalImage, forKey: indexPath.row)
		}
        return cell
    }
    
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		print(section)
		return UIEdgeInsetsMake(0, 0, 0, 0)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 15
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 15
	}
    //MARK: - Set Battery and Time to White
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    //MARK: - Custom Functions
    
    func RetrieveExtension(fileName:String) ->String
    {
        guard let ext = fileName.split(separator: ".").last else { return "" }
        return String(ext)
    }
  
    @objc func HandlePlayClicks(sender:UIButton)
    {
        let index = sender.tag
        mediaFileName = (mediaArry[index])
        let extensionName:String = RetrieveExtension(fileName: mediaFileName!)
        
        if (extensionName == "MOV")
        {
            self.performSegue(withIdentifier: "ToVideo", sender: nil)
        }
    }
  	
	func resizedImage(at image: UIImage, for size: CGSize) -> UIImage? {
	
		let renderer = UIGraphicsImageRenderer(size: size)
		return renderer.image { (context) in
			image.draw(in: CGRect(origin: .zero, size: size))
		}
	}
 
	func performStartingZoomInForImageView(startingImageView: UIImageView)
    {
		startingFrame = startingImageView.convert(startingImageView.frame, to: nil)
        guard let frame = startingFrame, frame.width > 0 else { return }
        let zoomingImageView = UIImageView(frame: frame)
		zoomingImageView.backgroundColor = UIColor.clear
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))

        guard let window = self.view.window else { return }
        blackBackGroundView = UIView(frame: window.frame)
        blackBackGroundView?.backgroundColor = UIColor.black
        blackBackGroundView?.alpha = 0
        window.addSubview(blackBackGroundView!)
        window.addSubview(zoomingImageView)

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.blackBackGroundView?.alpha = 1
            let height = frame.height / frame.width * window.frame.width
            zoomingImageView.frame = CGRect(x: 0, y: 0, width: window.frame.width, height: height)
            zoomingImageView.center = window.center
        }, completion: nil)
    }
    
    @objc func handleZoomOut(tapGesture:UITapGestureRecognizer)
    {
		guard let cell = PicVideoCollectionView.cellForItem(at: IndexPath(row: selectedRow, section: 0)),
		      let zoomingOutImageView = tapGesture.view else { return }
		let relativePos = self.view.convert(cell.frame, from: PicVideoCollectionView)
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseOut, animations: {
			zoomingOutImageView.frame = relativePos
			zoomingOutImageView.layer.cornerRadius = 10.0
			self.blackBackGroundView?.alpha = 0
		}, completion:{(completed) in
			zoomingOutImageView.removeFromSuperview()
		})
	}
}
extension UICollectionView {

    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .white
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "Avenir-Light", size: 18)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel;
    }

    func restore() {
        self.backgroundView = nil
    }
}


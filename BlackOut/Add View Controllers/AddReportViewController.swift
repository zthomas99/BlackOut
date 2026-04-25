import UIKit
import Photos
import PhotosUI
@preconcurrency import Firebase

class AddReportViewController: UIViewController {

    // MARK: - Form Data

    private var businessName: String?
    private var businessLocation: String?
    private var businessCity: String?
    private var businessState: String?
    private var businessZip: String?
    private var businessImage: UIImage?
    private var selectedAssets: [PHAsset] = []
    private var selectedThumbnails: [UIImage] = []
    private var spinnerView: SpinnerViewController?

    private let gold = UIColor(red: 0.929, green: 0.807, blue: 0.041, alpha: 1)
    private let fieldBackground = UIColor(white: 0.11, alpha: 1)
    private let dividerColor = UIColor(white: 0.2, alpha: 1)

    // MARK: - UI Components

    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.keyboardDismissMode = .interactive
        sv.alwaysBounceVertical = true
        return sv
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 24
        return stack
    }()

    private lazy var locationRow: UIView = {
        let container = UIView()
        container.backgroundColor = fieldBackground
        container.layer.cornerRadius = 12
        container.isUserInteractionEnabled = true
        container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(locationTapped)))
        return container
    }()

    private lazy var locationIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "mappin.and.ellipse"))
        iv.tintColor = gold
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.setContentHuggingPriority(.required, for: .horizontal)
        return iv
    }()

    private lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.text = "Search for establishment"
        label.textColor = UIColor(white: 0.5, alpha: 1)
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var locationChevron: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.tintColor = UIColor(white: 0.4, alpha: 1)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.setContentHuggingPriority(.required, for: .horizontal)
        return iv
    }()

    private lazy var locationClearButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        btn.tintColor = UIColor(white: 0.4, alpha: 1)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.isHidden = true
        btn.addTarget(self, action: #selector(clearLocation), for: .touchUpInside)
        return btn
    }()

    private lazy var titleField: UITextField = {
        let field = UITextField()
        field.placeholder = "Title"
        field.font = .systemFont(ofSize: 16)
        field.textColor = .white
        field.backgroundColor = fieldBackground
        field.layer.cornerRadius = 12
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.leftViewMode = .always
        field.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.rightViewMode = .always
        field.attributedPlaceholder = NSAttributedString(string: "Title", attributes: [.foregroundColor: UIColor(white: 0.5, alpha: 1)])
        field.returnKeyType = .next
        field.delegate = self
        return field
    }()

    private lazy var storyTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 16)
        tv.textColor = UIColor(white: 0.5, alpha: 1)
        tv.text = "Tell your story..."
        tv.backgroundColor = fieldBackground
        tv.layer.cornerRadius = 12
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        tv.isScrollEnabled = false
        tv.delegate = self
        return tv
    }()

    private lazy var storyCharCount: UILabel = {
        let label = UILabel()
        label.text = "0/20 min"
        label.textColor = UIColor(white: 0.4, alpha: 1)
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .right
        return label
    }()

    private lazy var mediaCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 90, height: 90)
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.register(MediaThumbnailCell.self, forCellWithReuseIdentifier: MediaThumbnailCell.reuseID)
        cv.register(AddMediaCell.self, forCellWithReuseIdentifier: AddMediaCell.reuseID)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    private lazy var businessPhotoView: UIView = {
        let container = UIView()
        container.isUserInteractionEnabled = true
        container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(businessPhotoTapped)))
        return container
    }()

    private lazy var businessPhotoImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.backgroundColor = fieldBackground
        iv.image = UIImage(systemName: "building.2")
        iv.tintColor = UIColor(white: 0.3, alpha: 1)
        iv.layer.borderWidth = 1
        iv.layer.borderColor = UIColor(white: 0.2, alpha: 1).cgColor
        return iv
    }()

    private lazy var businessPhotoLabel: UILabel = {
        let label = UILabel()
        label.text = "Add a photo of the\nbusiness or building"
        label.textColor = UIColor(white: 0.5, alpha: 1)
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var submitButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("SUBMIT REPORT", for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 17)
        btn.setTitleColor(.black, for: .normal)
        btn.setTitleColor(UIColor.black.withAlphaComponent(0.4), for: .disabled)
        btn.backgroundColor = gold
        btn.layer.cornerRadius = 14
        btn.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        return btn
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupLayout()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        let tapDismiss = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapDismiss.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tapDismiss)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: - Layout

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -40),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
        ])

        addLocationSection()
        addDivider()
        addStorySection()
        addDivider()
        addEvidenceSection()
        addDivider()
        addBusinessPhotoSection()
        addSubmitButton()
    }

    private func addSectionHeader(_ title: String) {
        let label = UILabel()
        label.attributedText = NSAttributedString(
            string: title.uppercased(),
            attributes: [
                .kern: 1.2,
                .foregroundColor: UIColor(white: 0.45, alpha: 1),
                .font: UIFont.systemFont(ofSize: 12, weight: .semibold)
            ]
        )
        contentStack.addArrangedSubview(label)
    }

    private func addDivider() {
        let divider = UIView()
        divider.backgroundColor = dividerColor
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        contentStack.addArrangedSubview(divider)
    }

    private func addLocationSection() {
        addSectionHeader("Where did this happen?")

        locationRow.translatesAutoresizingMaskIntoConstraints = false
        locationRow.addSubview(locationIcon)
        locationRow.addSubview(locationLabel)
        locationRow.addSubview(locationChevron)
        locationRow.addSubview(locationClearButton)

        NSLayoutConstraint.activate([
            locationRow.heightAnchor.constraint(equalToConstant: 52),
            locationIcon.leadingAnchor.constraint(equalTo: locationRow.leadingAnchor, constant: 14),
            locationIcon.centerYAnchor.constraint(equalTo: locationRow.centerYAnchor),
            locationIcon.widthAnchor.constraint(equalToConstant: 22),
            locationLabel.leadingAnchor.constraint(equalTo: locationIcon.trailingAnchor, constant: 10),
            locationLabel.centerYAnchor.constraint(equalTo: locationRow.centerYAnchor),
            locationLabel.trailingAnchor.constraint(equalTo: locationClearButton.leadingAnchor, constant: -8),
            locationChevron.trailingAnchor.constraint(equalTo: locationRow.trailingAnchor, constant: -14),
            locationChevron.centerYAnchor.constraint(equalTo: locationRow.centerYAnchor),
            locationChevron.widthAnchor.constraint(equalToConstant: 14),
            locationClearButton.trailingAnchor.constraint(equalTo: locationRow.trailingAnchor, constant: -14),
            locationClearButton.centerYAnchor.constraint(equalTo: locationRow.centerYAnchor),
            locationClearButton.widthAnchor.constraint(equalToConstant: 28),
            locationClearButton.heightAnchor.constraint(equalToConstant: 28),
        ])

        contentStack.addArrangedSubview(locationRow)
    }

    private func addStorySection() {
        addSectionHeader("What happened?")

        titleField.translatesAutoresizingMaskIntoConstraints = false
        titleField.heightAnchor.constraint(equalToConstant: 48).isActive = true
        contentStack.addArrangedSubview(titleField)

        storyTextView.translatesAutoresizingMaskIntoConstraints = false
        let heightConstraint = storyTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 140)
        heightConstraint.isActive = true
        contentStack.addArrangedSubview(storyTextView)

        storyCharCount.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(storyCharCount)
        contentStack.setCustomSpacing(4, after: storyTextView)
    }

    private func addEvidenceSection() {
        addSectionHeader("Evidence")

        mediaCollectionView.heightAnchor.constraint(equalToConstant: 90).isActive = true
        contentStack.addArrangedSubview(mediaCollectionView)

        let helper = UILabel()
        helper.text = "Photos & videos from the scene"
        helper.textColor = UIColor(white: 0.4, alpha: 1)
        helper.font = .systemFont(ofSize: 12)
        contentStack.addArrangedSubview(helper)
        contentStack.setCustomSpacing(4, after: mediaCollectionView)
    }

    private func addBusinessPhotoSection() {
        addSectionHeader("Establishment Photo (Optional)")

        businessPhotoView.translatesAutoresizingMaskIntoConstraints = false
        businessPhotoView.addSubview(businessPhotoImageView)
        businessPhotoView.addSubview(businessPhotoLabel)

        NSLayoutConstraint.activate([
            businessPhotoView.heightAnchor.constraint(equalToConstant: 80),
            businessPhotoImageView.leadingAnchor.constraint(equalTo: businessPhotoView.leadingAnchor),
            businessPhotoImageView.topAnchor.constraint(equalTo: businessPhotoView.topAnchor),
            businessPhotoImageView.bottomAnchor.constraint(equalTo: businessPhotoView.bottomAnchor),
            businessPhotoImageView.widthAnchor.constraint(equalToConstant: 80),
            businessPhotoLabel.leadingAnchor.constraint(equalTo: businessPhotoImageView.trailingAnchor, constant: 14),
            businessPhotoLabel.centerYAnchor.constraint(equalTo: businessPhotoView.centerYAnchor),
        ])

        contentStack.addArrangedSubview(businessPhotoView)
    }

    private func addSubmitButton() {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: 8).isActive = true
        contentStack.addArrangedSubview(spacer)

        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.heightAnchor.constraint(equalToConstant: 54).isActive = true
        contentStack.addArrangedSubview(submitButton)
    }

    // MARK: - Actions

    @objc private func locationTapped() {
        let storyboard = UIStoryboard(name: "Add", bundle: nil)
        guard let estVC = storyboard.instantiateViewController(withIdentifier: "EstablishmentController") as? EstablishmentViewController else { return }
        estVC.delegate = self
        estVC.modalPresentationStyle = .fullScreen
        present(estVC, animated: true)
    }

    @objc private func clearLocation() {
        businessName = nil
        businessLocation = nil
        businessCity = nil
        businessState = nil
        businessZip = nil
        locationLabel.text = "Search for establishment"
        locationLabel.textColor = UIColor(white: 0.5, alpha: 1)
        locationChevron.isHidden = false
        locationClearButton.isHidden = true
    }

    @objc private func businessPhotoTapped() {
        let alert = UIAlertController(title: "Establishment Photo", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default) { [weak self] _ in
            self?.presentBusinessPhotoPicker()
        })
        if businessImage != nil {
            alert.addAction(UIAlertAction(title: "Remove Photo", style: .destructive) { [weak self] _ in
                self?.businessImage = nil
                self?.businessPhotoImageView.image = UIImage(systemName: "building.2")
                self?.businessPhotoImageView.contentMode = .scaleAspectFit
                self?.businessPhotoImageView.tintColor = UIColor(white: 0.3, alpha: 1)
                self?.businessPhotoLabel.text = "Add a photo of the\nbusiness or building"
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func presentBusinessPhotoPicker() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = false
        present(picker, animated: true)
    }

    @objc private func addMediaTapped() {
        let alert = UIAlertController(title: "Add Evidence", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { [weak self] _ in
            self?.presentMediaPicker()
        })
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Take Photo or Video", style: .default) { [weak self] _ in
                self?.presentCamera()
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func presentMediaPicker() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 10
        config.filter = .any(of: [.images, .videos])
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func presentCamera() {
        let camera = UIImagePickerController()
        camera.sourceType = .camera
        camera.mediaTypes = ["public.image", "public.movie"]
        camera.delegate = self
        present(camera, animated: true)
    }

    @objc private func submitTapped() {
        guard let storyText = storyTextView.text,
              storyTextView.textColor != UIColor(white: 0.5, alpha: 1),
              storyText.count >= 20 else {
            AlertController.showAlert(self, title: "Missing Story", message: "Please enter a description of at least 20 characters.")
            return
        }
        guard let titleText = titleField.text, titleText.count >= 5 else {
            AlertController.showAlert(self, title: "Missing Title", message: "Please enter a title of at least 5 characters.")
            return
        }
        guard let location = businessLocation, !location.isEmpty else {
            AlertController.showAlert(self, title: "Missing Location", message: "Please search for and select an establishment.")
            return
        }
        uploadReport(title: titleText, story: storyText)
    }

    @objc override func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Upload

    private func uploadReport(title: String, story: String) {
        var businessPhotoFileName = "default.JPG"

        if let image = businessImage {
            let identifier = UUID().uuidString
            businessPhotoFileName = identifier + ".JPG"
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                let uploadRef = FireStorage.shared.mediaReference.child(businessPhotoFileName)
                uploadRef.putData(imageData, metadata: nil) { _, error in
                    if let error = error { print(error) }
                }
            }
        }

        let reference = FireDatabaseService.shared.incidentReference.childByAutoId()
        let dateString = String(describing: Date())
        let currentUser = Auth.auth().currentUser?.displayName ?? ""
        let hasMedia = !selectedAssets.isEmpty

        var parameters: [String: Any] = [
            "username": currentUser,
            "businessName": businessName ?? "",
            "descriptionMessage": story,
            "reportTitle": title,
            "businessLocation": businessLocation ?? "",
            "businessPhoto": businessPhotoFileName,
            "replyCount": 0,
            "businessCity": businessCity ?? "",
            "state": businessState ?? "",
            "zipCode": businessZip ?? "",
            "date": dateString
        ]
        if !hasMedia {
            parameters["NoMedia"] = true
        }

        showSpinner()
        reference.setValue(parameters) { [weak self] error, _ in
            Task { @MainActor in
                guard let self = self else { return }
                if error != nil {
                    self.hideSpinner()
                    AlertController.showAlert(self, title: "Upload Failure", message: "The report failed to upload. Please try again later.")
                    return
                }
                if hasMedia {
                    self.uploadSelectedMedia(reference: reference) { [weak self] uploadError in
                        Task { @MainActor in
                            guard let self = self else { return }
                            self.hideSpinner()
                            if uploadError != nil {
                                self.resetForm()
                                AlertController.showAlert(self, title: "Media Upload Error", message: "Unable to upload selected media. Please try uploading through My Reports.")
                            } else {
                                self.resetForm()
                                AlertController.showAlert(self, title: "Successful Upload", message: "The report was successfully uploaded. You can now search for it under the Search screen.")
                            }
                        }
                    }
                } else {
                    self.hideSpinner()
                    self.resetForm()
                    AlertController.showAlert(self, title: "Successful Upload", message: "The report was successfully uploaded. You can now search for it under the Search screen.")
                }
            }
        }
    }

    private final class UploadProgress: @unchecked Sendable {
        var completedCount = 0
        var errorCount = 0
    }

    private func uploadSelectedMedia(reference: DatabaseReference, completion: @Sendable @escaping (Error?) -> Void) {
        let assets = selectedAssets
        let assetCount = assets.count
        let progress = UploadProgress()
        let manager = PHImageManager.default()

        for asset in assets {
            let identifier = UUID().uuidString
            switch asset.mediaType {
            case .image:
                let fileName = identifier + ".JPG"
                let options = PHImageRequestOptions()
                options.version = .original
                options.isNetworkAccessAllowed = true
                manager.requestImageDataAndOrientation(for: asset, options: options) { data, _, _, _ in
                    guard let data = data else {
                        progress.errorCount += 1
                        progress.completedCount += 1
                        if progress.errorCount == assetCount {
                            FireDatabaseService.shared.InsertNoMediaChild(reference: reference) {
                                if progress.completedCount == assetCount { completion(nil) }
                            }
                        }
                        return
                    }
                    FireStorage.shared.mediaReference.child(fileName).putData(data, metadata: nil) { _, error in
                        if error != nil {
                            progress.errorCount += 1
                            progress.completedCount += 1
                            if progress.errorCount == assetCount {
                                FireDatabaseService.shared.InsertNoMediaChild(reference: reference) {
                                    if progress.completedCount == assetCount { completion(nil) }
                                }
                            }
                        } else {
                            progress.completedCount += 1
                            FireDatabaseService.shared.AddMediaToReference(reference: reference, media: fileName) {
                                if progress.completedCount == assetCount { completion(nil) }
                            }
                        }
                    }
                }
            case .video:
                let fileName = identifier + ".MOV"
                let options = PHVideoRequestOptions()
                options.isNetworkAccessAllowed = true
                manager.requestAVAsset(forVideo: asset, options: options) { avAsset, _, _ in
                    guard let urlAsset = avAsset as? AVURLAsset,
                          let videoData = try? Data(contentsOf: urlAsset.url) else {
                        progress.errorCount += 1
                        progress.completedCount += 1
                        if progress.errorCount == assetCount {
                            FireDatabaseService.shared.InsertNoMediaChild(reference: reference) {
                                if progress.completedCount == assetCount { completion(nil) }
                            }
                        }
                        return
                    }
                    FireStorage.shared.mediaReference.child(fileName).putData(videoData, metadata: nil) { _, error in
                        if error != nil {
                            progress.errorCount += 1
                            progress.completedCount += 1
                            if progress.errorCount == assetCount {
                                FireDatabaseService.shared.InsertNoMediaChild(reference: reference) {
                                    if progress.completedCount == assetCount { completion(nil) }
                                }
                            }
                        } else {
                            progress.completedCount += 1
                            FireDatabaseService.shared.AddMediaToReference(reference: reference, media: fileName) {
                                if progress.completedCount == assetCount { completion(nil) }
                            }
                        }
                    }
                }
            default:
                progress.completedCount += 1
                if progress.completedCount == assetCount { completion(nil) }
            }
        }
    }

    // MARK: - Spinner

    private func showSpinner() {
        let spinner = SpinnerViewController()
        addChild(spinner)
        spinner.view.frame = view.bounds
        view.addSubview(spinner.view)
        spinner.didMove(toParent: self)
        spinnerView = spinner
    }

    private func hideSpinner() {
        spinnerView?.willMove(toParent: nil)
        spinnerView?.view.removeFromSuperview()
        spinnerView?.removeFromParent()
        spinnerView = nil
    }

    // MARK: - Reset

    private func resetForm() {
        clearLocation()
        titleField.text = ""
        storyTextView.text = "Tell your story..."
        storyTextView.textColor = UIColor(white: 0.5, alpha: 1)
        storyCharCount.text = "0/20 min"
        businessImage = nil
        businessPhotoImageView.image = UIImage(systemName: "building.2")
        businessPhotoImageView.contentMode = .scaleAspectFit
        businessPhotoImageView.tintColor = UIColor(white: 0.3, alpha: 1)
        businessPhotoLabel.text = "Add a photo of the\nbusiness or building"
        selectedAssets.removeAll()
        selectedThumbnails.removeAll()
        mediaCollectionView.reloadData()
    }

    // MARK: - Keyboard

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let inset = frame.height - view.safeAreaInsets.bottom
        scrollView.contentInset.bottom = inset
        scrollView.verticalScrollIndicatorInsets.bottom = inset
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }
}

// MARK: - EstablishmentControllerDelegate

extension AddReportViewController: EstablishmentControllerDelegate {
    func sendEstablishmentInfo(location: String, city: String, state: String, zip: String, name: String) {
        businessName = name
        businessLocation = location
        businessCity = city
        businessState = state
        businessZip = zip

        locationLabel.text = "\(name)\n\(location)"
        locationLabel.textColor = .white
        locationLabel.numberOfLines = 2
        locationLabel.font = .systemFont(ofSize: 14)
        locationChevron.isHidden = true
        locationClearButton.isHidden = false
    }
}

// MARK: - PHPickerViewControllerDelegate

extension AddReportViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard !results.isEmpty else { return }

        let identifiers = results.compactMap(\.assetIdentifier)
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
        var assets: [PHAsset] = []
        fetchResult.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }
        selectedAssets.append(contentsOf: assets)

        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .opportunistic

        for asset in assets {
            manager.requestImage(for: asset, targetSize: CGSize(width: 180, height: 180), contentMode: .aspectFill, options: options) { [weak self] image, _ in
                guard let self = self, let image = image else { return }
                DispatchQueue.main.async {
                    self.selectedThumbnails.append(image)
                    self.mediaCollectionView.reloadData()
                }
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension AddReportViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        if picker.sourceType == .camera {
            if let image = info[.originalImage] as? UIImage {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                if let asset = fetchLatestAsset() {
                    selectedAssets.append(asset)
                    selectedThumbnails.append(image)
                    mediaCollectionView.reloadData()
                }
            }
        } else {
            if let image = info[.originalImage] as? UIImage {
                businessImage = image
                businessPhotoImageView.image = image
                businessPhotoImageView.contentMode = .scaleAspectFill
                businessPhotoImageView.tintColor = nil
                businessPhotoLabel.text = "Tap to change"
            }
        }
    }

    private func fetchLatestAsset() -> PHAsset? {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.fetchLimit = 1
        return PHAsset.fetchAssets(with: options).firstObject
    }
}

// MARK: - UITextFieldDelegate

extension AddReportViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleField {
            storyTextView.becomeFirstResponder()
        }
        return true
    }
}

// MARK: - UITextViewDelegate

extension AddReportViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor(white: 0.5, alpha: 1) {
            textView.text = ""
            textView.textColor = gold
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Tell your story..."
            textView.textColor = UIColor(white: 0.5, alpha: 1)
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        let count = textView.text.count
        if count < 20 {
            storyCharCount.text = "\(count)/20 min"
            storyCharCount.textColor = UIColor(white: 0.4, alpha: 1)
        } else {
            storyCharCount.text = "\(count) characters"
            storyCharCount.textColor = gold
        }
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension AddReportViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedThumbnails.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddMediaCell.reuseID, for: indexPath) as! AddMediaCell
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaThumbnailCell.reuseID, for: indexPath) as! MediaThumbnailCell
        cell.imageView.image = selectedThumbnails[indexPath.item - 1]
        let asset = selectedAssets[indexPath.item - 1]
        cell.showVideoBadge = (asset.mediaType == .video)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            addMediaTapped()
        } else {
            let idx = indexPath.item - 1
            selectedAssets.remove(at: idx)
            selectedThumbnails.remove(at: idx)
            collectionView.reloadData()
        }
    }
}

// MARK: - Collection View Cells

private class AddMediaCell: UICollectionViewCell {
    static let reuseID = "AddMediaCell"

    private let iconView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "plus"))
        iv.tintColor = UIColor(red: 0.929, green: 0.807, blue: 0.041, alpha: 1)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let label: UILabel = {
        let l = UILabel()
        l.text = "Add"
        l.textColor = UIColor(red: 0.929, green: 0.807, blue: 0.041, alpha: 1)
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor(white: 0.11, alpha: 1)
        contentView.layer.cornerRadius = 10
        contentView.layer.borderWidth = 1.5
        contentView.layer.borderColor = UIColor(red: 0.929, green: 0.807, blue: 0.041, alpha: 0.4).cgColor

        contentView.addSubview(iconView)
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -8),
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28),
            label.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 2),
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }
}

private class MediaThumbnailCell: UICollectionViewCell {
    static let reuseID = "MediaThumbnailCell"

    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 10
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let videoBadge: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "play.fill"))
        iv.tintColor = .white
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isHidden = true
        return iv
    }()

    var showVideoBadge: Bool = false {
        didSet { videoBadge.isHidden = !showVideoBadge }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(videoBadge)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            videoBadge.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            videoBadge.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            videoBadge.widthAnchor.constraint(equalToConstant: 24),
            videoBadge.heightAnchor.constraint(equalToConstant: 24),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        showVideoBadge = false
    }
}
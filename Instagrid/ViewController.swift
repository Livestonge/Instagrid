//
//  ViewController.swift
//  Instagrid
//
//  Created by Awaleh Moussa Hassan on 05/11/2021.
//

import UIKit

class ViewController: UIViewController {
	
//	Variable to keep track of the selected layout view
	var selectedLayoutView: UIImageView?
//	Variable for holding the image of the selected layout.
	var primaryImageOfTheSelectedLayout: UIImage!
//	Variable for the index of the user selected subview.
	var indexOfSelectedSubview: Int?
	var imagesToShare = [UIImage]()

//	Stack views composing the central view.
	@IBOutlet var upperStackView: UIStackView!
	@IBOutlet var lowerStackView: UIStackView!
// The tap gesture recognizer of the standard layout view.
	@IBOutlet var selectingStandardLayoutTapGesture: UITapGestureRecognizer!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Checks if the tap is coming from an ImageView.
		guard let imageView = selectingStandardLayoutTapGesture.view as? UIImageView
		else {return}
		
		updateAndstoreDetailOf(selectedLayout: imageView)
		
	}
	
	private func updateAndstoreDetailOf(selectedLayout: UIImageView){
		
		//	I store the primary image of this view in a variable
				primaryImageOfTheSelectedLayout = selectedLayout.image
		//  Assign the selected image to this layout view.
				selectedLayout.image = UIImage(named: "Selected")
		//	Store this layout view in the variable.
				selectedLayoutView = selectedLayout
	}
	
	@IBAction
	func didTapOnLayoutView(sender: UITapGestureRecognizer){
		
		guard let imageView = sender.view as? UIImageView else {return}
//	Restore the image for the former selected layout view
		selectedLayoutView?.image = primaryImageOfTheSelectedLayout
//	Then store and update for the currently tapped layout view
		updateAndstoreDetailOf(selectedLayout: imageView)
//		Update the layout of the central view
		updateLayout(selectedTag: sender.view?.tag ?? 0)
	}
	@IBAction
	func didTapUploadImage(sender: UITapGestureRecognizer){
		guard let tag = sender.view?.tag else { return }
		uploadImageToViewWith(tag: tag)
	}
  
//	This method is for updating the layout of the central view.
	private func updateLayout(selectedTag: Int){
		
		// Make one of the subview hidden or not depending on the selected layout.
		switch selectedTag{
		case 1:
			lowerStackView.subviews.last?.isHidden = false
			upperStackView.subviews.last?.isHidden = true
		case 2:
			upperStackView.subviews.last?.isHidden = false
			lowerStackView.subviews.last?.isHidden = true
		case 3:
//	Here we will have 4 square views in the central view.
			upperStackView.subviews.forEach{ $0.isHidden = false }
			lowerStackView.subviews.forEach{ $0.isHidden = false }
		default: break
		}
	}
	@IBAction
	func uploadImageToViewWith(tag: Int){
		// Stores the currently selected subview in the central view
		indexOfSelectedSubview = tag
		// Initiate the image picker
		let picker = UIImagePickerController()
		// Allow the user to edit the selected image.
		picker.allowsEditing = true
		// Assign self as the delegate to this picker.
		picker.delegate = self
		// Present modally the picker.
		present(picker, animated: true)
	}
	
	@IBAction
	func didTapShareButton(sender: UISwipeGestureRecognizer){
		
		animateUserSwipingAction(sender)
		// Checks if there is any image to share.
		guard imagesToShare.isEmpty == false else  { return }
		// Instantiates a activityController with the images to share.
		let activityController = UIActivityViewController(activityItems: imagesToShare,
																											applicationActivities: nil)
		// Make sur the user don't restore his image to his photo library.
		activityController.excludedActivityTypes = [.saveToCameraRoll]
		self.present(activityController, animated: true)
	}
	
	private func animateUserSwipingAction(_ sender: UISwipeGestureRecognizer){
		
		var upward = true
		// Checks the value of direction property of the swipeGesture.
		if sender.direction == .left { upward = false }
		// we displace the view 50 points to the left.
		let translationXaxis = upward == false ? 50.0 : 0.0
		// we displace the view 50 points upward.
		let translationYaxis = upward == true ? 50.0 : 0.0
		// Animate the displacement of the view.
		UIView.animate(withDuration: 1){
			sender.view?.transform = .init(translationX: translationXaxis,
																		 y: translationYaxis)
		}
		// after animation, the view is back to his initial position.
		sender.view?.transform = .identity
	}

}



extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
	
	// This function is called when the user has selected an image.
	func imagePickerController(_ picker: UIImagePickerController,
														 didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		// Retrieve the user selected image.
		if let uiimage = info[.editedImage] as? UIImage {
      // Store the image in the variable.
			imagesToShare.append(uiimage)
			// Update the correct subview in the central view.
			switch indexOfSelectedSubview {
			case 1 :
				let view = upperStackView.subviews.first
				assignImageTo(subview: view, uiimage: uiimage)
			case 2:
				let view = upperStackView.subviews.last
				assignImageTo(subview: view, uiimage: uiimage)
			case 3:
				let view = lowerStackView.subviews.first
				assignImageTo(subview: view, uiimage: uiimage)
			case 4:
				let view = lowerStackView.subviews.last
				assignImageTo(subview: view, uiimage: uiimage)
			default: break
				
			}
		}
		// Dismiss the picker view.
		dismiss(animated: true)
	}
	
	private func assignImageTo(subview: UIView?, uiimage: UIImage) {
		
		// Checks if we got a view
		guard let baseView = subview else { return }
		// Checks the type of each subview.
		for view in baseView.subviews {
      // if we have a button, we make the button hidden.
			if (view as? UIButton) != nil{
				view.isHidden = true
				// In case of an UIImageView, we update his image property.
			}else if (view as? UIImageView) != nil {
				(view as! UIImageView).image = uiimage
				// then we return from here.
				return
			}
		}
		// if the view has not subview of type UIImageview then we add an instance of uiimageView.
		addImageViewTo(view: baseView, with: uiimage)
	}
	
	private func addImageViewTo(view: UIView, with image: UIImage){
		let uiImageView = UIImageView()
		uiImageView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(uiImageView)
		uiImageView.image = image
		// Make sur the image fill the whole view.
		uiImageView.contentMode = .scaleToFill
		// Create constraint to the imageView.
		let centerX = uiImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
		let centerY = uiImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
		let width = uiImageView.widthAnchor.constraint(equalTo: view.widthAnchor)
		let height = uiImageView.heightAnchor.constraint(equalTo: view.heightAnchor)
		NSLayoutConstraint.activate([ centerX, centerY, width, height])
	}
}

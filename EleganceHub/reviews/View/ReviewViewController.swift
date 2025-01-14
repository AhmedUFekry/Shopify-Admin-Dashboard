//
//  ReviewViewController.swift
//  EleganceHub
//
//  Created by Shimaa on 18/06/2024.
//

import UIKit

class ReviewViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource{
    
    var reviewViewModel = ReviewViewModel()
    var displayedReviews: [Review] = []
    var allReviews: [Review] = []
    var initialReviews: [Review] = []
    var showAllReviews: Bool = false
    
    @IBOutlet weak var tableViewReview: UITableView!
    
    private var customAppBar: CustomAppBarUIView!
        private var toggleButton: UIButton!
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            setupCustomAppBar()
            allReviews = reviewViewModel.getReviews()
            initialReviews = getRandomReviews(from: allReviews, count: 5)
            displayedReviews = initialReviews

            tableViewReview.delegate = self
            tableViewReview.dataSource = self
            
            let nib = UINib(nibName: "CartTableViewCell", bundle: nil)
            tableViewReview.register(nib, forCellReuseIdentifier: "CartTableViewCell")
            
            updateToggleButton()
        }

        private func setupCustomAppBar() {
            customAppBar = CustomAppBarUIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
            view.addSubview(customAppBar)
            
            customAppBar.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                customAppBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                customAppBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                customAppBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                customAppBar.heightAnchor.constraint(equalToConstant: 60)
            ])
            
            customAppBar.lableTitle.text = "Reviews"
            customAppBar.backBtn.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
            
            customAppBar.trailingIcon.isHidden = true
            customAppBar.secoundTrailingIcon.isHidden = true
            
            toggleButton = UIButton(type: .system)
            toggleButton.addTarget(self, action: #selector(toggleButtonTapped), for: .touchUpInside)
            customAppBar.addSubview(toggleButton)
            
            toggleButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                toggleButton.trailingAnchor.constraint(equalTo: customAppBar.trailingAnchor, constant: -16),
                toggleButton.centerYAnchor.constraint(equalTo: customAppBar.centerYAnchor)
            ])
            
            toggleButton.setTitleColor(.darkGray, for: .normal)
            toggleButton.titleLabel?.font = UIFont(name: "Palatino", size: 17.0)
        }
        
        @objc private func toggleButtonTapped() {
            showAllReviews = !showAllReviews
            updateToggleButton()
            displayedReviews = showAllReviews ? allReviews : initialReviews
            tableViewReview.reloadData()
        }
        
        private func updateToggleButton() {
            let title = showAllReviews ? "Show less" : "Show more"
            toggleButton.setTitle(title, for: .normal)
            
        }
        
        func getRandomReviews(from reviewList: [Review], count: Int) -> [Review] {
            let shuffledReviews = reviewList.shuffled()
            let randomReviews = Array(shuffledReviews.prefix(count))
            return randomReviews
        }
        
        @objc private func backButtonTapped() {
            navigationController?.popViewController(animated: true)
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return displayedReviews.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CartTableViewCell", for: indexPath) as! CartTableViewCell
            
            let review = displayedReviews[indexPath.row]
            cell.productNameLabel.text = review.image
            cell.productPriceLabel.text = review.text
            cell.productVarintLabel.text = review.date
            cell.productImage.image = UIImage(named: "person")
            
            cell.IncreaseQuantityBtn.isHidden = true
            
            if let rate = review.rate {
                cell.productQuantityLabel.text = String(format: "%.1f", rate)
            }
            
            cell.decreaseQuantityBtn.setImage(UIImage(named: "star"), for: .normal)
            
            return cell
        }
    }

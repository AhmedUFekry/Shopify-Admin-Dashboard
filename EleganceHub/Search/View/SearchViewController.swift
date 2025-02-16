//
//  SearchViewController.swift
//  EleganceHub
//
//  Created by Shimaa on 01/06/2024.
//

import UIKit
import RxSwift
import RxCocoa


class SearchViewController: UIViewController ,UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate{
    
    @IBOutlet weak var txtSearchBar: UISearchBar!
    @IBOutlet weak var searchCollectionView: UICollectionView!
    @IBOutlet weak var filterByPriceButton: UIButton!
    @IBOutlet weak var filterByLettersButton: UIButton!
    @IBOutlet weak var removeFiltersButton: UIButton!
    @IBOutlet weak var noConnectionImage: UIImageView!
    @IBOutlet weak var noConnectionLabel: UILabel!
    
    var currencyViewModel = CurrencyViewModel()
    var rate : Double?
    var userCurrency:String?

    var disposeBag = DisposeBag()
    var searchViewModel: SearchViewModel!
    var products: [ProductModel] = []
    var productList: [ProductModel] = []
    var isPriceFiltered: Bool = false
    var isLettersFiltered:Bool = false
    
    var networkPresenter :NetworkManager?
    var isConnected:Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        configureRoundedButtons()
        setupButtons()
                
        self.searchCollectionView.register(UINib(nibName: "CategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "categoryCell")
        self.searchCollectionView.delegate = self
        self.searchCollectionView.dataSource = self
        self.txtSearchBar.delegate = self
        searchViewModel = SearchViewModel(networkManager: NetworkService())
        searchViewModel.bindResultToViewController = { [weak self] in
            DispatchQueue.main.async {
                self?.products = self?.searchViewModel.result ?? []
                self?.productList = self?.products ?? []
                self?.searchCollectionView.reloadData()
            }
        }
        noConnectionLabel.isHidden = true
        noConnectionImage.isHidden = true
        setupSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        networkPresenter = NetworkManager(vc: self)
    }
    
    func configureRoundedButtons() {
        let buttons: [UIButton] = [filterByPriceButton, filterByLettersButton]
        buttons.forEach { button in
            button.layoutIfNeeded()
            button.layer.cornerRadius = button.bounds.height / 2
            button.clipsToBounds = true
            button.layer.borderWidth = 0.1
            button.layer.borderColor = UIColor.white.cgColor
           // button.layer.borderColor = UIColor.black.cgColor
        }
    }

    func setupButtons() {
        let buttons: [UIButton] = [filterByPriceButton, filterByLettersButton]
        buttons.forEach { button in
            button.backgroundColor = .white
            button.setTitleColor(.black, for: .normal)
            button.tintColor = .black
            button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        }
    }
    
    
    @objc func buttonPressed(_ sender: UIButton) {
        let buttons: [UIButton] = [filterByPriceButton, filterByLettersButton]
        buttons.forEach { button in
            if button == sender {
                if isPriceFiltered || isLettersFiltered{
                    styleButtonAsActive(button)
                }
                else{
                    styleButtonAsInactive(button)
                }
            } else {
                styleButtonAsInactive(button)
            }
        }
    }
        
    func setupSearchBar() {
        txtSearchBar.rx.text.orEmpty
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] query in
                self?.filterProducts(searchText: query)
            })
            .disposed(by: disposeBag)
    }
        
    func filterProducts(searchText: String) {
        let lowercaseSearchText = searchText.lowercased()
        
        if searchText.isEmpty {
            products = productList
        } else {
            products = productList.filter { product in
                guard let title = product.title else { return false }
                let parts = title.components(separatedBy: " | ")
                
                if let lastPart = parts.last {
                    return lastPart.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().contains(lowercaseSearchText)
                } else {
                    return false
                }
            }
        }
        searchCollectionView.reloadData()
    }
    
    @IBAction func navigateBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func filterByPrice(_ sender: Any) {
        isPriceFiltered.toggle()
        if isPriceFiltered{
            products = products.sorted(by:  {Float($0.variants?[0].price ?? "") ?? 0 < Float($1.variants?[0].price ?? "") ?? 0})
        }else{
            products = productList
        }
        searchCollectionView.reloadData()
    }
    
    @IBAction func filterByLetters(_ sender: Any) {
        isLettersFiltered.toggle()
        if isLettersFiltered{
            products = products.sorted { Utilities.splitName(text: $0.title ?? "", delimiter: " | ") < Utilities.splitName(text: $1.title ?? "", delimiter: " | ") }
        }else{
            products = productList
        }
        searchCollectionView.reloadData()
    }
    
    func styleButtonAsActive(_ button: UIButton) {
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .white
        button.layer.borderColor = UIColor.black.cgColor
    }
        
    func styleButtonAsInactive(_ button: UIButton) {
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.tintColor = .black
        button.layer.borderColor = UIColor.black.cgColor
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SearchViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return products.count
        }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CategoryCollectionViewCell
        let product = products[indexPath.item]

        let title = Utilities.splitName(text: product.title ?? "No Title", delimiter: " | ")
        print("Title: \(title)")
        cell.categoryTitle.text = title

        let convertedPrice = convertPrice(price: product.variants?[0].price ?? "2", rate: self.rate ?? 1.0)
        cell.categoryType.text = "\(String(format: "%.2f", convertedPrice)) \(userCurrency ?? "USD")"
                

        if let imageUrlString = product.image?.src, let imageUrl = URL(string: imageUrlString) {
            cell.categoryImage.kf.setImage(with: imageUrl)
        } else {
            cell.categoryImage.image = nil
        }
        
        cell.categoryPrice.isHidden = true

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedProduct = products[indexPath.item]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let productDetailVC = storyboard.instantiateViewController(withIdentifier: "ProductDetailViewController") as? ProductDetailViewController {
            productDetailVC.productId = selectedProduct.id
            self.navigationController?.pushViewController(productDetailVC, animated: true)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16
        let collectionViewSize = collectionView.frame.size.width - padding * 3
        
        let width = collectionViewSize / 2
        let height = width + 50
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}

extension SearchViewController: ConnectivityProtocol, NetworkStatusProtocol{
    
    func networkStatusDidChange(connected: Bool) {
        isConnected = connected
        print("networkStatusDidChange called \(isConnected)")
        checkForConnection()
    }
    
    private func checkForConnection(){
        guard let isConnected = isConnected else {
            ConnectivityUtils.showConnectivityAlert(from: self)
            print("is connect nilllllll")
            return
        }
        if isConnected{
            getData()
        }else{
            ConnectivityUtils.showConnectivityAlert(from: self)
            isShowViews()
        }
    }
    
    private func getData(){
        rate = UserDefaultsHelper.shared.getDataDoubleFound(key: UserDefaultsConstants.currencyRate.rawValue)
        userCurrency = UserDefaultsHelper.shared.getCurrencyFromUserDefaults().uppercased()
        searchCollectionView.reloadData()
        
        searchViewModel.getItems()
        
    }
    private func isShowViews(){
        guard let isConnected = isConnected else {return}
        searchCollectionView.isHidden = !isConnected
        noConnectionLabel.isHidden = isConnected
        noConnectionImage.isHidden = isConnected
        
        let  isDarkMode = UserDefaultsHelper.shared.isDarkMode()
        if isDarkMode{
            noConnectionImage.image = UIImage(named: "no-wifi-light")
        }else{
            noConnectionImage.image = UIImage(named: "no-wifi")
        }
    }
}



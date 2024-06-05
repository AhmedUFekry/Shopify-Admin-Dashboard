//
//  ShippingAddressViewController.swift
//  EleganceHub
//
//  Created by AYA on 02/06/2024.
//

import UIKit
import RxSwift
import RxCocoa

class ShippingAddressViewController: UIViewController {
    
    @IBOutlet weak var appBar:CustomAppBarUIView!
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var customerData:User? = User(id: 8222308237587, first_name: "shimaa", last_name: "shimo", email: "", password: "")
    
    let viewModel = AddressesViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        commenInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        viewModel.getAllAddresses(customerID: customerData!.id!)
        setupTableViewBinding()
        loadingObserverSetUp()
    }
    
    private func commenInit(){
        appBar.secoundTrailingIcon.isHidden = true
        appBar.lableTitle.text = "Shipping Address"
        appBar.trailingIcon.setImage(UIImage(named: "add"), for: .normal)
        appBar.backBtn.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        appBar.trailingIcon.addTarget(self, action: #selector(addNewLocation), for: .touchUpInside)

        tableView.register(UINib(nibName: "AddressesTableViewCell", bundle: nil), forCellReuseIdentifier: "AddressesTableViewCell")
        
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
    }
    
    @objc func goBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func addNewLocation(){
        self.navigationController?.present(LocationViewController(), animated: true)
    }

    private func setupTableViewBinding() {

        viewModel.addresses.asObserver().bind(to: tableView.rx.items(cellIdentifier: "AddressesTableViewCell", cellType: AddressesTableViewCell.self)) { index, address, cell in
            cell.setCellData(address:address)
            
        }.disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self)
                .disposed(by: disposeBag)
    }
    private func loadingObserverSetUp(){
        viewModel.isLoading.subscribe{ isloading in
            self.showActivityIndicator(isloading)
        }.disposed(by: disposeBag)
    }
    private func showActivityIndicator(_ show: Bool) {
        if show {
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
        } else {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
        }
    }
    
    private func onErrorObserverSetUp(){
        viewModel.error.subscribe{ err in
            self.showAlertError(err: err.error?.localizedDescription ?? "Error")
        }.disposed(by: disposeBag)
    }
    private func showAlertError(err:String){
        print(err)
    }
}

extension ShippingAddressViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            220
        }
    
}

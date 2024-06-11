//
//  ProductViewController.swift
//  EleganceHub
//
//  Created by raneem on 25/05/2024.
//

import UIKit
import Kingfisher

class ProductViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var productsTableView: UITableView!
        var brandsId: Int?
        var productArray: [Product]?
        var productsViewModel = ProductsViewModel()
        
        override func viewDidLoad() {
            super.viewDidLoad()

            productsTableView.delegate = self
            productsTableView.dataSource = self

            let productsNibCell = UINib(nibName: "ProductsTableViewCell", bundle: nil)
            productsTableView.register(productsNibCell, forCellReuseIdentifier: "productsCell")
            
            productsViewModel.bindResultToViewController = { [weak self] in
                guard let self = self else { return }
                self.productArray = self.productsViewModel.vmResult
                self.renderView()
            }

            productsViewModel.getProductsFromModel(collectionId: brandsId ?? 484442308883)
            
            
        }
        
        func renderView() {
            DispatchQueue.main.async {
                print("Reloading table view data")
                self.productsTableView.reloadData()
            }
        }

    

        // MARK: - Table view data source

        func numberOfSections(in tableView: UITableView) -> Int {
            let count = productArray?.count ?? 0
            print("Number of sections: \(count)")
            return count
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 1
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let productsCell = tableView.dequeueReusableCell(withIdentifier: "productsCell", for: indexPath) as! ProductsTableViewCell
            
            if let product = productArray?[indexPath.section] {
            if let title = product.title {
                
                    let components = title.split(separator: "|")
                    let remainingTitle = components.dropFirst().joined(separator: "|")
                    productsCell.ProductTitle?.text = remainingTitle.isEmpty ? nil : remainingTitle
                }
                productsCell.productCategory?.text = product.productType
                productsCell.productPrice?.text = product.variants?[0].price

                KF.url(URL(string: product.image?.src ?? "https://cdn.shopify.com/s/files/1/0880/0426/4211/collections/a340ce89e0298e52c438ae79591e3284.jpg?v=1716276581"))
                    .set(to: productsCell.productImage)
            }
            return productsCell
        }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
}

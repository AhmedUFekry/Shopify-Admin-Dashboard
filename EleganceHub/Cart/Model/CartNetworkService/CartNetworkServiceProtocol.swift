//
//  CartNetworkServiceProtocol.swift
//  EleganceHub
//
//  Created by AYA on 08/06/2024.
//

import Foundation
import RxSwift

protocol CartNetworkServiceProtocol{
    func postItemToCartNewProduct(customerID:Int,product:Product) -> Observable<PostDraftOrderResponse>
    func getCustomerOrder(orderID:Int, completionHandler: @escaping (Result<DraftOrder, Error>) -> Void)
    func addNewLineItemToDraftOrder(orderID: Int, updatedDraftOrder:DraftOrder) -> Observable<PostDraftOrderResponse>
    func getDraftOrderForUser(orderID:Int) -> Observable<PostDraftOrderResponse>
    func getAllDraftOrders() -> Observable<DraftOrdersResponse>
    func deleteDraftOrder(orderID:Int) -> Observable<Bool>
    
    func checkForCopuns(discountCode:String, completionHandler: @escaping (Result<DiscountCodes, Error>) -> Void)
    func updateDraftOrder(orderID:Int, draftOrder:DraftOrder) ->Observable<PostDraftOrderResponse>
    func getPriceRule(priceRuleID:Int, completionHandler: @escaping (Result<PriceRule, Error>) -> Void)
    
}

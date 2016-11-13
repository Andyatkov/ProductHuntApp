//
//  ProductDetailViewController.swift
//  gglads
//
//  Created by Andrey on 13.11.16.
//  Copyright © 2016 DyatkovAndrey. All rights reserved.
//

import UIKit

class ProductViewController: UIViewController
{
    @IBOutlet weak var productImageView : UIImageView!
    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var upVotesLabel : UILabel!
    @IBOutlet weak var descriptionLabel : UILabel!
    
    var product : Product?
}

//MARK: - LifeCycle
extension  ProductViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if let product = self.product
        {
            if let url = NSURL(string: product.screenshotUrl)
            {
                self.productImageView.sd_setImageWithURL(url)
            }
            self.title = product.name
            self.nameLabel.text = product.name
            self.descriptionLabel.text = product.descriptionProduct
            self.upVotesLabel.text = "\(product.upVotes)"
        }
    }
    
}

extension ProductViewController
{
    
    @IBAction func getItAction(sender: UIButton)
    {
        if let site = self.product?.site {
            if let url = NSURL(string: site) {
                UIApplication.sharedApplication().openURL(url)
            }
            else
            {
                let alert = UIAlertController(title: "Ошибка", message: "Не удалось открыть", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { alertAction in
                    alert.dismissViewControllerAnimated(true, completion: nil)
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        else
        {
            let alert = UIAlertController(title: "Ошибка", message: "Не удалось открыть", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { alertAction in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}

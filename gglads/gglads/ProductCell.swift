//
//  ProductCell.swift
//  gglads
//
//  Created by Andrey on 13.11.16.
//  Copyright © 2016 DyatkovAndrey. All rights reserved.
//

import UIKit

class ProductCell : UITableViewCell
{
    @IBOutlet weak var imageProduct : UIImageView!
    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var descriptionLabel : UILabel!
    @IBOutlet weak var voteLabel : UILabel!
    
    
    override func awakeFromNib() {
        
        //imageProduct.contentMode = .ScaleAspectFill
        //imageProduct.userInteractionEnabled = true
    }
    
    
    
    func configureSelfWithDataModel(product:Product)
    {
        self.imageProduct.sd_setImageWithURL(NSURL(string: product.thumbnail.image_url))
        
        self.nameLabel.text = product.name
        self.descriptionLabel.text = product.descriptionProduct
        self.voteLabel.text = "\(product.upVotes)"
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}


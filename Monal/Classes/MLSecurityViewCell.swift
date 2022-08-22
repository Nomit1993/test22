//
//  MLSecurityViewCell.swift
//  Monal
//
//  Created by mohanchandaluri on 14/06/22.
//  Copyright © 2022 Monal.im. All rights reserved.
//

import UIKit

class MLSecurityViewCell: UITableViewCell {

    @IBOutlet var threatCheck: UILabel!
    @IBOutlet var statusView: UIImageView!
    @IBOutlet var Approve: UISwitch!
    @IBOutlet var Title: UILabel!
    var status:Bool?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if (status == true){
            self.statusView.image = UIImage.init(named: "Warning")
            threatCheck.text = "Threat"
        }else{
            self.statusView.image = UIImage.init(named: "Secured")
            threatCheck.text = "No Threat"
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

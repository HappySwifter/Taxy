import UIKit
import Former
import HCSStarRatingView

final class RaitingCell: UITableViewCell {
    
    @IBOutlet weak var raitingView: HCSStarRatingView!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        infoLabel.textColor = .mainOrangeColor()
        infoLabel.font = .light_Med()
        raitingView.tintColor = .mainOrangeColor()
    }
}
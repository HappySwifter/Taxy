import UIKit
import Former

final class PhoneCell: UITableViewCell, PhoneFormableRow {
    
    @IBOutlet weak var phoneTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func myPhoneTextField() -> UITextField {
        return phoneTextField
    }
 
    func updateWithRowFormer(rowFormer: RowFormer) {}

}
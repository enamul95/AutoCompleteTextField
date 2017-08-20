     import UIKit
     
     class ViewController: UIViewController ,UITextFieldDelegate{
        
        
        @IBOutlet weak var txtAutoComplete: UITextField!
        
        var autoCompletionPossibilities = ["01921687433", "01553377642", "0155776622"]
        var autoCompleteCharacterCount = 0
        var timer = Timer()
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            
            txtAutoComplete.delegate = self
        }
        
        
        
        
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool { //1
            var subString = (textField.text!.capitalized as NSString).replacingCharacters(in: range, with: string)
            subString = formatSubstring(subString: subString)
            
            if subString.characters.count == 0 {
                // 3 when a user clears the textField
                resetValues()
            } else {
                searchAutocompleteEntriesWIthSubstring(substring: subString)
            }
            return true
        }
        
        func formatSubstring(subString: String) -> String {
            let formatted = String(subString.characters.dropLast(autoCompleteCharacterCount)).lowercased().capitalized //5
            return formatted
        }
        
        func resetValues() {
            autoCompleteCharacterCount = 0
            txtAutoComplete.text = ""
        }
        
        func searchAutocompleteEntriesWIthSubstring(substring: String) {
            let userQuery = substring
            let suggestions = getAutocompleteSuggestions(userText: substring)
            
            if suggestions.count > 0 {
                timer = .scheduledTimer(withTimeInterval: 0.01, repeats: false, block: { (timer) in //2
                    let autocompleteResult =   self.formatAutocompleteResult(substring: substring, possibleMatches: suggestions)
                    self.putColourFormattedTextInTextField(autocompleteResult: autocompleteResult, userQuery : userQuery)
                    self.moveCaretToEndOfUserQueryPosition(userQuery: userQuery)
                })
                
            } else {
                timer = .scheduledTimer(withTimeInterval: 0.01, repeats: false, block: { (timer) in //7
                    self.txtAutoComplete.text = substring
                })
                autoCompleteCharacterCount = 0
            }
            
        }
        
        func getAutocompleteSuggestions(userText: String) -> [String]{
            var possibleMatches: [String] = []
            for item in autoCompletionPossibilities { //2
                let myString:NSString! = item as NSString
                let substringRange :NSRange! = myString.range(of: userText)
                
                if (substringRange.location == 0)
                {
                    possibleMatches.append(item)
                }
            }
            return possibleMatches
        }
        
        func putColourFormattedTextInTextField(autocompleteResult: String, userQuery : String) {
            let colouredString: NSMutableAttributedString = NSMutableAttributedString(string: userQuery + autocompleteResult)
            colouredString.addAttribute(NSForegroundColorAttributeName, value: UIColor.green, range: NSRange(location: userQuery.characters.count,length:autocompleteResult.characters.count))
            self.txtAutoComplete.attributedText = colouredString
        }
        
        func moveCaretToEndOfUserQueryPosition(userQuery : String) {
            if let newPosition = self.txtAutoComplete.position(from: self.txtAutoComplete.beginningOfDocument, offset: userQuery.characters.count) {
                self.txtAutoComplete.selectedTextRange = self.txtAutoComplete.textRange(from: newPosition, to: newPosition)
            }
            let selectedRange: UITextRange? = txtAutoComplete.selectedTextRange
            txtAutoComplete.offset(from: txtAutoComplete.beginningOfDocument, to: (selectedRange?.start)!)
        }
        
        func formatAutocompleteResult(substring: String, possibleMatches: [String]) -> String {
            var autoCompleteResult = possibleMatches[0]
            autoCompleteResult.removeSubrange(autoCompleteResult.startIndex..<autoCompleteResult.index(autoCompleteResult.startIndex, offsetBy: substring.characters.count))
            autoCompleteCharacterCount = autoCompleteResult.characters.count
            return autoCompleteResult
        }
     }
     

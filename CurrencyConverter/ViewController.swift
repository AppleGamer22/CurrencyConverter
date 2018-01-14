//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by Omri Bornstein on 14/1/18.
//  Copyright © 2018 AppleGamer22 Software Development. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //fetchData()
        createPicker()
        tableView.delegate = self
        tableView.dataSource = self
        currencyPicker.delegate = self
        currencyPicker.dataSource = self
    }

    struct Currency: Decodable {
        let base: String
        let date: String
        let rates: [String: Double]
    }

    func fetchData(type: String) {
        let url = URL(string: "https:api.fixer.io/latest?base=\(type)")
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error == nil {
                do {
                    self.currency = try JSONDecoder().decode(Currency.self, from: data!)
                } catch {
                    print("Parse error...")
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                print(error?.localizedDescription ?? "nil")
            }
            }.resume()
    }

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var txtCurrencyType: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var currency: Currency?
    var baseRate = 1.0
    let currencyPicker = UIPickerView()
    let currencies = ["Select Currency" ,"AUD", "BGN", "BRL", "CAD", "CHF", "CNY", "CZK", "DKK", "EUR", "GBP", "HKD", "HRK", "HUF", "IDR", "ILS", "INR", "JPY", "KRW", "MXN", "MYR", "NOK", "NZD", "PHP", "PLN", "RON", "RUB", "SEK", "SGD", "THB", "TRY", "USD", "ZAR"]

    @IBAction func btnConvert(_ sender: Any) {
        guard let currencyType = txtCurrencyType.text else { print("Form is not valid."); return }
        fetchData(type: currencyType)
        if let input = textField.text {
            if let value = Double(input) {
                baseRate = value
                
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currencyFetched = currency {
            return currencyFetched.rates.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        if let currencyFetched = currency {
            cell.textLabel?.text = Array(currencyFetched.rates.keys)[indexPath.row]
            let selectedRate = baseRate * Double(Array(currencyFetched.rates.values)[indexPath.row])
            cell.detailTextLabel?.text = "\(selectedRate)"
            return cell
        }
        return UITableViewCell()
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1}
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return currencies.count }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { return currencies[row] }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row != 0 {
            txtCurrencyType.text = currencies[row]
        }
    }

    func createPicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(endEditing))
        toolbar.setItems([done], animated: false)
        txtCurrencyType.inputAccessoryView = toolbar; textField.inputAccessoryView = toolbar
        txtCurrencyType.inputView = currencyPicker
    }

    @objc func endEditing() {
        self.view.endEditing(true)
    }
}

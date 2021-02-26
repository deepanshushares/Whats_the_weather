//
//  ViewController.swift
//  weatherApp
//
//  Created by Deepanshu Jain on 21/12/20.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var mainLabel: UILabel!
    
    @IBOutlet weak var tempTitle: UILabel!
    @IBOutlet weak var pressureTitle: UILabel!
    @IBOutlet weak var humidityTitle: UIStackView!
    @IBOutlet weak var speedTitle: UIStackView!
    
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var localtionLabel: UILabel!
    
    // MARK: - Properties
    var result: Weather? = nil
    var isShowingMainDesc: Bool = true

    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.hideKeyboardWhenTappedAround()
    }
    
    // MARK: - Methods
    
    func setupUI() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapFunction))
        mainLabel.isUserInteractionEnabled = true
        mainLabel.addGestureRecognizer(tap)
        
        setInitialUI()
        localtionLabel.text = "Welcome to weather app"
    }
    
    func setInitialUI() {
        cityTextField.text = nil
        iconImageView.image = nil
        mainLabel.text = nil
        tempLabel.text = nil
        pressureLabel.text = nil
        humidityLabel.text = nil
        speedLabel.text = nil
        setTitleLabelHiddenStatus(to: true)
    }
    
    func setTitleLabelHiddenStatus(to hidden: Bool) {
        tempTitle.isHidden = hidden
        pressureTitle.isHidden = hidden
        humidityTitle.isHidden = hidden
        speedTitle.isHidden = hidden
    }
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        mainLabel.text = isShowingMainDesc ? result?.weather[0].main : result?.weather[0].description
        isShowingMainDesc = !isShowingMainDesc
    }
    
    func setErrorMessage(to text: String) {
        DispatchQueue.main.async {
            self.view.setNeedsLayout()
            self.setInitialUI()
            self.localtionLabel.text = text
        }
    }
 
    func getData(city: String) {
        let key = "7d7c50161abb3fea79d0db42d5545a94"
        let urlString = "http://api.openweathermap.org/data/2.5/weather?q=\(city)&units=metric&appid=\(key)".replacingOccurrences(of: " ", with: "")
        
        let task = URLSession.shared.dataTask(with: URL(string: urlString)!) { (data, response, error) in
            guard let data = data, error == nil else {
                print("ERROR: \(error?.localizedDescription ?? "Some error occured")")
                self.setErrorMessage(to: error?.localizedDescription ?? "Something went wrong")
                return
            }
            
            do {
                self.result = try JSONDecoder().decode(Weather.self, from: data)
            } catch {
                print("ERROR: \(error.localizedDescription)")
                self.setErrorMessage(to: error.localizedDescription)
                return
            }
            
            guard let json = self.result else { return }
            
            print(json)
            
            let main = json.weather[0].main
            let desc = json.weather[0].description
            let icon = json.weather[0].icon
            let temp = json.main.temp
            let pressure = json.main.pressure
            let humidity = json.main.humidity
            let speed = json.wind.speed
            let country = json.sys.country
            let city = json.name

            let viewModel: WeatherModel = WeatherModel(main: main,
                                                       desc: desc,
                                                       icon: icon,
                                                       temp: temp,
                                                       pressure: pressure,
                                                       humidity: humidity,
                                                       speed: speed,
                                                       country: country,
                                                       city: city)
            DispatchQueue.main.async {
                self.updateUI(model: viewModel)
            }
        }
        
        task.resume()
    }
    
    func updateUI(model: WeatherModel) {
        setTitleLabelHiddenStatus(to: false)
        mainLabel.text = model.main
        tempLabel.text = String(model.temp)
        pressureLabel.text = String(model.pressure)
        humidityLabel.text = String(model.humidity)
        speedLabel.text = String(model.speed)
        localtionLabel.text = model.country + " | " + model.city
        
        URLSession.shared.dataTask(with: URL(string: "http://openweathermap.org/img/w/\(model.icon).png")!) { iconData, _ , _ in
                               if let data = iconData {
                                  DispatchQueue.main.async {
                                         self.iconImageView.image = UIImage(data: data)
                                  }
                               }
                            }.resume()
    }
    
    // MARK: - IBActions
    @IBAction func searchTapped(_ sender: UIButton) {
        guard let city = cityTextField.text else {
            return
        }
        getData(city: city)
        cityTextField.text = nil
    }
}

// MARK: - Codable
struct Weather: Codable {
    let weather: [WeatherDesc]
    let main: MainDesc
    let wind: WindDesc
    let sys: SysDesc
    let name: String
}

struct WeatherDesc: Codable {
    let main: String
    let description: String
    let icon: String
}

struct MainDesc: Codable {
    let temp: Float
    let pressure: Int
    let humidity: Int
}

struct WindDesc: Codable {
    let speed: Float
}

struct SysDesc: Codable {
    let country: String
}

struct WeatherModel {
    let main: String
    let desc: String
    let icon: String
    let temp: Float
    let pressure: Int
    let humidity: Int
    let speed: Float
    let country: String
    let city: String
}

// MARK: - Keyboard Gestures
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

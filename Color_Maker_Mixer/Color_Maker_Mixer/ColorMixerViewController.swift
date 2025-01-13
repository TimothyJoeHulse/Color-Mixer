import UIKit

class ColorMixerViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var colorDisplay: UIView!
    @IBOutlet weak var redSwitch: UISwitch!
    @IBOutlet weak var greenSwitch: UISwitch!
    @IBOutlet weak var blueSwitch: UISwitch!
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    @IBOutlet weak var redText: UITextField!
    @IBOutlet weak var greenText: UITextField!
    @IBOutlet weak var blueText: UITextField!
    @IBOutlet weak var reset: UIButton!
    
    private var redValue: Float = 1.0
    private var greenValue: Float = 1.0
    private var blueValue: Float = 1.0
    private var portraitFrames: [String: CGRect] = [:]
    private var savedPortraitFrames: [String: CGRect] = [:] // Dictionary to store iPhone portrait frames
    private var isInitialPortraitLayoutSaved = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadValues()
        configureUI()
        
        DispatchQueue.main.async {
            let isLandscape = self.view.frame.width > self.view.frame.height
            let isPad = UIDevice.current.userInterfaceIdiom == .pad
            
            if isLandscape {
                self.layoutForLandscape(isPad: isPad)
            } else {
                self.layoutForPortrait(isPad: isPad)
            }
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleScreenTap))
        self.view.addGestureRecognizer(tapGesture)
    }


    func applyInitialLayout() {
        let isLandscape = view.frame.width > view.frame.height
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        
        if isLandscape {
            layoutForLandscape(isPad: isPad)
        } else {
            layoutForPortrait(isPad: isPad)
        }
    }
    
    @objc func handleScreenTap() {
        // Attempt to parse the text field values and update persistence
        if let redTextValue = Float(redText.text ?? ""), redTextValue >= 0, redTextValue <= 1 {
            redValue = redTextValue
            redSlider.value = redTextValue
        }

        if let greenTextValue = Float(greenText.text ?? ""), greenTextValue >= 0, greenTextValue <= 1 {
            greenValue = greenTextValue
            greenSlider.value = greenTextValue
        }

        if let blueTextValue = Float(blueText.text ?? ""), blueTextValue >= 0, blueTextValue <= 1 {
            blueValue = blueTextValue
            blueSlider.value = blueTextValue
        }

        // Save the updated values to persistence
        saveValues()

        // Refresh the color display to reflect new values
        updateColorDisplay()

        // Debugging log
        print("Screen tapped: Persistence replaced with new values from text fields.")
    }


    func saveValues() {
        let defaults = UserDefaults.standard

        // Save the updated slider values
        defaults.set(redValue, forKey: "redValue")
        defaults.set(greenValue, forKey: "greenValue")
        defaults.set(blueValue, forKey: "blueValue")

        // Save the switch states
        defaults.set(redSwitch.isOn, forKey: "redSwitch")
        defaults.set(greenSwitch.isOn, forKey: "greenSwitch")
        defaults.set(blueSwitch.isOn, forKey: "blueSwitch")

        // Debug log
        print("Saved Values - Red: \(redValue), Green: \(greenValue), Blue: \(blueValue)")
    }


    
    func setupUI() {
        colorDisplay.layer.borderColor = UIColor.black.cgColor
        colorDisplay.layer.borderWidth = 2.0
        colorDisplay.layer.cornerRadius = 8.0
        colorDisplay.clipsToBounds = true
    }
    
    func configureUI() {
        redSlider.value = redValue
        greenSlider.value = greenValue
        blueSlider.value = blueValue
        
        redText.text = String(format: "%.2f", redValue)
        greenText.text = String(format: "%.2f", greenValue)
        blueText.text = String(format: "%.2f", blueValue)
        
        redText.delegate = self
        greenText.delegate = self
        blueText.delegate = self
        
        updateColorDisplay()
    }
    
    func updateColorDisplay() {
        let red = redSwitch.isOn ? redValue : 0
        let green = greenSwitch.isOn ? greenValue : 0
        let blue = blueSwitch.isOn ? blueValue : 0
        
        colorDisplay.backgroundColor = UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1.0)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        let allowedCharacters = "0123456789."
        let filtered = newText.filter { allowedCharacters.contains($0) }
        return newText == filtered && newText.components(separatedBy: ".").count <= 2
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text, let value = Float(text), value >= 0.0, value <= 1.0 else {
            resetInvalidInput(for: textField)
            return
        }
        let formattedValue = String(format: "%.2f", value)
        textField.text = formattedValue
        updateValue(for: textField, with: value)
        saveValues()
        updateColorDisplay()
    }
    
    func updateValue(for textField: UITextField, with value: Float) {
        if textField == redText {
            redValue = value
            redSlider.value = value
        } else if textField == greenText {
            greenValue = value
            greenSlider.value = value
        } else if textField == blueText {
            blueValue = value
            blueSlider.value = value
        }
    }
    
    func resetInvalidInput(for textField: UITextField) {
        if textField == redText {
            textField.text = String(format: "%.2f", redValue)
        } else if textField == greenText {
            textField.text = String(format: "%.2f", greenValue)
        } else if textField == blueText {
            textField.text = String(format: "%.2f", blueValue)
        }
    }
    
    @IBAction func redSwitchChanged(_ sender: UISwitch) {
        redSlider.isEnabled = sender.isOn
        redText.isEnabled = sender.isOn
        saveValues()
        updateColorDisplay()
    }

    @IBAction func greenSwitchChanged(_ sender: UISwitch) {
        greenSlider.isEnabled = sender.isOn
        greenText.isEnabled = sender.isOn
        saveValues()
        updateColorDisplay()
    }

    @IBAction func blueSwitchChanged(_ sender: UISwitch) {
        blueSlider.isEnabled = sender.isOn
        blueText.isEnabled = sender.isOn
        saveValues()
        updateColorDisplay()
    }
    
    @IBAction func redSliderChanged(_ sender: UISlider) {
        redValue = sender.value
        redText.text = String(format: "%.2f", redValue)
        saveValues()
        updateColorDisplay()
    }

    @IBAction func greenSliderChanged(_ sender: UISlider) {
        greenValue = sender.value
        greenText.text = String(format: "%.2f", greenValue)
        saveValues()
        updateColorDisplay()
    }

    @IBAction func blueSliderChanged(_ sender: UISlider) {
        blueValue = sender.value
        blueText.text = String(format: "%.2f", blueValue)
        saveValues()
        updateColorDisplay()
    }
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        // Turn all switches ON
        redSwitch.setOn(true, animated: true)
        greenSwitch.setOn(true, animated: true)
        blueSwitch.setOn(true, animated: true)

        // Enable sliders and text fields
        redSlider.isEnabled = true
        greenSlider.isEnabled = true
        blueSlider.isEnabled = true

        redText.isEnabled = true
        greenText.isEnabled = true
        blueText.isEnabled = true

        // Reset slider values
        redSlider.value = 1.0
        greenSlider.value = 1.0
        blueSlider.value = 1.0

        // Reset text field values
        redText.text = "1.00"
        greenText.text = "1.00"
        blueText.text = "1.00"

        // Update variables
        redValue = 1.0
        greenValue = 1.0
        blueValue = 1.0

        // Update color display and save
        updateColorDisplay()
        saveValues()
    }

    
    
    func loadValues() {
        let defaults = UserDefaults.standard

        // Load slider values or default to 1.0
        redValue = defaults.object(forKey: "redValue") as? Float ?? 1.0
        greenValue = defaults.object(forKey: "greenValue") as? Float ?? 1.0
        blueValue = defaults.object(forKey: "blueValue") as? Float ?? 1.0

        // Sync sliders with loaded values
        redSlider.value = redValue
        greenSlider.value = greenValue
        blueSlider.value = blueValue

        // Sync switches with loaded states
        redSwitch.isOn = defaults.bool(forKey: "redSwitch")
        greenSwitch.isOn = defaults.bool(forKey: "greenSwitch")
        blueSwitch.isOn = defaults.bool(forKey: "blueSwitch")

        // Enable or disable sliders and text fields based on switches
        redSlider.isEnabled = redSwitch.isOn
        redText.isEnabled = redSwitch.isOn
        greenSlider.isEnabled = greenSwitch.isOn
        greenText.isEnabled = greenSwitch.isOn
        blueSlider.isEnabled = blueSwitch.isOn
        blueText.isEnabled = blueSwitch.isOn

        // Configure the UI
        configureUI()
    }

    func savePortraitFrames() {
        // Save frames only if in portrait mode and not already saved
        if portraitFrames.isEmpty && view.frame.width < view.frame.height {
            portraitFrames["colorDisplay"] = colorDisplay.frame
            portraitFrames["redSwitch"] = redSwitch.frame
            portraitFrames["redSlider"] = redSlider.frame
            portraitFrames["redText"] = redText.frame
            portraitFrames["greenSwitch"] = greenSwitch.frame
            portraitFrames["greenSlider"] = greenSlider.frame
            portraitFrames["greenText"] = greenText.frame
            portraitFrames["blueSwitch"] = blueSwitch.frame
            portraitFrames["blueSlider"] = blueSlider.frame
            portraitFrames["blueText"] = blueText.frame
            portraitFrames["reset"] = reset.frame
            
            print("Portrait frames saved:", portraitFrames)
        }
    }

    func saveInitialPortraitFrames() {
        savedPortraitFrames["colorDisplay"] = colorDisplay.frame
        savedPortraitFrames["redSwitch"] = redSwitch.frame
        savedPortraitFrames["redSlider"] = redSlider.frame
        savedPortraitFrames["redText"] = redText.frame
        savedPortraitFrames["greenSwitch"] = greenSwitch.frame
        savedPortraitFrames["greenSlider"] = greenSlider.frame
        savedPortraitFrames["greenText"] = greenText.frame
        savedPortraitFrames["blueSwitch"] = blueSwitch.frame
        savedPortraitFrames["blueSlider"] = blueSlider.frame
        savedPortraitFrames["blueText"] = blueText.frame
        savedPortraitFrames["reset"] = reset.frame

        print("Saved initial portrait frames for iPhone.")
    }

    func layoutForPortrait(isPad: Bool) {
        let safeAreaInsets = view.safeAreaInsets
        let screenWidth = view.frame.width
        let screenHeight = view.frame.height - safeAreaInsets.top - safeAreaInsets.bottom

        if !isPad {
            // Restore saved frames if available
            if isInitialPortraitLayoutSaved {
                restoreSavedPortraitFrames()
                print("Restored portrait layout.")
                return
            }

            // First-time setup for portrait layout
            let baseScreenWidth: CGFloat = 375 // Reference screen width for scaling
            let baseScreenHeight: CGFloat = 812 // Reference screen height for scaling

            let widthScale = screenWidth / baseScreenWidth
            let heightScale = screenHeight / baseScreenHeight

            let verticalSpacing: CGFloat = 25 * heightScale
            let controlHeight: CGFloat = 31 * heightScale
            let sliderHeight: CGFloat = 25 * heightScale
            let sliderWidth: CGFloat = screenWidth * 0.75
            let sliderX: CGFloat = (screenWidth - sliderWidth) / 2

            let colorDisplayHeight: CGFloat = screenHeight * 0.35
            colorDisplay.frame = CGRect(x: 0, y: safeAreaInsets.top, width: screenWidth, height: colorDisplayHeight)

            let redSwitchY = colorDisplay.frame.maxY + verticalSpacing
            redSwitch.frame = CGRect(x: 20 * widthScale, y: redSwitchY, width: 51 * widthScale, height: controlHeight)
            redText.frame = CGRect(x: screenWidth - 80 * widthScale, y: redSwitchY, width: 60 * widthScale, height: controlHeight)
            redSlider.frame = CGRect(x: sliderX, y: redSwitch.frame.maxY + verticalSpacing * 0.5, width: sliderWidth, height: sliderHeight)

            let greenSwitchY = redSlider.frame.maxY + verticalSpacing
            greenSwitch.frame = CGRect(x: 20 * widthScale, y: greenSwitchY, width: 51 * widthScale, height: controlHeight)
            greenText.frame = CGRect(x: screenWidth - 80 * widthScale, y: greenSwitchY, width: 60 * widthScale, height: controlHeight)
            greenSlider.frame = CGRect(x: sliderX, y: greenSwitch.frame.maxY + verticalSpacing * 0.5, width: sliderWidth, height: sliderHeight)

            let blueSwitchY = greenSlider.frame.maxY + verticalSpacing
            blueSwitch.frame = CGRect(x: 20 * widthScale, y: blueSwitchY, width: 51 * widthScale, height: controlHeight)
            blueText.frame = CGRect(x: screenWidth - 80 * widthScale, y: blueSwitchY, width: 60 * widthScale, height: controlHeight)
            blueSlider.frame = CGRect(x: sliderX, y: blueSwitch.frame.maxY + verticalSpacing * 0.5, width: sliderWidth, height: sliderHeight)

            let resetWidth: CGFloat = 150 * widthScale
            let resetHeight: CGFloat = 50 * heightScale
            reset.frame = CGRect(x: (screenWidth - resetWidth) / 2, y: blueSlider.frame.maxY + verticalSpacing, width: resetWidth, height: resetHeight)

            // Save initial layout frames
            saveInitialPortraitFrames()
            isInitialPortraitLayoutSaved = true
        } else {
            // iPad Layout Logic (No changes)
            let colorDisplayHeight: CGFloat = screenHeight * 0.5
            colorDisplay.frame = CGRect(x: 0, y: 0, width: screenWidth, height: colorDisplayHeight)

            let controlHeight: CGFloat = screenHeight * 0.06
            let textHeight: CGFloat = controlHeight * 0.8
            let textWidth: CGFloat = screenWidth * 0.08
            let controlSpacing: CGFloat = screenHeight * 0.015
            let sliderWidth: CGFloat = screenWidth * 0.75
            let sliderX: CGFloat = (screenWidth - sliderWidth) / 2

            var currentY: CGFloat = colorDisplayHeight + controlSpacing

            redSwitch.frame = CGRect(x: sliderX - 80, y: currentY, width: 70, height: controlHeight)
            redText.frame = CGRect(x: sliderX + sliderWidth + 10, y: currentY, width: textWidth, height: textHeight)
            currentY += controlHeight
            redSlider.frame = CGRect(x: sliderX, y: currentY, width: sliderWidth, height: controlHeight)

            currentY += controlHeight + controlSpacing

            greenSwitch.frame = CGRect(x: sliderX - 80, y: currentY, width: 70, height: controlHeight)
            greenText.frame = CGRect(x: sliderX + sliderWidth + 10, y: currentY, width: textWidth, height: textHeight)
            currentY += controlHeight
            greenSlider.frame = CGRect(x: sliderX, y: currentY, width: sliderWidth, height: controlHeight)

            currentY += controlHeight + controlSpacing

            blueSwitch.frame = CGRect(x: sliderX - 80, y: currentY, width: 70, height: controlHeight)
            blueText.frame = CGRect(x: sliderX + sliderWidth + 10, y: currentY, width: textWidth, height: textHeight)
            currentY += controlHeight
            blueSlider.frame = CGRect(x: sliderX, y: currentY, width: sliderWidth, height: controlHeight)

            let resetWidth: CGFloat = screenWidth * 0.4
            let resetHeight: CGFloat = 50
            let resetY: CGFloat = blueSlider.frame.maxY + controlSpacing * 0.5
            reset.frame = CGRect(x: (screenWidth - resetWidth) / 2, y: resetY, width: resetWidth, height: resetHeight)
        }

        print("Portrait layout applied.")
    }

    
    // Restore the saved portrait frames
    func restoreSavedPortraitFrames() {
        colorDisplay.frame = savedPortraitFrames["colorDisplay"] ?? .zero
        redSwitch.frame = savedPortraitFrames["redSwitch"] ?? .zero
        redSlider.frame = savedPortraitFrames["redSlider"] ?? .zero
        redText.frame = savedPortraitFrames["redText"] ?? .zero
        greenSwitch.frame = savedPortraitFrames["greenSwitch"] ?? .zero
        greenSlider.frame = savedPortraitFrames["greenSlider"] ?? .zero
        greenText.frame = savedPortraitFrames["greenText"] ?? .zero
        blueSwitch.frame = savedPortraitFrames["blueSwitch"] ?? .zero
        blueSlider.frame = savedPortraitFrames["blueSlider"] ?? .zero
        blueText.frame = savedPortraitFrames["blueText"] ?? .zero
        reset.frame = savedPortraitFrames["reset"] ?? .zero

        print("Restored saved portrait layout for iPhone.")
    }
    
    
    func layoutForLandscape(isPad: Bool) {
        let screenWidth = view.frame.width
        let screenHeight = view.frame.height

        if isPad {
            // iPad Landscape Layout (No changes)
            let colorDisplayWidth: CGFloat = screenWidth / 3
            colorDisplay.frame = CGRect(x: 0, y: 0, width: colorDisplayWidth, height: screenHeight)

            let controlsStartX: CGFloat = colorDisplayWidth + 20
            let controlsWidth: CGFloat = screenWidth - colorDisplayWidth - 40
            let controlHeight: CGFloat = screenHeight * 0.06
            let controlSpacing: CGFloat = screenHeight * 0.015
            var currentY: CGFloat = controlSpacing

            redSwitch.frame = CGRect(x: controlsStartX, y: currentY, width: 70, height: controlHeight)
            redText.frame = CGRect(x: controlsStartX + controlsWidth - 70, y: currentY, width: 60, height: controlHeight)
            currentY += controlHeight + controlSpacing
            redSlider.frame = CGRect(x: controlsStartX, y: currentY, width: controlsWidth - 10, height: controlHeight)

            currentY += controlHeight + controlSpacing

            greenSwitch.frame = CGRect(x: controlsStartX, y: currentY, width: 70, height: controlHeight)
            greenText.frame = CGRect(x: controlsStartX + controlsWidth - 70, y: currentY, width: 60, height: controlHeight)
            currentY += controlHeight + controlSpacing
            greenSlider.frame = CGRect(x: controlsStartX, y: currentY, width: controlsWidth - 10, height: controlHeight)

            currentY += controlHeight + controlSpacing

            blueSwitch.frame = CGRect(x: controlsStartX, y: currentY, width: 70, height: controlHeight)
            blueText.frame = CGRect(x: controlsStartX + controlsWidth - 70, y: currentY, width: 60, height: controlHeight)
            currentY += controlHeight + controlSpacing
            blueSlider.frame = CGRect(x: controlsStartX, y: currentY, width: controlsWidth - 10, height: controlHeight)

            let resetWidth: CGFloat = controlsWidth * 0.6
            let resetHeight: CGFloat = 50
            let resetX: CGFloat = controlsStartX + (controlsWidth - resetWidth) / 2
            reset.frame = CGRect(x: resetX, y: screenHeight - resetHeight - 20, width: resetWidth, height: resetHeight)
        } else {
            // iPhone Landscape Layout with Reduced Spacing
            let colorDisplayWidth: CGFloat = screenWidth / 3
            colorDisplay.frame = CGRect(x: 0, y: 0, width: colorDisplayWidth, height: screenHeight)

            let controlsStartX: CGFloat = colorDisplayWidth + 20
            let controlsWidth: CGFloat = screenWidth - colorDisplayWidth - 40
            let controlHeight: CGFloat = 40
            let controlSpacing: CGFloat = 10 // Reduced spacing
            var currentY: CGFloat = 20

            // Red Controls
            redSwitch.frame = CGRect(x: controlsStartX, y: currentY, width: 70, height: controlHeight)
            redText.frame = CGRect(x: controlsStartX + controlsWidth - 70, y: currentY, width: 60, height: controlHeight)
            currentY += controlHeight + 5 // Slight spacing adjustment
            redSlider.frame = CGRect(x: controlsStartX, y: currentY, width: controlsWidth - 10, height: controlHeight)

            currentY += controlHeight + controlSpacing

            // Green Controls
            greenSwitch.frame = CGRect(x: controlsStartX, y: currentY, width: 70, height: controlHeight)
            greenText.frame = CGRect(x: controlsStartX + controlsWidth - 70, y: currentY, width: 60, height: controlHeight)
            currentY += controlHeight + 5 // Slight spacing adjustment
            greenSlider.frame = CGRect(x: controlsStartX, y: currentY, width: controlsWidth - 10, height: controlHeight)

            currentY += controlHeight + controlSpacing

            // Blue Controls
            blueSwitch.frame = CGRect(x: controlsStartX, y: currentY, width: 70, height: controlHeight)
            blueText.frame = CGRect(x: controlsStartX + controlsWidth - 70, y: currentY, width: 60, height: controlHeight)
            currentY += controlHeight + 5 // Slight spacing adjustment
            blueSlider.frame = CGRect(x: controlsStartX, y: currentY, width: controlsWidth - 10, height: controlHeight)

            let resetWidth: CGFloat = controlsWidth * 0.6
            let resetHeight: CGFloat = 50
            let resetX: CGFloat = controlsStartX + (controlsWidth - resetWidth) / 2
            reset.frame = CGRect(x: resetX, y: screenHeight - resetHeight - 20, width: resetWidth, height: resetHeight)
        }

        print("Landscape layout applied.")
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            let isLandscape = size.width > size.height
            let isPad = UIDevice.current.userInterfaceIdiom == .pad
            
            if isLandscape {
                self.layoutForLandscape(isPad: isPad)
            } else {
                self.layoutForPortrait(isPad: isPad)
            }
        })
    }

}


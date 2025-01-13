# Color-Mixer

Overview

The ColorMixerViewController is a Swift-based iOS application that allows users to dynamically mix colors by adjusting red, green, and blue (RGB) values using sliders, switches, and text fields. The resulting color is displayed in a color preview area. The app includes features for user input validation, persistence of user settings, and adaptive layout for both portrait and landscape orientations on iPhone and iPad devices.

Features

1. Color Mixing Controls

Sliders: Each color channel (Red, Green, Blue) has a dedicated slider that can be adjusted between 0.0 and 1.0 to control the intensity of the respective color.

Switches: Toggles for enabling or disabling each color channel.

Text Fields: Direct numeric input for each color channel, with input validation.

2. Color Display

A preview area (colorDisplay) dynamically updates to reflect the current color based on the RGB values set by the sliders and switches.

3. Persistence

The app saves the current state of the sliders and switches using UserDefaults so that users can resume where they left off upon restarting the app.

4. Reset Functionality

A reset button is provided to restore all color channels to their default values (1.0) and enable all controls.

5. Adaptive Layout

The app supports both portrait and landscape orientations, with different layouts for iPhone and iPad devices.

The layout automatically adjusts during orientation changes and ensures consistent spacing and control positions.

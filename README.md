# Muta Manager

Muta Manager is a Flutter application designed for the management of the "mute" of the Ceri of Gubbio. It allows users to create, organize, and archive the compositions of the "mute", track their locations, and manage the participants ("ceraioli").

## Features

*   **Cero Management:** Select and manage mute for each of the three Ceri: Sant'Ubaldo, San Giorgio, and Sant'Antonio.
*   **Muta Creation:** Easily create new mute, specifying the year, name, location, and the participants for each position on the "barella".
*   **Participant Management:** Maintain a list of all "ceraioli", including their name, surname, and nickname.
*   **Archive:** Browse and view all the created mute, organized by year and Cero.
*   **Visual Barella Layout:** A graphical representation of the "barella" shows the composition of each muta in a clear and intuitive way.
*   **Sharing:** Share the details of a muta as a PDF or an image file.
*   **Map View:** Visualize the locations of the mute on a map.
*   **Dark Mode:** The application supports both light and dark themes.

## Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

*   Flutter SDK: Make sure you have the Flutter SDK installed. You can find instructions on how to install it [here](https://docs.flutter.dev/get-started/install).

### Installation

1.  Clone the repo
    ```sh
    git clone https://github.com/your_username/muta_manager.git
    ```
2.  Install packages
    ```sh
    flutter pub get
    ```
3.  Run the app
    ```sh
    flutter run
    ```

## Technologies Used

*   **Flutter:** The application is built using the Flutter framework.
*   **Dart:** The programming language used for the application.
*   **Provider:** For state management.
*   **SQFlite:** For local database storage.
*   **PDF:** For generating PDF documents.
*   **Printing:** For sharing and printing documents.
*   **Share Plus:** For sharing files.
*   **Flutter Map:** For the map view.

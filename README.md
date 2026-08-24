# Ostad Product Manager

A responsive Flutter product and inventory management app with a mobile-first interface. The app connects to the Ostad CRUD API and supports browsing, searching, creating, updating, deleting, and viewing detailed product information.

## Features

- Product list with image, product code, quantity, unit price, and total value
- Search by product name or product code
- Pull-to-refresh and manual refresh actions
- Create, edit, and delete product workflows
- Product descriptions shown on the dedicated product details page
- Responsive layouts for Android, web, desktop, and tablet-sized screens
- Loading, empty, retry, validation, and API error states
- Image loading states and fallback icons for unavailable images
- Local description preservation when the remote API omits the custom description field

## Screenshots

### Product UI

![Product UI](Screenshots/Product%20UI.png)

### Product Details

![Product Details](Screenshots/Product%20Details.png)

### Create Product

![Create Product](Screenshots/Create%20Product.png)

### After Creating Product

![After Creating Product](Screenshots/After%20Creating%20Product.png)

### Update Product

![Update Product](Screenshots/Update%20Product.png)

### After Updating

![After Updating](Screenshots/After%20Updating.png)

### Delete Product

![Delete Product](Screenshots/Delete%20Product.png)

### After Deletion

![After Deletion](Screenshots/After%20Deletion.png)

## Project Structure

```text
lib/
├── main.dart
├── models/
│   └── product.dart
├── services/
│   └── api_service.dart
├── screens/
│   ├── product_detail_screen.dart
│   └── product_list_screen.dart
└── widgets/
	├── product_card.dart
	└── product_form_dialog.dart
```

## Getting Started

### Prerequisites

- Flutter SDK 3.x or later
- Dart SDK compatible with the version in `pubspec.yaml`
- Android emulator, physical Android device, Chrome, or Windows desktop target

### Run locally

```bash
flutter pub get
flutter run
```

To run on a specific device:

```bash
flutter devices
flutter run -d <device-id>
```

For the Android emulator used during development:

```bash
flutter run -d emulator-5554
```

## Validation

```bash
flutter analyze
flutter test
```

## API

The app uses the Ostad CRUD API:

```text
https://crud-api-ostad-live.onrender.com/api/v1
```

The API provides the product CRUD operations used by the app. Its current response schema does not consistently return a description field, so the app accepts multiple description key variants and preserves descriptions entered during the current session when the API omits them.

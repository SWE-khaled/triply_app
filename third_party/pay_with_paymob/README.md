

# **pay_with_paymob**

**A Flutter package to simplify Paymob gateway integration for Visa and mobile wallet payments.**

---

## **Features**  

- Seamless integration with Paymob's payment gateway.  
- Supports multiple payment methods: Visa and mobile wallets.  
- Customizable payment views with flexible style options.  
- User data collection for personalized payment experiences.  
- Callback functions for handling payment success and errors.  

---

## **Getting Started**

### **Prerequisites**  

1. Ensure Flutter SDK is installed on your machine.  
2. Create a Paymob account to obtain your API key and other required credentials.  

---

### **Installation**  

Add the following to your `pubspec.yaml` file:  

```yaml  
dependencies:  
  pay_with_paymob: ^1.4.0
```  

Run the following command to install the package:  
```bash  
flutter pub get  
```  

---

## **Usage**  

### **Initializing Payment Data**

Initialize payment data in your `main` function or within the `initState` of your widget:  

```dart  
PaymentData.initialize(
  apiKey: "Your API Key", // Required: Found under Dashboard -> Settings -> Account Info -> API Key
  iframeId: "Your Iframe ID", // Required: Found under Developers -> iframes
  integrationCardId: "Your Card Integration ID", // Required: Found under Developers -> Payment Integrations -> Online Card ID
  integrationMobileWalletId: "Your Wallet Integration ID", // Required: Found under Developers -> Payment Integrations -> Mobile Wallet ID

  // Optional User Data
  userData: UserData(
    email: "User Email", // Optional: Defaults to 'NA'
    phone: "User Phone", // Optional: Defaults to 'NA'
    name: "User First Name", // Optional: Defaults to 'NA'
    lastName: "User Last Name", // Optional: Defaults to 'NA'
  ),
  
  // Optional Style Customizations
  style: Style(
    primaryColor: Colors.blue, // Default: Colors.blue
    scaffoldColor: Colors.white, // Default: Colors.white
    appBarBackgroundColor: Colors.blue, // Default: Colors.blue
    appBarForegroundColor: Colors.white, // Default: Colors.white
    textStyle: TextStyle(), // Default: TextStyle()
    buttonStyle: ElevatedButton.styleFrom(), // Default: ElevatedButton.styleFrom()
    circleProgressColor: Colors.blue, // Default: Colors.blue
    unselectedColor: Colors.grey, // Default: Colors.grey
  ),
);
```  

---

### **Navigating to the Payment View**  

After initializing the payment data, navigate to the payment view:  

```dart  
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PaymentView(
      onPaymentSuccess: () {
        // Handle payment success
      },
      onPaymentError: () {
        // Handle payment failure
      },
      price: 100, // Required: Total price (e.g., 100 for 100 EGP)
    ),
  ),
);
```  

---

## **Additional Information**

### **Test Data for Simulation**  

#### **Visa Card**  
- **Card Number:** 5123456789012346  
- **Card Holder Name:** Test Account  
- **Expiry Date:** 12/25  
- **CVV:** 123  

#### **Mobile Wallet**  
- **Wallet Number:** 01010101010  
- **MPIN:** 123456  
- **One-Time Password:** 123456  

For more details, refer to the [documentation](https://github.com/dev-KarimAhmed/paymob_payment_package).  

---

## **Contributions**  

Contributions are welcome! If you encounter issues or have suggestions for improvements, feel free to open an issue on GitHub.  


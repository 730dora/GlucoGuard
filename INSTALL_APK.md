# Installing the APK on Your Android Phone

## Option 1: Install via USB (Recommended)

1. **Connect your phone via USB** to your computer
2. **Enable USB Debugging** on your phone:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times to enable Developer Options
   - Go back to Settings → Developer Options
   - Enable "USB Debugging"
3. **Allow USB Debugging** when prompted on your phone
4. **Run this command:**
   ```powershell
   flutter install
   ```
   Or manually:
   ```powershell
   adb install build\app\outputs\flutter-apk\app-debug.apk
   ```

## Option 2: Transfer APK Manually

1. **Copy the APK** from: `build\app\outputs\flutter-apk\app-debug.apk`
2. **Transfer to your phone** via:
   - Email it to yourself
   - Use Google Drive/Dropbox
   - Use a USB cable and copy to phone storage
3. **On your phone:**
   - Open File Manager
   - Find the APK file
   - Tap it to install
   - Allow "Install from Unknown Sources" if prompted

## After Installation

✅ **Backend is running** on `localhost:5000`  
✅ **Public URL is active**: `https://sublabial-unpondered-tiffanie.ngrok-free.dev`  
✅ **APK is ready**: `build\app\outputs\flutter-apk\app-debug.apk`

The app will automatically connect via the public URL when you're on mobile data!






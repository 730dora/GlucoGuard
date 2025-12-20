# Setting Up Backend for Mobile Data Access

When you switch to mobile data, your phone can't reach the local IP address (`192.168.x.x`) because it's on a different network. You need to expose your backend publicly.

## Option 1: Using serveo.net (Easiest - No Installation!)

**This is the simplest option - no downloads needed!**

1. **Make sure your backend is running:**
   ```powershell
   python backend.py
   ```

2. **In a new terminal, run:**
   ```powershell
   .\start_backend_public.ps1
   ```
   Or manually:
   ```powershell
   ssh -R 80:localhost:5000 serveo.net
   ```

3. **Copy the public URL** (looks like `https://xxxx.serveo.net`)

4. **Update `assets/config.json`:**
   ```json
   {
     "backend_url": "http://192.168.215.100:5000",
     "backend_url_public": "https://xxxx.serveo.net"
   }
   ```

5. **Restart your Flutter app** - it will now work on mobile data!

## Option 2: Download ngrok (If serveo doesn't work)

1. **Download ngrok:**
   ```powershell
   .\download_ngrok.ps1
   ```
   Or manually download from: https://ngrok.com/download

2. **Start the backend:**
   ```powershell
   python backend.py
   ```

3. **In a new terminal, start ngrok:**
   ```powershell
   .\ngrok.exe http 5000
   ```

4. **Copy the public URL** (looks like `https://xxxx-xxxx-xxxx.ngrok-free.app`)

5. **Update `assets/config.json`** with the URL in `backend_url_public`

## Option 3: Deploy to Cloud (Production)

For a permanent solution, deploy your backend to:
- **Heroku**: Free tier available
- **Railway**: Easy deployment
- **Render**: Free tier available
- **AWS/GCP/Azure**: More complex but scalable

Then update `backend_url_public` in `config.json` with your cloud URL.

## How It Works

The app now tries URLs in this order:
1. Public URL (from `backend_url_public`) - works on mobile data
2. Local URL (from `backend_url`) - works on same WiFi network
3. Common network IPs - automatic fallback

The app will automatically use the public URL when on mobile data!


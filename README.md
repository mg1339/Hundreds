# Hundreds - Workout Tracker PWA

A mobile-optimized Progressive Web App for tracking your daily "Hundreds" workout routine:
- 100 pushups
- 100 situps  
- 100 squats
- 10 mile run

## 🚀 Features

### ✅ Daily Tracking
- **Interactive Counters**: Tap +/- buttons or type directly to update your progress
- **Visual Progress Bars**: See your completion percentage at a glance
- **Real-time Updates**: Progress saves automatically as you work out
- **Smart Input Validation**: Prevents invalid entries and handles edge cases

### 📅 Calendar View
- **Monthly Overview**: See your workout history in a clean calendar grid
- **Color-coded Days**: Green (complete), yellow (partial), gray (no activity)
- **Compact Display**: Each day shows pushups/situps/squats and running miles
- **Detailed Day View**: Tap any day to see exact numbers and completion percentage

### 💾 Data Management
- **Local Storage**: All data stays on your device for privacy
- **Export/Import**: Backup your data as JSON files
- **Automatic Midnight Reset**: New day starts fresh with timezone handling
- **Data Persistence**: Never lose your progress, even if you close the browser

### 📱 Progressive Web App
- **Install on Home Screen**: Works like a native app on mobile and desktop
- **Offline Functionality**: Use the app without internet connection
- **Mobile Optimized**: Touch-friendly buttons (44px+ tap targets)
- **Responsive Design**: Looks great on any screen size
- **Dark Mode Support**: Automatically adapts to system preferences

## 🛠 Installation

### Option 1: Direct Use
1. Open [`index.html`](index.html) in any modern web browser
2. The app works immediately - no installation required!

### Option 2: Install as PWA
**On Mobile (iOS/Android):**
1. Open the app in Safari (iOS) or Chrome (Android)
2. Tap the share button
3. Select "Add to Home Screen"
4. The app icon will appear on your home screen

**On Desktop:**
1. Open the app in Chrome, Edge, or Firefox
2. Look for the install icon in the address bar
3. Click "Install Hundreds"
4. The app will open in its own window

### Option 3: Local Development
```bash
# Serve with any local server
python -m http.server 8000
# or
npx serve .
# or
php -S localhost:8000
```

## 📖 How to Use

### Daily Workout Tracking
1. **Open the app** - see today's date and current progress
2. **Update counters** using:
   - **+/- buttons**: Quick increments (1 for exercises, 0.1 for running)
   - **Direct input**: Type exact numbers in the input fields
3. **Watch progress bars** fill up as you complete exercises
4. **See total completion** percentage and motivational messages

### Viewing History
1. **Tap the calendar icon** in the top-right corner
2. **Browse months** using the arrow buttons
3. **Tap any day** with data to see detailed breakdown
4. **Return to today** using the "Back to Today" button

### Data Management
1. **Tap the settings icon** (gear) in the top-right
2. **Export Data**: Download a JSON backup file
3. **Import Data**: Upload a previously exported JSON file
4. **Reset Options**: Clear today's data or all historical data

## 🏗 Technical Details

### File Structure
```
/
├── index.html          # Main app interface
├── styles.css          # Mobile-optimized styling  
├── script.js           # Core application logic
├── manifest.json       # PWA configuration
├── service-worker.js   # Offline functionality
├── project-plan.md     # Original project specification
└── README.md          # This documentation
```

### Data Structure
The app stores data in browser localStorage using this JSON structure:
```javascript
{
  "currentDate": "2025-01-15",
  "currentData": {
    "pushups": 25,
    "situps": 50, 
    "squats": 30,
    "running": 1.5
  },
  "workoutHistory": {
    "2025-01-14": {
      "pushups": 100,
      "situps": 100,
      "squats": 100,
      "running": 5.0,
      "timestamp": "2025-01-14T23:45:00.000Z"
    }
  }
}
```

### Browser Compatibility
- **Mobile**: iOS Safari 12+, Chrome 80+, Firefox 85+
- **Desktop**: Chrome 80+, Firefox 85+, Safari 14+, Edge 80+
- **Requirements**: localStorage support, modern JavaScript (ES6+)

### PWA Features
- **Offline Support**: Service worker caches all resources
- **App-like Experience**: Standalone display mode
- **Background Sync**: Ensures data persistence
- **Responsive Icons**: Adaptive icons for different platforms
- **Shortcuts**: Quick access to today's workout and calendar

## 🎯 Usage Tips

### Maximizing Your Workout
- **Break it down**: Don't try to do all 100 at once
- **Track throughout the day**: Update as you complete sets
- **Use the visual feedback**: Progress bars help maintain motivation
- **Check your streaks**: Calendar view shows consistency patterns

### Data Safety
- **Regular exports**: Backup your data monthly
- **Multiple devices**: Import/export to sync between devices
- **Browser data**: Clearing browser data will reset the app

### Mobile Optimization
- **Add to home screen**: For the best mobile experience
- **Portrait orientation**: App is optimized for vertical use
- **Touch targets**: All buttons are sized for easy tapping
- **Swipe navigation**: Smooth interactions throughout

## 🔧 Customization

### Modifying Targets
To change the default targets (100/100/100/5.0), edit the `targets` object in [`script.js`](script.js:4):
```javascript
this.targets = { pushups: 150, situps: 150, squats: 150, running: 3.0 };
```

### Styling Changes
All visual customization can be done in [`styles.css`](styles.css). The app uses CSS custom properties for easy theming.

### Adding Exercises
To add new exercises, you'll need to modify:
1. [`index.html`](index.html) - Add new exercise card
2. [`script.js`](script.js) - Add to exercises array and targets
3. [`styles.css`](styles.css) - Add any specific styling

## 🚀 Deployment

### GitHub Pages
1. Push code to a GitHub repository
2. Go to Settings → Pages
3. Select source branch (usually `main`)
4. Your app will be available at `https://username.github.io/repository-name`

### Custom Domain
1. Deploy to any static hosting service
2. Upload all files to the web root
3. Ensure HTTPS is enabled for PWA features

### Local Network
```bash
# Share on local network
python -m http.server 8000 --bind 0.0.0.0
# Access from other devices at http://YOUR_IP:8000
```

## 🐛 Troubleshooting

### App Not Installing
- Ensure you're using HTTPS (required for PWA)
- Check that [`manifest.json`](manifest.json) is accessible
- Verify service worker is registering (check browser dev tools)

### Data Not Saving
- Check if localStorage is enabled in browser settings
- Ensure you're not in private/incognito mode
- Try exporting data as backup

### Midnight Reset Not Working
- The app checks for new day every minute when open
- Close and reopen the app if date seems stuck
- Check your device's timezone settings

### Performance Issues
- Clear browser cache and reload
- Check if service worker is functioning (dev tools → Application)
- Ensure you have sufficient storage space

## 📈 Future Enhancements

Potential features for future versions:
- **Streak tracking** and achievement badges
- **Weekly/monthly progress charts** and analytics
- **Custom workout targets** per user
- **Social sharing** of achievements
- **Apple Health / Google Fit integration**
- **Push notifications** for workout reminders
- **Multiple workout routines** support
- **Cloud sync** across devices

## 📄 License

This project is open source and available under the MIT License.

## 🤝 Contributing

Feel free to submit issues, feature requests, or pull requests to improve the app!

---

**Ready to crush your hundreds? 💪**


Start tracking your daily workout progress and build consistency with this powerful, offline-capable PWA!

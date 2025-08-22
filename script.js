// Hundreds Workout Tracker - Main Application Logic
class HundredsApp {
    constructor() {
        this.exercises = ['pushups', 'situps', 'squats', 'running'];
        this.targets = { pushups: 100, situps: 100, squats: 100, running: 10.0 };
        this.currentData = { pushups: 0, situps: 0, squats: 0, running: 0.0 };
        this.currentDate = this.getTodayString();
        this.currentView = 'tracking';
        this.currentCalendarDate = new Date();
        this.currentTheme = localStorage.getItem('hundredsTheme') || 'dark';
        
        this.init();
    }

    init() {
        this.loadData();
        this.setupEventListeners();
        this.updateDisplay();
        this.updateDateDisplay();
        this.checkForNewDay();
        this.applyTheme();
    }

    // Date and Time Utilities
    getTodayString() {
        const now = new Date();
        return now.toISOString().split('T')[0];
    }

    formatDate(dateString) {
        const date = new Date(dateString + 'T00:00:00');
        return date.toLocaleDateString('en-US', { 
            weekday: 'long', 
            year: 'numeric', 
            month: 'long', 
            day: 'numeric' 
        });
    }

    // Data Management
    loadData() {
        try {
            const stored = localStorage.getItem('hundredsData');
            if (stored) {
                const data = JSON.parse(stored);
                this.currentDate = data.currentDate || this.getTodayString();
                this.currentData = data.currentData || { pushups: 0, situps: 0, squats: 0, running: 0.0 };
                this.workoutHistory = data.workoutHistory || {};
                
                // Check if we need to reset for a new day
                if (this.currentDate !== this.getTodayString()) {
                    this.handleNewDay();
                }
            } else {
                this.workoutHistory = {};
            }
        } catch (error) {
            console.error('Error loading data:', error);
            this.workoutHistory = {};
            this.currentData = { pushups: 0, situps: 0, squats: 0, running: 0.0 };
        }
    }

    saveData() {
        try {
            const dataToSave = {
                currentDate: this.currentDate,
                currentData: this.currentData,
                workoutHistory: this.workoutHistory,
                lastSaved: new Date().toISOString()
            };
            localStorage.setItem('hundredsData', JSON.stringify(dataToSave));
        } catch (error) {
            console.error('Error saving data:', error);
            this.showNotification('Error saving data', 'error');
        }
    }

    handleNewDay() {
        // Save yesterday's data to history if there was any progress
        if (this.hasAnyProgress(this.currentData)) {
            this.workoutHistory[this.currentDate] = {
                ...this.currentData,
                timestamp: new Date().toISOString()
            };
        }
        
        // Reset for new day
        this.currentDate = this.getTodayString();
        this.currentData = { pushups: 0, situps: 0, squats: 0, running: 0.0 };
        this.saveData();
    }

    checkForNewDay() {
        // Check every minute if we've crossed midnight
        setInterval(() => {
            const today = this.getTodayString();
            if (today !== this.currentDate) {
                this.handleNewDay();
                this.updateDisplay();
                this.updateDateDisplay();
                this.showNotification('New day started! 💪', 'success');
            }
        }, 60000); // Check every minute
    }

    hasAnyProgress(data) {
        return data.pushups > 0 || data.situps > 0 || data.squats > 0 || data.running > 0;
    }

    // Event Listeners
    setupEventListeners() {
        // Counter buttons
        document.querySelectorAll('.btn-counter').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const exercise = e.target.dataset.exercise;
                const action = e.target.dataset.action;
                this.updateCounter(exercise, action);
            });
        });

        // Input fields
        this.exercises.forEach(exercise => {
            const input = document.getElementById(`${exercise}Input`);
            input.addEventListener('change', (e) => {
                this.updateCounterFromInput(exercise, e.target.value);
            });
            input.addEventListener('blur', (e) => {
                this.updateCounterFromInput(exercise, e.target.value);
            });
        });

        // Navigation buttons
        document.getElementById('calendarBtn').addEventListener('click', () => {
            this.showCalendarView();
        });

        document.getElementById('backToTracking').addEventListener('click', () => {
            this.showTrackingView();
        });

        document.getElementById('settingsBtn').addEventListener('click', () => {
            this.showSettingsModal();
        });

        // Theme dropdown
        document.getElementById('themeSelect').addEventListener('change', (e) => {
            this.changeTheme(e.target.value);
        });

        // Calendar navigation
        document.getElementById('prevMonth').addEventListener('click', () => {
            this.navigateCalendar(-1);
        });

        document.getElementById('nextMonth').addEventListener('click', () => {
            this.navigateCalendar(1);
        });

        // Modal controls
        document.getElementById('closeModal').addEventListener('click', () => {
            this.hideModal('dayModal');
        });

        document.getElementById('closeSettingsModal').addEventListener('click', () => {
            this.hideModal('settingsModal');
        });

        // Settings actions
        document.getElementById('exportData').addEventListener('click', () => {
            this.exportData();
        });

        document.getElementById('importData').addEventListener('click', () => {
            document.getElementById('importFile').click();
        });

        document.getElementById('importFile').addEventListener('change', (e) => {
            this.importData(e.target.files[0]);
        });

        document.getElementById('resetToday').addEventListener('click', () => {
            this.resetToday();
        });


        // Close modals when clicking overlay
        document.querySelectorAll('.modal-overlay').forEach(modal => {
            modal.addEventListener('click', (e) => {
                if (e.target === modal) {
                    modal.style.display = 'none';
                }
            });
        });
    }

    // Counter Management
    updateCounter(exercise, action) {
        const increment = exercise === 'running' ? 0.1 : 1;
        const currentValue = this.currentData[exercise];
        
        let newValue;
        if (action === 'add') {
            newValue = currentValue + increment;
        } else if (action === 'subtract') {
            newValue = Math.max(0, currentValue - increment);
        }

        // Round running to 1 decimal place
        if (exercise === 'running') {
            newValue = Math.round(newValue * 10) / 10;
        }

        this.currentData[exercise] = newValue;
        this.updateDisplay();
        this.saveData();
        
        // Add visual feedback
        this.addProgressFeedback(exercise);
    }

    updateCounterFromInput(exercise, value) {
        let numValue = parseFloat(value) || 0;
        
        // Validate bounds
        if (exercise === 'running') {
            numValue = Math.max(0, Math.min(99.9, numValue));
            numValue = Math.round(numValue * 10) / 10;
        } else {
            numValue = Math.max(0, Math.min(999, Math.floor(numValue)));
        }

        this.currentData[exercise] = numValue;
        this.updateDisplay();
        this.saveData();
    }

    addProgressFeedback(exercise) {
        // Removed card bounce animation for cleaner interaction
    }

    // Display Updates
    updateDisplay() {
        this.exercises.forEach(exercise => {
            const count = this.currentData[exercise];
            const target = this.targets[exercise];
            const percentage = Math.min(100, (count / target) * 100);

            // Update counter display
            const countElement = document.getElementById(`${exercise}Count`);
            if (exercise === 'running') {
                countElement.textContent = count.toFixed(1);
            } else {
                countElement.textContent = count.toString();
            }

            // Update input field
            const inputElement = document.getElementById(`${exercise}Input`);
            if (exercise === 'running') {
                inputElement.value = count.toFixed(1);
            } else {
                inputElement.value = count.toString();
            }

            // Add completion styling
            const card = countElement.closest('.exercise-card');
            if (percentage >= 100) {
                card.classList.add('success-flash');
                setTimeout(() => card.classList.remove('success-flash'), 1000);
            }
        });

        this.updateSummary();
    }

    updateSummary() {
        // Summary removed for simplicity
    }

    updateDateDisplay() {
        document.getElementById('currentDate').textContent = this.formatDate(this.currentDate);
    }

    calculateTotalProgress(data) {
        let totalPercentage = 0;
        this.exercises.forEach(exercise => {
            const percentage = Math.min(100, (data[exercise] / this.targets[exercise]) * 100);
            totalPercentage += percentage;
        });
        return Math.round(totalPercentage / this.exercises.length);
    }

    // View Management
    showCalendarView() {
        document.getElementById('trackingView').style.display = 'none';
        document.getElementById('calendarView').style.display = 'block';
        this.currentView = 'calendar';
        this.renderCalendar();
    }

    showTrackingView() {
        document.getElementById('calendarView').style.display = 'none';
        document.getElementById('trackingView').style.display = 'block';
        this.currentView = 'tracking';
    }

    // Calendar Management
    renderCalendar() {
        const year = this.currentCalendarDate.getFullYear();
        const month = this.currentCalendarDate.getMonth();
        
        // Update calendar title
        document.getElementById('calendarTitle').textContent = 
            this.currentCalendarDate.toLocaleDateString('en-US', { month: 'long', year: 'numeric' });

        // Clear existing calendar
        const grid = document.getElementById('calendarGrid');
        grid.innerHTML = '';

        // Add day headers
        const dayHeaders = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        dayHeaders.forEach(day => {
            const header = document.createElement('div');
            header.className = 'calendar-day-header';
            header.textContent = day;
            header.style.cssText = 'font-weight: 600; padding: 0.5rem; text-align: center; background: #f5f5f5; color: #666;';
            grid.appendChild(header);
        });

        // Get first day of month and number of days
        const firstDay = new Date(year, month, 1);
        const lastDay = new Date(year, month + 1, 0);
        const daysInMonth = lastDay.getDate();
        const startingDayOfWeek = firstDay.getDay();

        // Add empty cells for days before month starts
        for (let i = 0; i < startingDayOfWeek; i++) {
            const emptyDay = document.createElement('div');
            emptyDay.className = 'calendar-day other-month';
            grid.appendChild(emptyDay);
        }

        // Add days of the month
        for (let day = 1; day <= daysInMonth; day++) {
            const dayElement = document.createElement('div');
            const dateString = `${year}-${String(month + 1).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
            const isToday = dateString === this.getTodayString();
            const dayData = this.workoutHistory[dateString] || (isToday ? this.currentData : null);

            dayElement.className = 'calendar-day';
            if (isToday) dayElement.classList.add('today');

            // Create day content
            const dayNumber = document.createElement('div');
            dayNumber.className = 'day-number';
            dayNumber.textContent = day;
            dayElement.appendChild(dayNumber);

            if (dayData) {
                const progress = document.createElement('div');
                progress.className = 'day-progress';
                
                const totalProgress = this.calculateTotalProgress(dayData);
                if (totalProgress === 100) {
                    dayElement.classList.add('complete');
                } else if (totalProgress > 0) {
                    dayElement.classList.add('partial');
                }

                // Show compact progress
                progress.innerHTML = `
                    ${dayData.pushups}/${dayData.situps}/${dayData.squats}<br>
                    ${dayData.running.toFixed(1)}mi
                `;
                dayElement.appendChild(progress);
            }

            // Add click handler
            dayElement.addEventListener('click', () => {
                if (dayData) {
                    this.showDayDetail(dateString, dayData);
                }
            });

            grid.appendChild(dayElement);
        }
    }

    navigateCalendar(direction) {
        this.currentCalendarDate.setMonth(this.currentCalendarDate.getMonth() + direction);
        this.renderCalendar();
    }

    showDayDetail(dateString, data) {
        document.getElementById('modalDate').textContent = this.formatDate(dateString);
        document.getElementById('modalPushups').textContent = `${data.pushups}/100`;
        document.getElementById('modalSitups').textContent = `${data.situps}/100`;
        document.getElementById('modalSquats').textContent = `${data.squats}/100`;
        document.getElementById('modalRunning').textContent = `${data.running.toFixed(1)}/5.0 mi`;
        document.getElementById('modalTotalProgress').textContent = `${this.calculateTotalProgress(data)}%`;
        
        this.showModal('dayModal');
    }

    // Modal Management
    showModal(modalId) {
        document.getElementById(modalId).style.display = 'flex';
    }

    hideModal(modalId) {
        document.getElementById(modalId).style.display = 'none';
    }

    showSettingsModal() {
        // Update dropdown to current theme
        document.getElementById('themeSelect').value = this.currentTheme;
        this.showModal('settingsModal');
    }

    // Data Import/Export
    exportData() {
        try {
            const dataToExport = {
                currentDate: this.currentDate,
                currentData: this.currentData,
                workoutHistory: this.workoutHistory,
                exportDate: new Date().toISOString(),
                version: '1.0'
            };

            const blob = new Blob([JSON.stringify(dataToExport, null, 2)], { type: 'application/json' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `hundreds-backup-${this.getTodayString()}.json`;
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);

            this.showNotification('Data exported successfully!', 'success');
        } catch (error) {
            console.error('Export error:', error);
            this.showNotification('Error exporting data', 'error');
        }
    }

    importData(file) {
        if (!file) return;

        const reader = new FileReader();
        reader.onload = (e) => {
            try {
                const importedData = JSON.parse(e.target.result);
                
                // Validate data structure
                if (!importedData.workoutHistory || !importedData.currentData) {
                    throw new Error('Invalid data format');
                }

                // Merge with existing data
                this.workoutHistory = { ...this.workoutHistory, ...importedData.workoutHistory };
                
                // Only update current data if it's from today
                if (importedData.currentDate === this.getTodayString()) {
                    this.currentData = importedData.currentData;
                }

                this.saveData();
                this.updateDisplay();
                this.showNotification('Data imported successfully!', 'success');
                this.hideModal('settingsModal');
            } catch (error) {
                console.error('Import error:', error);
                this.showNotification('Error importing data. Please check file format.', 'error');
            }
        };
        reader.readAsText(file);
    }

    // Reset Functions
    resetToday() {
        if (confirm('Are you sure you want to reset today\'s progress? This cannot be undone.')) {
            this.currentData = { pushups: 0, situps: 0, squats: 0, running: 0.0 };
            this.updateDisplay();
            this.saveData();
            this.showNotification('Today\'s progress reset', 'success');
            this.hideModal('settingsModal');
        }
    }


    // Notifications
    showNotification(message, type = 'info') {
        // Create notification element
        const notification = document.createElement('div');
        notification.style.cssText = `
            position: fixed;
            top: 20px;
            left: 50%;
            transform: translateX(-50%);
            background: ${type === 'success' ? '#4CAF50' : type === 'error' ? '#F44336' : '#2196F3'};
            color: white;
            padding: 1rem 2rem;
            border-radius: 8px;
            z-index: 10000;
            font-weight: 600;
            box-shadow: 0 4px 12px rgba(0,0,0,0.3);
            animation: slideDown 0.3s ease;
        `;
        notification.textContent = message;

        // Add animation keyframes
        if (!document.querySelector('#notification-styles')) {
            const style = document.createElement('style');
            style.id = 'notification-styles';
            style.textContent = `
                @keyframes slideDown {
                    from { transform: translateX(-50%) translateY(-100%); opacity: 0; }
                    to { transform: translateX(-50%) translateY(0); opacity: 1; }
                }
            `;
            document.head.appendChild(style);
        }

        document.body.appendChild(notification);

        // Remove after 3 seconds
        setTimeout(() => {
            notification.style.animation = 'slideDown 0.3s ease reverse';
            setTimeout(() => {
                if (notification.parentNode) {
                    notification.parentNode.removeChild(notification);
                }
            }, 300);
        }, 3000);
    }

    // Theme Management
    changeTheme(themeName) {
        this.currentTheme = themeName;
        localStorage.setItem('hundredsTheme', this.currentTheme);
        this.applyTheme();
    }

    applyTheme() {
        const body = document.body;
        body.className = ''; // Clear existing theme classes
        body.classList.add(`theme-${this.currentTheme}`);
    }
}

// Initialize app when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.hundredsApp = new HundredsApp();
});

// Register service worker for PWA functionality
if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
        navigator.serviceWorker.register('./service-worker.js')
            .then(registration => {
                console.log('SW registered: ', registration);
            })
            .catch(registrationError => {
                console.log('SW registration failed: ', registrationError);
            });
    });
}
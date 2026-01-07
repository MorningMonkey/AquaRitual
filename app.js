document.addEventListener('DOMContentLoaded', () => {
    // --- State ---
    const STORAGE_KEY = 'aqua-ritual-data';
    let state = {
        habits: [], // { id, title, completedDate }
        streak: 0,
        lastStreakDate: null
    };

    // --- DOM Elements ---
    const habitListEl = document.getElementById('habit-list');
    const formEl = document.getElementById('add-habit-form');
    const inputEl = document.getElementById('habit-input');
    const streakEl = document.getElementById('streak-display');
    const plantLayer = document.getElementById('plantLayer');
    const bubbleLayer = document.getElementById('bubbleLayer');
    const fishLayer = document.getElementById('fishLayer');

    // --- Core Logic: Load & Save ---
    function loadData() {
        const raw = localStorage.getItem(STORAGE_KEY);
        if (raw) {
            state = JSON.parse(raw);
            checkStreakReset();
        }
        render();
    }

    function saveData() {
        localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
        renderAquarium(); // Update visuals based on new state
    }

    function checkStreakReset() {
        // Simple streak logic: if last completed date was before yesterday, reset streak
        // (This is a simplified version; robust date handling would ideally use a library)
        const today = new Date().toDateString();
        // If needed, check gap between today and lastStreakDate
        // For MVP, simplistic check is handled on completion.
    }

    // --- Core Logic: Habits ---
    function addHabit(title) {
        state.habits.push({
            id: Date.now().toString(),
            title,
            completedDate: null
        });
        saveData();
        render();
    }

    function toggleHabit(id) {
        const habit = state.habits.find(h => h.id === id);
        if (!habit) return;

        const today = new Date().toDateString();
        if (habit.completedDate === today) {
            // Uncheck
            habit.completedDate = null;
        } else {
            // Check
            habit.completedDate = today;
            triggerCompletionEffects();
        }
        updateStreak();
        saveData();
        render();
    }

    function deleteHabit(id) {
        state.habits = state.habits.filter(h => h.id !== id);
        saveData();
        render();
    }

    function updateStreak() {
        // Calculate progress for today
        const completedCount = state.habits.filter(h => h.completedDate === new Date().toDateString()).length;
        if (completedCount > 0) {
            // Just a visual streak increment for MVP feel
            // Real streak logic requires persistent history tracking
            // state.streak = ... 
        }
    }

    function getTodayProgress() {
        if (state.habits.length === 0) return 0;
        const today = new Date().toDateString();
        const completed = state.habits.filter(h => h.completedDate === today).length;
        return completed / state.habits.length;
    }

    // --- Rendering: UI ---
    function render() {
        habitListEl.innerHTML = '';
        const today = new Date().toDateString();

        state.habits.forEach(habit => {
            const isCompleted = habit.completedDate === today;
            const li = document.createElement('li');
            li.className = `habit-item ${isCompleted ? 'completed' : ''}`;
            
            li.innerHTML = `
                <span class="habit-title">${escapeHtml(habit.title)}</span>
                <div style="display:flex; align-items:center;">
                    <button class="check-btn" onclick="appToggle('${habit.id}')">
                        ${isCompleted ? '✓' : ''}
                    </button>
                    <button class="delete-btn" onclick="appDelete('${habit.id}')">✕</button>
                </div>
            `;
            habitListEl.appendChild(li);
        });

        streakEl.textContent = `Streak: ${state.streak}`;
        
        // Render Aquarium immediately after UI
        renderAquarium();
    }

    // --- Rendering: Aquarium ---
    function renderAquarium() {
        const progress = getTodayProgress(); // 0.0 to 1.0
        
        // 1. Plant Growth
        const plants = plantLayer.querySelectorAll('.plant');
        plants.forEach((plant, index) => {
            // Base height + Growth based on progress
            // Random variance for natural look
            const baseHeight = 30 + (index * 5); 
            const maxHeight = 120 + (index * 10);
            const currentHeight = baseHeight + ((maxHeight - baseHeight) * progress);
            
            plant.style.height = `${currentHeight}px`;
            
            if (progress >= 0.8) {
                plant.classList.add('grown');
            } else {
                plant.classList.remove('grown');
            }
        });
    }

    function triggerCompletionEffects() {
        spawnBubbles();
        spawnFishBoost();
    }

    function spawnBubbles() {
        const count = Math.floor(Math.random() * 6) + 6; // 6-12 bubbles
        for (let i = 0; i < count; i++) {
            const bubble = document.createElement('div');
            bubble.classList.add('bubble');
            
            // Random position at bottom
            const left = Math.random() * 100;
            bubble.style.left = `${left}%`;
            
            // Random size variation
            const size = 5 + Math.random() * 10;
            bubble.style.width = `${size}px`;
            bubble.style.height = `${size}px`;
            
            bubbleLayer.appendChild(bubble);
            
            // Remove after animation
            setTimeout(() => {
                bubble.remove();
            }, 4000);
        }
    }

    function spawnFishBoost() {
        const fish = fishLayer.querySelectorAll('.fish');
        fish.forEach(f => {
            f.classList.add('boosted');
            setTimeout(() => {
                f.classList.remove('boosted');
            }, 5000);
        });
    }

    // --- Utilities ---
    function escapeHtml(text) {
        return text.replace(/[&<>"']/g, function(m) {
            return {
                '&': '&amp;',
                '<': '&lt;',
                '>': '&gt;',
                '"': '&quot;',
                "'": '&#039;'
            }[m];
        });
    }

    // --- Event Listeners ---
    formEl.addEventListener('submit', (e) => {
        e.preventDefault();
        const val = inputEl.value.trim();
        if (val) {
            addHabit(val);
            inputEl.value = '';
        }
    });

    // Global exposed functions for inline onclick handlers
    window.appToggle = toggleHabit;
    window.appDelete = deleteHabit;

    // Init
    loadData();
});

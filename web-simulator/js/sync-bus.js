// Simulated Apple Multipeer Connectivity Event Bus
class KitchenSyncBus {
  constructor() {
    this.stations = JSON.parse(JSON.stringify(window.KITCHEN_DATA.initialStations));
    this.listeners = [];
  }

  init() {
    this.renderCompanionStations();
  }

  subscribe(callback) {
    this.listeners.push(callback);
  }

  broadcast(event, payload) {
    this.listeners.forEach(cb => cb(event, payload));
  }

  toggleStationTask(stationId, taskId) {
    const station = this.stations.find(s => s.id === stationId);
    if (!station) return;

    const task = station.tasks.find(t => t.id === taskId);
    if (!task) return;

    task.completed = !task.completed;

    if (window.SFX) {
      window.SFX.playFocusTick();
    }

    // Calculate new progress
    const completedCount = station.tasks.filter(t => t.completed).length;
    const totalCount = station.tasks.length;
    const pct = Math.round((completedCount / totalCount) * 100);

    // Broadcast update to Apple TV
    this.broadcast('station_task_updated', {
      stationId,
      stationName: station.name,
      taskId,
      taskText: task.text,
      isCompleted: task.completed,
      completedCount,
      totalCount,
      percentage: pct
    });

    if (task.completed) {
      if (window.SFX) window.SFX.playStepComplete();
      if (window.App) {
        window.App.showToast(`✨ ${station.name} completed: "${task.text}"!`, station.color);
      }
    }

    this.renderCompanionStations();
    if (window.App) {
      window.App.renderSubstationStrip();
    }
  }

  renderCompanionStations() {
    const container = document.getElementById('companion-dock-container');
    if (!container) return;

    let html = '';
    this.stations.forEach(station => {
      const completed = station.tasks.filter(t => t.completed).length;
      const total = station.tasks.length;
      const pct = Math.round((completed / total) * 100);

      html += `
        <div class="companion-device-card" style="--device-accent: ${station.color}">
          <div class="device-notch"></div>
          <div class="device-screen-header">
            <div class="device-status-row">
              <span class="device-time">15:15</span>
              <span class="device-sync-tag">
                <span class="pulse-dot"></span> Synced to Apple TV 4K
              </span>
            </div>
            <div class="device-user-info">
              <div class="user-avatar" style="background: ${station.color}22; color: ${station.color}">
                ${station.name.split(' ')[1][0]}
              </div>
              <div>
                <h4 class="device-user-name">${station.name}</h4>
                <p class="device-model">${station.device} • ${station.roleLabel}</p>
              </div>
            </div>
          </div>

          <div class="device-progress-bar-wrap">
            <div class="progress-meta">
              <span>Station Progress</span>
              <strong>${completed}/${total} (${pct}%)</strong>
            </div>
            <div class="progress-track">
              <div class="progress-fill" style="width: ${pct}%; background: ${station.color};"></div>
            </div>
          </div>

          <div class="device-task-list">
            <div class="device-section-title">ACTIVE CHECKLIST</div>
            ${station.tasks.map(task => `
              <div class="device-task-item ${task.completed ? 'completed' : ''}" onclick="window.SyncBus.toggleStationTask('${station.id}', '${task.id}')">
                <div class="task-checkbox ${task.completed ? 'checked' : ''}">
                  ${task.completed ? '✓' : ''}
                </div>
                <div class="task-text-body">
                  <span class="task-label">${task.text}</span>
                </div>
              </div>
            `).join('')}
          </div>

          <div class="device-footer-bar">
            <button class="companion-quick-btn" onclick="window.Voice.simulateCommand('next step')">
              Next Step ➔
            </button>
            <button class="companion-quick-btn sub" onclick="window.App.openSubstitutionsModal()">
              Substitutions
            </button>
          </div>
        </div>
      `;
    });

    container.innerHTML = html;
  }
}

window.SyncBus = new KitchenSyncBus();

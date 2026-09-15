<script setup>
import { ref, computed } from 'vue'

const activeTab = ref('remote-thread') // 'remote-thread' | 'hollowing'
const currentStep = ref(0)

const remoteThreadSteps = [
  {
    step: 1,
    title: '1. Target Acquisition',
    api: 'OpenProcess(PROCESS_ALL_ACCESS, FALSE, targetPID)',
    desc: 'Attacker process requests full access handle to legitimate victim (e.g. explorer.exe).',
    action: 'handle',
    badgeTone: 'info'
  },
  {
    step: 2,
    title: '2. Staging Memory in Target',
    api: 'VirtualAllocEx(hProcess, NULL, size, MEM_COMMIT, PAGE_EXECUTE_READWRITE)',
    desc: 'Attacker creates a new, unbacked memory allocation in the victim address space with RWX permissions.',
    action: 'alloc',
    badgeTone: 'warn'
  },
  {
    step: 3,
    title: '3. Copying Payload Code',
    api: 'WriteProcessMemory(hProcess, remoteAddr, shellcode, size, &bytesWritten)',
    desc: 'Attacker writes raw malicious payload or DLL path into the newly allocated RWX buffer.',
    action: 'write',
    badgeTone: 'bad'
  },
  {
    step: 4,
    title: '4. Remote Execution Hijack',
    api: 'CreateRemoteThread(hProcess, NULL, 0, remoteAddr, param, 0, NULL)',
    desc: 'Kernel dispatches a new execution thread inside the victim process, pointing directly at the shellcode entry point.',
    action: 'exec',
    badgeTone: 'good'
  }
]

const hollowingSteps = [
  {
    step: 1,
    title: '1. Suspended Process Creation',
    api: 'CreateProcess("svchost.exe", ..., CREATE_SUSPENDED, ...)',
    desc: 'Attacker spawns a benign binary in suspended state. Process & primary thread exist, but execution is paused.',
    action: 'spawn',
    badgeTone: 'info'
  },
  {
    step: 2,
    title: '2. Unmapping Original Code',
    api: 'NtUnmapViewOfSection(hProcess, baseAddress)',
    desc: 'The legitimate code section (.text) is hollowed out from memory, leaving the PEB, VAD, and outer shell intact.',
    action: 'unmap',
    badgeTone: 'warn'
  },
  {
    step: 3,
    title: '3. Implantation of Malicious PE',
    api: 'VirtualAllocEx(...) + WriteProcessMemory(...)',
    desc: 'Attacker allocates replacement memory at the image base and copies malicious PE headers & sections.',
    action: 'implant',
    badgeTone: 'bad'
  },
  {
    step: 4,
    title: '4. Context Hijack & Resume',
    api: 'SetThreadContext(hThread, &ctx) + ResumeThread(hThread)',
    desc: 'Primary thread register (EIP/RIP) is repointed to evil entry point. Task Manager sees genuine svchost.exe!',
    action: 'resume',
    badgeTone: 'good'
  }
]

const currentStepsList = computed(() => {
  return activeTab.value === 'remote-thread' ? remoteThreadSteps : hollowingSteps
})

const activeStepData = computed(() => {
  return currentStepsList.value[currentStep.value]
})

function setTab(tab) {
  activeTab.value = tab
  currentStep.value = 0
}

function nextStep() {
  if (currentStep.value < currentStepsList.value.length - 1) {
    currentStep.value++
  } else {
    currentStep.value = 0
  }
}

function prevStep() {
  if (currentStep.value > 0) {
    currentStep.value--
  }
}

function selectStep(idx) {
  currentStep.value = idx
}
</script>

<template>
  <div class="process-injection-container w-full select-none">
    <!-- Top Mode Selection & Step Navigation -->
    <div class="flex items-center justify-between gap-4 mb-2">
      <!-- Mode Toggle -->
      <div class="flex items-center gap-1.5 bg-slate-900/90 border border-slate-700/70 p-1 rounded-lg">
        <button
          class="mode-btn"
          :class="{ active: activeTab === 'remote-thread' }"
          @click="setTab('remote-thread')"
        >
          <span class="w-2 h-2 rounded-full" :class="activeTab === 'remote-thread' ? 'bg-rose-400' : 'bg-slate-500'"></span>
          Remote Thread Injection
        </button>
        <button
          class="mode-btn"
          :class="{ active: activeTab === 'hollowing' }"
          @click="setTab('hollowing')"
        >
          <span class="w-2 h-2 rounded-full" :class="activeTab === 'hollowing' ? 'bg-amber-400' : 'bg-slate-500'"></span>
          Process Hollowing (RunPE)
        </button>
      </div>

      <!-- Step Stepper Pills -->
      <div class="flex items-center gap-1">
        <button
          v-for="(st, idx) in currentStepsList"
          :key="st.step"
          class="step-pill"
          :class="{ active: currentStep === idx }"
          @click="selectStep(idx)"
        >
          Step {{ st.step }}
        </button>
        <button
          class="nav-btn ml-1"
          :disabled="currentStep === 0"
          @click="prevStep"
          title="Previous Step"
        >
          ◀
        </button>
        <button
          class="nav-btn text-cyan-400 font-bold"
          @click="nextStep"
          title="Next Step"
        >
          {{ currentStep === currentStepsList.length - 1 ? '↺ Replay' : 'Next ▶' }}
        </button>
      </div>
    </div>

    <!-- Active Step Description Header -->
    <div class="step-banner mb-2.5 px-3 py-1.5 rounded-md flex items-center justify-between">
      <div class="flex items-center gap-2.5">
        <span class="badge" :class="activeStepData.badgeTone">
          Step {{ activeStepData.step }}/4
        </span>
        <span class="font-bold text-sm text-slate-100 tracking-wide">{{ activeStepData.title }}</span>
        <span class="text-xs text-slate-400 font-mono hidden md:inline">|</span>
        <span class="text-xs text-slate-300">{{ activeStepData.desc }}</span>
      </div>
      <code class="text-[11px] font-mono text-cyan-300 bg-slate-950/80 px-2 py-0.5 rounded border border-cyan-900/40">
        {{ activeStepData.api }}
      </code>
    </div>

    <!-- Interactive Diagram Area -->
    <div class="grid grid-cols-12 gap-3 bg-slate-950/60 p-3 rounded-xl border border-slate-800/80">
      
      <!-- Left Column: Attacker Process Space -->
      <div class="col-span-4 flex flex-col bg-slate-900/80 rounded-lg p-2.5 border border-rose-950/40 shadow-inner">
        <div class="flex items-center justify-between border-b border-rose-900/30 pb-1.5 mb-2">
          <div class="flex items-center gap-1.5">
            <span class="w-2.5 h-2.5 rounded-full bg-rose-500 animate-pulse"></span>
            <span class="font-bold text-xs text-rose-300">Attacker (evil.exe)</span>
          </div>
          <span class="text-[10px] font-mono text-slate-400">PID: 6660</span>
        </div>

        <!-- Attacker Memory Map -->
        <div class="flex flex-col gap-1.5 text-xs font-mono">
          <!-- Stack -->
          <div class="mem-block bg-slate-800/60 border border-slate-700/40 text-slate-400">
            <div class="flex items-center justify-between">
              <span>[0x7FFF... Stack]</span>
              <span class="badge-sub">RW</span>
            </div>
          </div>

          <!-- Shellcode / Payload in Attacker -->
          <div
            class="mem-block transition-all duration-300"
            :class="(activeTab === 'remote-thread' && currentStep >= 2) || (activeTab === 'hollowing' && currentStep >= 2)
              ? 'bg-rose-950/80 border-rose-500/80 text-rose-200 ring-1 ring-rose-500/30'
              : 'bg-rose-950/40 border-rose-900/50 text-rose-300'"
          >
            <div class="flex items-center justify-between">
              <span>Payload Buffer / PE</span>
              <span class="badge-sub bg-rose-900/60 text-rose-300">RW</span>
            </div>
            <div class="text-[10px] text-slate-400 font-sans mt-0.5">
              {{ activeTab === 'remote-thread' ? 'Shellcode [0x90, 0xCC, ...]' : 'Replacement PE payload' }}
            </div>
          </div>

          <!-- Code -->
          <div class="mem-block bg-slate-800/60 border border-slate-700/40 text-slate-400">
            <div class="flex items-center justify-between">
              <span>[0x0040... .text]</span>
              <span class="badge-sub">RX</span>
            </div>
          </div>

          <!-- Handle Table status in Attacker -->
          <div class="mt-2 p-2 bg-slate-950/90 rounded border border-slate-800 text-[11px] font-sans">
            <div class="text-slate-400 font-medium mb-1">Attacker Object Handles:</div>
            <div class="flex items-center gap-1.5 font-mono text-[10px]">
              <span class="text-cyan-400">hTarget:</span>
              <span class="text-emerald-400">0x00000044</span>
              <span class="text-slate-500">({{ activeTab === 'remote-thread' ? 'OpenProcess' : 'hProcess' }})</span>
            </div>
            <div v-if="currentStep >= 3" class="flex items-center gap-1.5 font-mono text-[10px] mt-0.5">
              <span class="text-cyan-400">hThread:</span>
              <span class="text-emerald-400">0x0000005C</span>
              <span class="text-slate-500">(Active Remote Thread)</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Center Flow Indicators / Action Tunnel -->
      <div class="col-span-3 flex flex-col items-center justify-center gap-2 text-center px-1">
        
        <!-- Action Arrow Graphic -->
        <div class="w-full flex flex-col items-center gap-1.5 bg-slate-900/40 p-2 rounded-lg border border-slate-800">
          <span class="text-[11px] font-bold uppercase tracking-wider text-slate-400">Inter-Process Cross Action</span>

          <!-- Animated API Arrow -->
          <div class="w-full py-1.5 px-2 bg-slate-950 rounded border border-cyan-800/50 flex flex-col items-center relative overflow-hidden">
            <div class="text-[11px] font-mono font-bold text-cyan-300 truncate max-w-full">
              <template v-if="activeTab === 'remote-thread'">
                <span v-if="currentStep === 0">OpenProcess() ➔</span>
                <span v-else-if="currentStep === 1">VirtualAllocEx() ➔</span>
                <span v-else-if="currentStep === 2">WriteProcessMemory() ➔</span>
                <span v-else>CreateRemoteThread() ➔</span>
              </template>
              <template v-else>
                <span v-if="currentStep === 0">CreateProcess(SUSPENDED) ➔</span>
                <span v-else-if="currentStep === 1">NtUnmapViewOfSection() ➔</span>
                <span v-else-if="currentStep === 2">VirtualAlloc + WriteMem() ➔</span>
                <span v-else>SetThreadContext + Resume() ➔</span>
              </template>
            </div>
            <div class="h-0.5 w-full bg-gradient-to-r from-transparent via-cyan-400 to-transparent mt-1 animate-pulse"></div>
          </div>

          <!-- Forensic Diagnostic Callout in center -->
          <div class="text-[10px] text-slate-300 font-sans leading-relaxed text-left mt-1">
            <template v-if="activeTab === 'remote-thread'">
              <div v-if="currentStep === 0" class="text-sky-300">
                • Demands <code>PROCESS_ALL_ACCESS</code> rights. Blocked by Protected Processes (PP/PPL).
              </div>
              <div v-if="currentStep === 1" class="text-amber-300">
                • <strong>VAD Leaf Created:</strong> Unbacked private allocation marked <code>PAGE_EXECUTE_READWRITE</code>.
              </div>
              <div v-if="currentStep === 2" class="text-rose-300">
                • Shellcode payload is staged in RAM without hitting the hard drive.
              </div>
              <div v-if="currentStep === 3" class="text-emerald-300">
                • New thread starts at unbacked memory outside any known loaded DLL!
              </div>
            </template>
            <template v-else>
              <div v-if="currentStep === 0" class="text-sky-300">
                • Legitimate host spawned. Image path on disk points to authentic Windows system file.
              </div>
              <div v-if="currentStep === 1" class="text-amber-300">
                • <strong>Hollowed:</strong> Base memory unmapped. VAD shows unmapped gap at image base.
              </div>
              <div v-if="currentStep === 2" class="text-rose-300">
                • Fake PE remapped. Memory headers do not match on-disk file checksums!
              </div>
              <div v-if="currentStep === 3" class="text-emerald-300">
                • Primary thread resumes inside forged memory while PEB still points to authentic svchost.exe!
              </div>
            </template>
          </div>
        </div>

      </div>

      <!-- Right Column: Target / Victim Process Space -->
      <div class="col-span-5 flex flex-col bg-slate-900/80 rounded-lg p-2.5 border border-sky-950/40 shadow-inner">
        <div class="flex items-center justify-between border-b border-sky-900/30 pb-1.5 mb-2">
          <div class="flex items-center gap-1.5">
            <span class="w-2.5 h-2.5 rounded-full" :class="activeTab === 'remote-thread' ? 'bg-sky-400' : 'bg-emerald-400'"></span>
            <span class="font-bold text-xs" :class="activeTab === 'remote-thread' ? 'text-sky-300' : 'text-emerald-300'">
              {{ activeTab === 'remote-thread' ? 'Target (explorer.exe)' : 'Target Host (svchost.exe)' }}
            </span>
          </div>
          <span class="text-[10px] font-mono text-slate-400">
            {{ activeTab === 'remote-thread' ? 'PID: 1420' : 'PID: 884 (Hollowed)' }}
          </span>
        </div>

        <!-- Target Memory Map -->
        <div class="flex flex-col gap-1.5 text-xs font-mono">
          
          <!-- Stack -->
          <div class="mem-block bg-slate-800/60 border border-slate-700/40 text-slate-400">
            <div class="flex items-center justify-between">
              <span>[0x7FFF... Stack]</span>
              <span class="badge-sub">RW</span>
            </div>
            <div v-if="activeTab === 'remote-thread' && currentStep === 3" class="text-[10px] text-emerald-300 font-sans mt-0.5">
              ⚡ New Thread Stack (Dispatched by CreateRemoteThread)
            </div>
          </div>

          <!-- DYNAMIC REGION: Varies by tab & step -->
          <template v-if="activeTab === 'remote-thread'">
            <!-- Injected RWX Block -->
            <div
              v-if="currentStep >= 1"
              class="mem-block transition-all duration-300"
              :class="currentStep >= 2
                ? 'bg-rose-950/90 border-rose-500 text-rose-200 ring-2 ring-rose-500/40'
                : 'bg-amber-950/70 border-amber-500/80 text-amber-200 animate-pulse'"
            >
              <div class="flex items-center justify-between font-bold">
                <span class="flex items-center gap-1">
                  <span v-if="currentStep === 3" class="animate-ping inline-block w-1.5 h-1.5 rounded-full bg-rose-400 mr-0.5"></span>
                  [0x02AB0000] Injected Buffer
                </span>
                <span class="badge-sub bg-rose-900 text-rose-200 font-bold">PAGE_EXECUTE_READWRITE</span>
              </div>
              <div class="text-[10px] font-sans mt-0.5 flex items-center justify-between text-slate-300">
                <span>{{ currentStep === 1 ? 'Committed RWX Memory (Empty)' : 'Malicious Shellcode Active!' }}</span>
                <span v-if="currentStep === 3" class="text-rose-400 font-bold">⚡ Thread EIP ➔ 0x02AB0000</span>
              </div>
            </div>

            <!-- Legitimate DLLs -->
            <div class="mem-block bg-slate-800/60 border border-slate-700/40 text-slate-400">
              <div class="flex items-center justify-between">
                <span>[0x7000... kernel32.dll / ntdll.dll]</span>
                <span class="badge-sub">RX</span>
              </div>
              <div class="text-[10px] text-slate-500 font-sans mt-0.5">Legitimate Loaded Modules</div>
            </div>

            <!-- Original Process Code -->
            <div class="mem-block bg-slate-800/60 border border-slate-700/40 text-slate-400">
              <div class="flex items-center justify-between">
                <span>[0x0040... explorer.exe .text]</span>
                <span class="badge-sub">RX</span>
              </div>
              <div class="text-[10px] text-slate-500 font-sans mt-0.5">Main GUI Loop Thread</div>
            </div>
          </template>

          <template v-else>
            <!-- PROCESS HOLLOWING VIEW -->
            <!-- Image Base Code Section -->
            <div
              class="mem-block transition-all duration-300"
              :class="{
                'bg-slate-800/60 border-slate-700/40 text-slate-400': currentStep === 0,
                'bg-dashed border-2 border-amber-500/70 bg-amber-950/30 text-amber-300': currentStep === 1,
                'bg-rose-950/90 border-rose-500 text-rose-200 ring-2 ring-rose-500/40': currentStep >= 2
              }"
            >
              <div class="flex items-center justify-between font-bold">
                <span>[0x0040... svchost.exe Base]</span>
                <span v-if="currentStep === 0" class="badge-sub">RX (Legit)</span>
                <span v-else-if="currentStep === 1" class="badge-sub bg-amber-900 text-amber-200">HOLLOWED (UNMAPPED)</span>
                <span v-else class="badge-sub bg-rose-900 text-rose-200">MALICIOUS PE (RWX/RX)</span>
              </div>
              <div class="text-[10px] font-sans mt-0.5">
                <span v-if="currentStep === 0">Authentic Microsoft svchost.exe section</span>
                <span v-else-if="currentStep === 1" class="text-amber-300 font-semibold">Unmapped via NtUnmapViewOfSection. Memory address space is hollow!</span>
                <span v-else-if="currentStep === 2" class="text-rose-300">Replacement PE headers & malicious payload written into address space</span>
                <span v-else class="text-emerald-300 font-bold">⚡ Primary Thread Context (RIP) repointed & resumed!</span>
              </div>
            </div>

            <!-- Standard Modules -->
            <div class="mem-block bg-slate-800/60 border border-slate-700/40 text-slate-400">
              <div class="flex items-center justify-between">
                <span>[0x7000... ntdll.dll]</span>
                <span class="badge-sub">RX</span>
              </div>
            </div>

            <!-- PEB (Process Environment Block) -->
            <div class="mem-block bg-slate-800/60 border border-slate-700/40 text-slate-300">
              <div class="flex items-center justify-between">
                <span>[PEB @ 0x7FFDF000]</span>
                <span class="badge-sub">RW</span>
              </div>
              <div class="text-[10px] text-emerald-400 font-sans mt-0.5">
                ProcessParameters ➔ "C:\Windows\System32\svchost.exe" (Deceptive Legitimacy)
              </div>
            </div>
          </template>

        </div>

      </div>

    </div>

    <!-- Bottom Forensic Detection Cue -->
    <div class="mt-2 text-[11px] bg-slate-900/60 border border-slate-800 px-3 py-1.5 rounded-lg flex items-center justify-between text-slate-300">
      <div class="flex items-center gap-2">
        <span class="text-amber-400 font-bold">🔍 Forensic Indicator:</span>
        <span v-if="activeTab === 'remote-thread'">
          Scan target's VAD tree for memory allocations marked <code>PAGE_EXECUTE_READWRITE</code> with <strong>no file backing</strong> (Private Memory).
        </span>
        <span v-else>
          Compare in-memory PE section headers against the on-disk binary in <code>System32</code> (Header mismatch & unbacked memory).
        </span>
      </div>
      <div class="text-cyan-400 font-mono text-[10px] hidden sm:block">
        {{ activeTab === 'remote-thread' ? 'Detection: malfind / ldrmodules' : 'Detection: hollowfind / malfind' }}
      </div>
    </div>
  </div>
</template>

<style scoped>
.mode-btn {
  @apply flex items-center gap-1.5 px-3 py-1 rounded text-xs font-semibold transition-colors duration-150;
  color: #94a3b8;
}
.mode-btn:hover {
  @apply text-slate-100 bg-slate-800/70;
}
.mode-btn.active {
  @apply text-white bg-slate-800 shadow-sm border border-slate-700;
}

.step-pill {
  @apply px-2.5 py-0.5 rounded text-xs font-medium transition-all text-slate-400 bg-slate-900 border border-slate-800;
}
.step-pill:hover {
  @apply text-slate-200 border-slate-700;
}
.step-pill.active {
  @apply text-cyan-300 bg-cyan-950/80 border-cyan-500/70 font-semibold shadow;
}

.nav-btn {
  @apply px-2 py-0.5 rounded text-xs font-medium bg-slate-800 border border-slate-700 hover:bg-slate-700 text-slate-300 transition-colors;
}
.nav-btn:disabled {
  @apply opacity-30 cursor-not-allowed hover:bg-slate-800;
}

.step-banner {
  background: rgba(15, 23, 42, 0.75);
  border: 1px solid rgba(51, 65, 85, 0.6);
}

.badge {
  @apply text-[10px] font-bold px-1.5 py-0.5 rounded uppercase tracking-wider font-mono;
}
.badge.info {
  @apply bg-sky-950 text-sky-400 border border-sky-800/60;
}
.badge.warn {
  @apply bg-amber-950 text-amber-400 border border-amber-800/60;
}
.badge.bad {
  @apply bg-rose-950 text-rose-400 border border-rose-800/60;
}
.badge.good {
  @apply bg-emerald-950 text-emerald-400 border border-emerald-800/60;
}

.mem-block {
  @apply p-1.5 rounded;
}

.badge-sub {
  @apply text-[9px] font-mono px-1 py-0.2 rounded border border-slate-700;
}
</style>

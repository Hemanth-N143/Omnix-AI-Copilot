<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Omnix — AI CoPilot</title>

    <!-- Highlight.js style + libs for markdown and sanitization -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.8.0/styles/github.min.css">
    <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/dompurify@2.4.0/dist/purify.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.8.0/highlight.min.js"></script>

    <style>
        /* ===== GLOBAL ===== */
        * { box-sizing: border-box; }
        :root{
            --bg: #ffffff;
            --muted: #6b7280;
            --accent: #007bff;
            --panel: #f7f7f8;
            --sidebar: #f3f4f6;
        }
        body { font-family: 'Segoe UI', Roboto, Arial, sans-serif; margin:0; height:100vh; color:#111827; background:var(--bg); display:flex; flex-direction:column; }

        /* HEADER */
        header{ height:64px; display:flex; align-items:center; padding:0 20px; border-bottom:1px solid #eef2f7; background:linear-gradient(180deg,#ffffff,#fbfdff); }
        .logo{ display:flex; align-items:center; gap:10px; }
        .mark{ width:36px; height:36px; border-radius:50%; background:linear-gradient(135deg,#e6f0ff,var(--accent)); display:flex; align-items:center; justify-content:center; color:white; box-shadow:0 2px 8px rgba(3,102,214,0.12); }
        .title{ font-weight:700; font-size:18px; color:#0f172a; }
        .header-actions{ margin-left:auto; }
        .sidebar-toggle{ background:none; border:1px solid #e6e9ef; padding:8px 10px; border-radius:8px; cursor:pointer; }

        /* MAIN LAYOUT */
        .main{ flex:1; display:flex; height: calc(100vh - 64px); }

        /* SIDEBAR (hidden by default). Add body.show-sidebar class to show */
        #sidebar{ width:280px; background:var(--sidebar); padding:18px; border-right:1px solid #eef2f7; display:flex; flex-direction:column; gap:12px; box-shadow:4px 0 20px rgba(15,23,42,0.04); }
        body:not(.show-sidebar) #sidebar{ display:none; }
        #sidebar h2{ margin:0; font-size:14px; color:var(--muted); }
        /* sidebar header layout for title + close button */
        .sidebar-header{ display:flex; align-items:center; justify-content:space-between; gap:8px; }
        .sidebar-close{ background:none; border:none; font-size:18px; cursor:pointer; padding:6px 8px; border-radius:6px; color:var(--muted); }
        .sidebar-close:hover{ background:rgba(0,0,0,0.04); }
        #newChatBtn{ background:var(--accent); color:white; padding:10px; border-radius:10px; border:none; cursor:pointer; font-weight:600; }
        #chatList{ margin-top:8px; overflow:auto; }
        .chat-item{ padding:10px 12px; border-radius:10px; display:flex; justify-content:space-between; align-items:center; cursor:pointer; }
        .chat-item:hover{ background:#eef2ff; }
        .chat-item.active{ background: rgba(0,123,255,0.12); color:var(--accent); font-weight:600; }

        /* CHAT AREA */
        #chatContainer{ flex:1; display:flex; flex-direction:column; }
        #messages{ flex:1; overflow-y:auto; padding:32px; background:#fbfdff; }

        /* ====== WELCOME CARD (Modern Omnix Style) ====== */
        #welcome {
          position: absolute;
          left: 60%;
          top: 50%;
          transform: translate(-50%, -50%) scale(1);
          width: 700px;
          max-width: 92vw;
          background: rgba(255, 255, 255, 0.85);
          border-radius: 16px;
          padding: 48px 40px;
          backdrop-filter: blur(12px);
          -webkit-backdrop-filter: blur(12px);
          box-shadow: 0 10px 40px rgba(0, 0, 0, 0.08);
          text-align: center;
          border: 1px solid rgba(255, 255, 255, 0.5);
          animation: fadeInUp 0.7s ease forwards;
        }

        #welcome h1 {
          margin: 0;
          font-size: 32px;
          font-weight: 800;
          letter-spacing: -0.5px;
        }

        #welcome p {
          margin: 12px 0 26px;
          color: #555;
          font-size: 16px;
          line-height: 1.6;
        }

        .welcome-input {
          display: flex;
          gap: 10px;
          align-items: center;
          justify-content: center;
        }

        .welcome-input input {
          flex: 1;
          padding: 14px 18px;
          border-radius: 999px;
          border: 1px solid #e6e9ef;
          font-size: 16px;
          transition: 0.25s ease;
          background: white;
        }

        .welcome-input input:focus {
          box-shadow: 0 0 0 4px rgba(0, 120, 255, 0.12);
          border-color: #0078ff;
          outline: none;
        }

        .welcome-input button {
          background: linear-gradient(90deg, #0078ff, #6a5acd);
          color: white;
          padding: 12px 20px;
          border-radius: 999px;
          border: none;
          font-weight: 600;
          font-size: 15px;
          cursor: pointer;
          transition: all 0.25s ease;
        }

        .welcome-input button:hover {
          background: linear-gradient(90deg, #0063e5, #5941b5);
          transform: translateY(-1px);
        }

        .welcome-input button:disabled {
          opacity: 0.6;
          cursor: not-allowed;
        }

        /* Subtle entry animation */
        @keyframes fadeInUp {
          from {
            opacity: 0;
            transform: translate(-50%, -40%) scale(0.98);
          }
          to {
            opacity: 1;
            transform: translate(-50%, -50%) scale(1);
          }
        }


        /* ===== MESSAGES ===== */
        /* ===== MESSAGES (modern UI style) ===== */
        #messages {
            flex: 1;
            overflow-y: auto;
            padding: 25px 20px;
            display: flex;
            flex-direction: column;
            background: #f7f8fa;
        }

        /* ====== Chat Message Styling (Omnix Clean Style) ====== */
        .message {
          display: flex;
          align-items: flex-end;
          margin: 12px 0;
          max-width: 80%;
        }

        .message.user {
          margin-left: auto;
          flex-direction: row-reverse;
        }

        .message.ai {
          margin-right: auto;
        }

        .avatar {
          width: 36px;
          height: 36px;
          border-radius: 50%;
          display: flex;
          align-items: center;
          justify-content: center;
          font-size: 18px;
          background: #eaeaea;
          margin: 0 8px;
        }

        .avatar.user {
          background: #0078ff;
          color: #fff;
        }

        .bubble {
          padding: 10px 14px;
          border-radius: 18px;
          position: relative;
          font-size: 15px;
          line-height: 1.4;
          word-wrap: break-word;
        }

        .message.user .bubble {
          background-color: #0078ff;
          color: white;
          border-bottom-right-radius: 4px;
        }

        .message.ai .bubble {
          background-color: #ffffff;
          color: #111;
          border-bottom-left-radius: 4px;
          box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }

        .time {
          display: block;
          font-size: 11px;
          opacity: 0.6;
          text-align: right;
          margin-top: 4px;
        }


        /* Fade animation */
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(8px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @keyframes appear{ from{opacity:0; transform:translateY(6px)} to{opacity:1; transform:none} }

        .meta{ display:flex; gap:8px; align-items:center; margin-bottom:8px; }
        .avatar{ width:30px; height:30px; border-radius:50%; display:inline-flex; align-items:center; justify-content:center; font-size:14px; }
        .avatar.ai{ background:#f3f4f6; }
        .avatar.user{ background:linear-gradient(45deg,#0066ff,#00aaff); color:white; }

        #welcome, #messages, #inputArea {
          transition: opacity 0.3s ease, transform 0.3s ease;
        }
        .hidden {
          opacity: 0;
          transform: translateY(10px);
          pointer-events: none;
        }


        /* INPUT AREA */
        #inputArea{ display:flex; gap:8px; padding:18px; border-top:1px solid #eef2f7; }
        #userInput{ flex:1; padding:12px 16px; border-radius:999px; border:1px solid #e6e9ef; }
        #userInput:focus{ box-shadow:0 6px 18px rgba(3,102,214,0.06); border-color:var(--accent); }
        #sendBtn{ background:var(--accent); color:white; border:none; padding:10px 14px; border-radius:10px; font-weight:700; cursor:pointer; }
        #sendBtn:disabled{ opacity:0.6; cursor:not-allowed; }

        /* ===== TOAST ===== */
        #toast {
            position: fixed; bottom: 20px; right: 20px; background: #111; color: #fff;
            padding: 10px 16px; border-radius: 8px; font-size: 14px; display: none;
            z-index: 1000; opacity: 0.9;
        }

        /* ===== Message content improvements ===== */
        .message pre { background: #0b1220; color: #e6edf3; padding: 12px; border-radius: 8px; overflow:auto; position:relative; }
        .message code { font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, 'Roboto Mono', 'Courier New', monospace; font-size: 0.92em; }
        .message.ai p { margin: 0 0 8px 0; }
        .message.ai ul, .message.ai ol { margin: 8px 0 8px 20px; }
        .message.ai strong { font-weight: 700; }
        .message .message-content { white-space: normal; }
        .copy-code {
            position: absolute; top: 8px; right: 8px; background: rgba(0,0,0,0.6); color: #fff; border: none; padding: 6px 8px; border-radius: 6px; cursor: pointer; font-size: 12px;
        }
        .message.ai a { color: #0066cc; text-decoration: underline; }
        .message.ai blockquote { border-left: 4px solid #d0d7de; padding-left: 12px; color:#374151; margin:8px 0; }

        /* ===== Avatars & meta ===== */
        .meta { display:flex; align-items:center; gap:8px; margin-bottom:8px; }
        .avatar { width:28px; height:28px; border-radius:50%; display:inline-flex; align-items:center; justify-content:center; font-size:14px; }
        .avatar.user { background:#0b6; color:#033; }
        .avatar.ai { background:#eef; color:#036; }
        .meta .time { font-size:12px; color:#666; }

        /* ===== Typing indicator ===== */
        .typing-dots { display:inline-block; width:40px; }
        .typing-dots span { display:inline-block; width:8px; height:8px; margin:0 2px; background:#888; border-radius:50%; opacity:0.4; animation: blink 1s infinite; }
        .typing-dots span:nth-child(2){ animation-delay:0.2s; }
        .typing-dots span:nth-child(3){ animation-delay:0.4s; }
        @keyframes blink { 0%{opacity:0.2; transform:translateY(0)}50%{opacity:1; transform:translateY(-4px)}100%{opacity:0.2; transform:translateY(0)} }

        /* small helpers */
        .muted{ color:var(--muted); }

        @media (max-width:900px){ #welcome{ width:92vw; padding:28px } body.show-sidebar #sidebar{ position:absolute; z-index:20; height:calc(100vh - 64px); } }
    </style>
</head>
<body>
<header>
    <div class="logo">
        <div class="mark">🤖</div>
        <div class="title">Omnix</div>
    </div>
    <div class="header-actions">
        <button class="sidebar-toggle" id="sidebarToggle" aria-label="Toggle sidebar">☰ Open Sidebar</button>
    </div>
</header>

<div class="main">
    <!-- Sidebar (hidden by default) -->
    <div id="sidebar">
        <div class="sidebar-header">
            <h2>Your chats</h2>
            <!-- close icon inside sidebar as requested -->
            <button id="sidebarCloseBtn" class="sidebar-close" aria-label="Close sidebar">✕</button>
        </div>
        <!-- New Chat opens the welcome card; session created only after user types and sends -->
        <button id="newChatBtn" onclick="openWelcomeForNewChat()">+ New Chat</button>
        <div id="chatList"></div>
    </div>

    <!-- Chat area -->
    <div id="chatContainer">
        <div id="welcome" style="display:none;">
          <h1>Welcome to Omnix 🤖</h1>
          <p>Ask anything — Omnix is here to guide, code, and create with you.</p>
          <div class="welcome-input">
            <input id="welcomeInput" type="text" placeholder="Ask anything to begin...">
            <button id="welcomeSend" disabled>Start</button>
          </div>
        </div>


        <div id="messages"></div>

        <div id="inputArea">
            <input type="text" id="userInput" placeholder="Message Omnix..." aria-label="Message Omnix" />
            <button id="sendBtn" onclick="sendMessage()" disabled>Send</button>
        </div>
    </div>
</div>

<div id="toast" style="display:none; position:fixed; right:20px; bottom:18px; background:#111; color:#fff; padding:10px 14px; border-radius:10px;"></div>

<script>
// ========== State ==========
let activeSessionId = null;
let justCreatedSessionId = null;
// When true, the next user send will create a new session (used when clicking New Chat)
let pendingNewChat = false;

// ========== Sidebar toggle ==========
const sidebarToggle = document.getElementById('sidebarToggle');
sidebarToggle && sidebarToggle.addEventListener('click', () => {
    document.body.classList.toggle('show-sidebar');
    const shown = document.body.classList.contains('show-sidebar');
    sidebarToggle.textContent = shown ? '✕ Close Sidebar' : '☰ Open Sidebar';
});

// Sidebar close button inside the sidebar header
const sidebarCloseBtn = document.getElementById('sidebarCloseBtn');
sidebarCloseBtn && sidebarCloseBtn.addEventListener('click', () => {
    document.body.classList.remove('show-sidebar');
    sidebarToggle.textContent = '☰ Open Sidebar';
});

// Called when user clicks "New Chat" — show welcome card and wait for user to type.
function openWelcomeForNewChat(){
    pendingNewChat = true;
    showWelcome();
    // ensure sidebar visible so the user sees the chat list while composing
    document.body.classList.add('show-sidebar');
    sidebarToggle.textContent = '✕ Close Sidebar';
    setTimeout(()=>{ const w = document.getElementById('welcomeInput'); if (w) w.focus(); },60);
}

// ========== Init and handlers ==========
document.addEventListener('DOMContentLoaded', async () => {
    console.log('🔍 [DEBUG] Omnix UI initialized');

    // Restore saved active session (if any)
    const saved = localStorage.getItem('activeSessionId');
    if (saved && saved.trim() !== '') activeSessionId = saved;

    // Welcome input wiring
    const welcomeInput = document.getElementById('welcomeInput');
    const welcomeSend = document.getElementById('welcomeSend');
    welcomeInput && welcomeInput.addEventListener('input', () => { welcomeSend.disabled = welcomeInput.value.trim() === ''; });
    welcomeInput && welcomeInput.addEventListener('keypress', (e) => { if (e.key === 'Enter' && !welcomeSend.disabled) welcomeStartChat(); });
    welcomeSend && welcomeSend.addEventListener('click', () => welcomeStartChat());

    // Bottom input wiring
    const userInput = document.getElementById('userInput');
    const sendBtn = document.getElementById('sendBtn');
    userInput && userInput.addEventListener('input', () => { sendBtn.disabled = userInput.value.trim() === ''; });
    userInput && userInput.addEventListener('keypress', (e) => { if (e.key === 'Enter' && !sendBtn.disabled) sendMessage(); });

    await loadChatSessions();
    showWelcome();

    if (activeSessionId) highlightActiveChat(); // highlight last used chat but don’t open
    document.body.classList.add('show-sidebar');
    sidebarToggle.textContent = '✕ Close Sidebar';
});

// ========== Welcome helpers ==========
function showWelcome(){
    // Show welcome card and hide chat area & input while composing
    document.getElementById('welcome').style.display = 'block';
    const msgs = document.getElementById('messages'); if (msgs) msgs.style.display = 'none';
    const inputArea = document.getElementById('inputArea'); if (inputArea) inputArea.style.display = 'none';
}
function hideWelcome(){
    // Hide welcome card and reveal chat area & input
    document.getElementById('welcome').style.display = 'none';
    const msgs = document.getElementById('messages'); if (msgs) msgs.style.display = 'block';
    const inputArea = document.getElementById('inputArea'); if (inputArea) inputArea.style.display = 'flex';
}

async function welcomeStartChat(){
    const val = document.getElementById('welcomeInput').value.trim();
    if (!val) return;
    try{
        // If user opened welcome via New Chat, we create session now
        pendingNewChat = false;
         const id = await createNewChat();
         if (!id) throw new Error('Could not create session');
         document.body.classList.add('show-sidebar');
         sidebarToggle.textContent = '✕ Close Sidebar';
         hideWelcome();
         document.getElementById('userInput').value = val;
         document.getElementById('sendBtn').disabled = false;
         await sendMessage();
         document.getElementById('welcomeInput').value = '';
     }catch(e){ console.error('❌ [DEBUG] Welcome start failed:', e); showToast('Failed to start chat'); }
}

// ========== Load sessions ==========
async function loadChatSessions(){
    const list = document.getElementById('chatList');
    if (!list) return;
    list.innerHTML = '';
    try{
        const res = await fetch('/api/copilot/sessions');
        if (!res.ok) throw new Error(`Failed: ${res.status}`);
        const sessions = await res.json();
        const validSessions = (sessions || []).filter(s => s && s.sessionId);
        if (validSessions.length === 0) { list.innerHTML = '<p class="muted">No chats yet — start a new conversation</p>'; return; }
        validSessions.forEach((s, idx) => addChatToSidebar(s.sessionId, s.title || `Chat ${idx+1}`));
        highlightActiveChat();
    }catch(err){ console.error('❌ [DEBUG] Error loading sessions:', err); showToast('Failed to load chat sessions'); }
}

async function updateSessionTitle(sessionId, newTitle) {
  try {
    const res = await fetch(`/api/copilot/rename/${sessionId}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ title: newTitle })
    });
    if (!res.ok) throw new Error('Failed to rename session');
    console.log(`✅ Session renamed to: ${newTitle}`);
  } catch (err) {
    console.error('❌ Error renaming session:', err);
  }
}


// ========== Sidebar helpers ==========
function addChatToSidebar(sessionId, title){
    const list = document.getElementById('chatList');
    const item = document.createElement('div'); item.className='chat-item'; item.dataset.id = sessionId;
    const span = document.createElement('span'); span.textContent = title; span.style.cursor='pointer';
    span.addEventListener('click', (e)=>{ e.stopPropagation(); selectChat(sessionId); });
    const del = document.createElement('button'); del.textContent='🗑'; del.style.border='none'; del.style.background='transparent'; del.style.cursor='pointer';
    del.addEventListener('click', (e)=>{ e.stopPropagation(); deleteChat(sessionId); });
    item.appendChild(span); item.appendChild(del); item.addEventListener('click', ()=> selectChat(sessionId));
    list.appendChild(item);
}
function highlightActiveChat(){ document.querySelectorAll('.chat-item').forEach(el => el.classList.toggle('active', el.dataset.id === activeSessionId)); }

// ========== Create chat ==========
async function createNewChat(){
    try{
        const res = await fetch('/api/copilot/new', { method:'POST' });
        if (!res.ok) throw new Error(`Create failed: ${res.status}`);
        const data = await res.json();
        activeSessionId = data.sessionId;
        localStorage.setItem('activeSessionId', activeSessionId);
        justCreatedSessionId = activeSessionId;
        await loadChatSessions(); highlightActiveChat();
        clearMessages(); appendAIMessage('New chat started. How can I help?');
        return activeSessionId;
    }catch(err){ console.error('❌ [DEBUG] Error creating chat:', err); showToast('Failed to create chat'); return null; }
}
// ========== Select & load history ==========
async function selectChat(sessionId){
    if (!sessionId) return;
    hideWelcome();
    activeSessionId = sessionId;
    localStorage.setItem('activeSessionId', activeSessionId);
    highlightActiveChat();

    const preserve = (justCreatedSessionId && justCreatedSessionId === sessionId);
    if (!preserve) clearMessages(); else justCreatedSessionId = null;

    try{
        const res = await fetch('/api/copilot/history/' + encodeURIComponent(sessionId));
        if (!res.ok) throw new Error(`Failed to load history: ${res.status}`);
        const messages = await res.json();
        if (!messages || messages.length === 0){
            if (!preserve) appendAIMessage('🕳 No messages yet in this chat.');
            return;
        }

        // ✅ Display oldest first (chronological)
        const ordered = Array.isArray(messages) ? messages.slice() : messages;

        ordered.forEach(m => {
            if ((m.role || '').toLowerCase() === 'user')
                appendUserMessage(m.content);
            else
                appendAIMessage(m.content);
        });

        // ✅ Scroll to bottom automatically
        const container = document.getElementById("messages");
        container.scrollTop = container.scrollHeight;
    }catch(err){
        console.error('❌ [DEBUG] Error loading history:', err);
        showToast('Failed to load history');
    }
}
// ========== Delete chat ==========
async function deleteChat(sessionId){
    if (!sessionId) return showToast('Invalid session');
    try{
        const res = await fetch('/api/copilot/delete/' + encodeURIComponent(sessionId), { method:'DELETE' });
        if (!res.ok) throw new Error(`Delete failed: ${res.status}`);
        if (sessionId === activeSessionId){ clearMessages(); activeSessionId = null; localStorage.removeItem('activeSessionId'); showWelcome(); }
        await loadChatSessions(); showToast('Chat deleted');
    }catch(err){ console.error('❌ [DEBUG] Error deleting chat:', err); showToast('Error deleting chat'); }
}

// ========== Send message ==========
async function sendMessage() {
  const input = document.getElementById('userInput');
  const text = input.value.trim();
  if (!text) return;

  function scrollToBottom(smooth = true) {
    const container = document.getElementById("messages");
    container.scrollTo({
      top: container.scrollHeight,
      behavior: smooth ? "smooth" : "instant"
    });
  }

  // Create new session if none exists
  const creatingNew = !activeSessionId;
  if (creatingNew) {
    const id = await createNewChat();
    if (!id) return showToast('Could not create chat');
    activeSessionId = id;
    document.body.classList.add('show-sidebar');
    sidebarToggle.textContent = '✕ Close Sidebar';
    hideWelcome();
  }

  try {
    appendUserMessage(text);
    input.value = '';
    document.getElementById('sendBtn').disabled = true;
    showTyping();

    const res = await fetch('/api/copilot/chat', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        sessionId: activeSessionId,
        message: text
      })
    });

    hideTyping();
    if (!res.ok) throw new Error(`Chat API failed: ${res.status}`);
    const data = await res.json();
    appendAIMessage(data.reply || '⚠ No response received.');

    // ✅ Rename session only after first real user message
    // ✅ Auto-rename just-created chat with user's first message
    if (justCreatedSessionId) {
      const title = text.length > 35 ? text.substring(0, 35) + '…' : text;
      await updateSessionTitle(justCreatedSessionId, title);
      justCreatedSessionId = null;
    }


    // 🔄 Refresh sidebar list and keep active chat highlighted
    await loadChatSessions();
    highlightActiveChat();
    scrollToBottom();

  } catch (err) {
    hideTyping();
    console.error('❌ [DEBUG] Error sending message:', err);
    appendAIMessage('⚠ Error sending message.');
  }
}

/* ===== Helpers ===== */
function clearMessages() { document.getElementById("messages").innerHTML = ""; }
function appendUserMessage(text) {
    const msg = document.createElement("div");
    msg.className = "message user";

    const avatar = document.createElement("div");
    avatar.className = "avatar user";
    avatar.textContent = "🙂";

    const bubble = document.createElement("div");
    bubble.className = "bubble";
    bubble.textContent = text;

    const time = document.createElement("div");
    time.className = "time";
    time.textContent = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    bubble.appendChild(time);

    msg.appendChild(avatar);
    msg.appendChild(bubble);
    document.getElementById("messages").appendChild(msg);
    msg.scrollIntoView({ behavior: "smooth", block: "end" });
}

function appendAIMessage(text) {
    const msg = document.createElement("div");
    msg.className = "message ai";

    const avatar = document.createElement("div");
    avatar.className = "avatar ai";
    avatar.textContent = "🤖";

    const bubble = document.createElement("div");
    bubble.className = "bubble";

    const html = marked.parse(text || "", { gfm: true, breaks: true });
    bubble.innerHTML = DOMPurify.sanitize(html);

    const time = document.createElement("div");
    time.className = "time";
    time.textContent = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    bubble.appendChild(time);

    msg.appendChild(avatar);
    msg.appendChild(bubble);
    document.getElementById("messages").appendChild(msg);
    msg.scrollIntoView({ behavior: "smooth", block: "end" });
}


// typing indicator helpers
function showTyping() {
    // avoid duplicate
    if (document.querySelector('.message.typing')) return;
    const msg = document.createElement('div'); msg.className = 'message ai typing';
    const meta = document.createElement('div'); meta.className='meta';
    const avatar = document.createElement('div'); avatar.className='avatar ai'; avatar.textContent='🤖';
    const time = document.createElement('div'); time.className='time'; time.textContent='...';
    meta.appendChild(avatar); meta.appendChild(time);
    msg.appendChild(meta);
    const body = document.createElement('div'); body.className='message-content';
    const dots = document.createElement('span'); dots.className='typing-dots'; dots.innerHTML = '<span></span><span></span><span></span>';
    body.appendChild(dots); msg.appendChild(body);
    document.getElementById('messages').appendChild(msg);
    msg.scrollIntoView({behavior:'smooth', block:'end'});
}
function hideTyping() {
    const el = document.querySelector('.message.typing'); if (el) el.remove();
}
function showToast(msg) {
    const toast = document.getElementById("toast");
    toast.textContent = msg;
    toast.style.display = "block";
    setTimeout(() => (toast.style.display = "none"), 2000);
    console.log("🔍DEBUG:", msg);
}
</script>
</body>
</html>

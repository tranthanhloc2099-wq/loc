# tiktok_buff_fixed_render.py - Phiên bản sửa lỗi cho Render
import asyncio
import random
import time
import re
import requests
import socks
import socket
import os
from concurrent.futures import ThreadPoolExecutor, as_completed
from typing import Optional, List, Dict
from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import Application, CommandHandler, CallbackQueryHandler, ContextTypes, MessageHandler, filters
from flask import Flask
from threading import Thread

# ========== FLASK KEEP ALIVE ==========
app_flask = Flask('')

@app_flask.route('/')
def home():
    return "Bot is running!"

def run_flask():
    app_flask.run(host='0.0.0.0', port=8080)

def keep_alive():
    t = Thread(target=run_flask)
    t.start()

# ========== CONFIG ==========
BOT_TOKEN = os.environ.get('BOT_TOKEN', '8885826684:AAHO425Yvs7R7N5owUvYSQcNMx0ltQ6j3Kg')
MAX_WORKERS = 5
TIMEOUT = 10

# ========== PROXY CHECKER ==========
class ProxyChecker:
    @staticmethod
    def check_proxy(proxy: str) -> Dict:
        try:
            proxy = proxy.strip()
            if '://' in proxy:
                proxy = proxy.split('://')[1]
            if ':' not in proxy:
                return {'proxy': proxy, 'alive': False, 'error': 'Invalid format'}
            parts = proxy.split(':')
            ip = parts[0]
            port = int(parts[1])
            sock = socks.socksocket()
            sock.set_proxy(socks.SOCKS5, ip, port)
            sock.settimeout(TIMEOUT)
            start = time.time()
            sock.connect(('8.8.8.8', 53))
            latency = (time.time() - start) * 1000
            sock.close()
            return {'proxy': f"{ip}:{port}", 'alive': True, 'latency': round(latency, 2), 'ip': ip, 'port': port}
        except Exception as e:
            return {'proxy': proxy, 'alive': False, 'error': str(e)[:50]}

# ========== PROXY MANAGER ==========
class ProxyManager:
    def __init__(self):
        self.proxies = []
        self.all_proxies = []
        self.proxy_stats = {}
        self.checker = ProxyChecker()
    
    def add_proxies_from_text(self, text: str) -> List[str]:
        new_proxies = []
        lines = text.strip().split('\n')
        for line in lines:
            proxy = line.strip()
            if proxy and not proxy.startswith('#') and proxy not in self.all_proxies:
                if '://' in proxy:
                    proxy = proxy.split('://')[1]
                if ':' in proxy and len(proxy.split(':')) == 2:
                    self.all_proxies.append(proxy)
                    new_proxies.append(proxy)
        return new_proxies
    
    def check_all_proxies(self, max_workers: int = MAX_WORKERS) -> Dict:
        if not self.all_proxies:
            return {'total': 0, 'alive': 0, 'dead': 0, 'alive_list': []}
        alive_list = []
        dead_list = []
        with ThreadPoolExecutor(max_workers=max_workers) as executor:
            futures = {executor.submit(self.checker.check_proxy, p): p for p in self.all_proxies}
            for future in as_completed(futures):
                result = future.result()
                if result['alive']:
                    alive_list.append(result)
                else:
                    dead_list.append(result)
        self.proxies = [p['proxy'] for p in alive_list]
        for p in alive_list:
            self.proxy_stats[p['proxy']] = {'latency': p['latency'], 'ip': p['ip'], 'port': p['port'], 'success': 0, 'fail': 0}
        return {'total': len(self.all_proxies), 'alive': len(alive_list), 'dead': len(dead_list), 'alive_list': alive_list, 'dead_list': dead_list}
    
    def get_proxy(self) -> Optional[str]:
        if not self.proxies:
            return None
        return random.choice(self.proxies)
    
    def report_result(self, proxy: str, success: bool):
        if proxy in self.proxy_stats:
            if success:
                self.proxy_stats[proxy]['success'] += 1
            else:
                self.proxy_stats[proxy]['fail'] += 1
                if self.proxy_stats[proxy]['fail'] >= 3 and proxy in self.proxies:
                    self.proxies.remove(proxy)
    
    def get_stats(self) -> Dict:
        return {'total': len(self.all_proxies), 'alive': len(self.proxies), 'dead': len(self.all_proxies) - len(self.proxies)}
    
    def clear_all(self):
        self.proxies = []
        self.all_proxies = []
        self.proxy_stats = {}

# ========== TIKTOK REQUEST ==========
def send_request_with_proxy(proxy_ip: str, proxy_port: int, payload: dict) -> Dict:
    try:
        proxies = {'http': f'socks5://{proxy_ip}:{proxy_port}', 'https': f'socks5://{proxy_ip}:{proxy_port}'}
        headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36", "Accept": "application/json"}
        response = requests.post("https://www.tiktok.com/api/v1/item/view", headers=headers, json=payload, proxies=proxies, timeout=15)
        if response.status_code == 200:
            return {'success': True, 'data': response.json()}
        return {'success': False, 'error': f'HTTP {response.status_code}'}
    except Exception as e:
        return {'success': False, 'error': str(e)}

def extract_video_id(url: str) -> str:
    patterns = [r'/video/(\d+)', r'video_id=(\d+)', r'/(\d+)(?:\?|$)']
    for pattern in patterns:
        match = re.search(pattern, url)
        if match:
            return match.group(1)
    return ""

# ========== TELEGRAM BOT ==========
user_states = {}
proxy_manager = ProxyManager()

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    chat_id = update.effective_chat.id
    user_states[chat_id] = {'action': None, 'quantity': 10}
    keyboard = [
        [InlineKeyboardButton("📊 Buff Views", callback_data='buff_views')],
        [InlineKeyboardButton("❤️ Buff Likes", callback_data='buff_likes')],
        [InlineKeyboardButton("🔢 Set Quantity", callback_data='set_quantity')],
        [InlineKeyboardButton("📡 Proxy Status", callback_data='proxy_status')],
        [InlineKeyboardButton("🔍 Check Proxies", callback_data='check_proxies')]
    ]
    stats = proxy_manager.get_stats()
    await update.message.reply_text(
        f"🤖 **TikTok Buff Bot**\n\n📡 Proxy sống: {stats['alive']}/{stats['total']}\n🔢 Số lượng: {user_states[chat_id]['quantity']}\n\n📌 Gửi danh sách proxy dạng IP:PORT (mỗi dòng 1)\nVí dụ: `185.199.97.178:1080`",
        reply_markup=InlineKeyboardMarkup(keyboard),
        parse_mode="Markdown"
    )

async def button_handler(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    await query.answer()
    chat_id = update.effective_chat.id
    if chat_id not in user_states:
        user_states[chat_id] = {'action': None, 'quantity': 10}
    action = query.data
    if action == 'set_quantity':
        await query.edit_message_text("📝 Gửi số lượng (1-100):")
        user_states[chat_id]['action'] = 'awaiting_quantity'
    elif action == 'proxy_status':
        stats = proxy_manager.get_stats()
        text = f"📡 **Proxy Status**\n\n📊 Tổng: {stats['total']}\n✅ Sống: {stats['alive']}\n❌ Chết: {stats['dead']}\n\n"
        if proxy_manager.proxies:
            text += f"🟢 **Proxy đang dùng:**\n"
            for p in proxy_manager.proxies[:10]:
                latency = proxy_manager.proxy_stats.get(p, {}).get('latency', '?')
                text += f"• `{p}` - {latency}ms\n"
        await query.edit_message_text(text, parse_mode="Markdown")
    elif action == 'check_proxies':
        if not proxy_manager.all_proxies:
            await query.edit_message_text("⚠️ Chưa có proxy. Hãy gửi danh sách IP:PORT trước!")
            return
        msg = await query.edit_message_text("🔄 Đang kiểm tra proxy...")
        result = proxy_manager.check_all_proxies()
        text = f"🔍 **Kết quả**\n\n📊 Tổng: {result['total']}\n✅ Sống: {result['alive']}\n❌ Chết: {result['dead']}\n\n"
        if result['alive_list']:
            sorted_alive = sorted(result['alive_list'], key=lambda x: x['latency'])
            for p in sorted_alive[:10]:
                text += f"• `{p['proxy']}` - {p['latency']}ms\n"
        await msg.edit_text(text, parse_mode="Markdown")
    elif action == 'buff_views':
        if not proxy_manager.proxies:
            await query.edit_message_text("❌ Không có proxy sống! Hãy gửi danh sách IP:PORT trước.")
            return
        user_states[chat_id]['action'] = 'awaiting_views_url'
        await query.edit_message_text(f"📹 Gửi link TikTok để buff {user_states[chat_id]['quantity']} views:")
    elif action == 'buff_likes':
        if not proxy_manager.proxies:
            await query.edit_message_text("❌ Không có proxy sống! Hãy gửi danh sách IP:PORT trước.")
            return
        user_states[chat_id]['action'] = 'awaiting_likes_url'
        await query.edit_message_text(f"❤️ Gửi link TikTok để buff {user_states[chat_id]['quantity']} likes:")

async def handle_proxy_list(update: Update, context: ContextTypes.DEFAULT_TYPE):
    text = update.message.text
    new_proxies = proxy_manager.add_proxies_from_text(text)
    if not new_proxies:
        await update.message.reply_text("❌ Không tìm thấy proxy hợp lệ.\n\nĐịnh dạng đúng: `IP:PORT`\nVí dụ: `185.199.97.178:1080`", parse_mode="Markdown")
        return
    await update.message.reply_text(f"✅ Đã thêm {len(new_proxies)} proxy. Đang kiểm tra...")
    result = proxy_manager.check_all_proxies()
    text_result = f"📊 **Kết quả:** ✅ Sống: {result['alive']}/{result['total']}\n\n"
    if result['alive'] > 0:
        for p in result['alive_list'][:10]:
            text_result += f"• `{p['proxy']}` - {p['latency']}ms\n"
        text_result += f"\n💡 Dùng /start để buff!"
    await update.message.reply_text(text_result, parse_mode="Markdown")

async def handle_buff(update: Update, context: ContextTypes.DEFAULT_TYPE, buff_type: str, video_id: str, count: int):
    success_count = 0
    for i in range(count):
        proxy = proxy_manager.get_proxy()
        if not proxy:
            await update.message.reply_text("❌ Hết proxy sống!")
            break
        ip, port = proxy.split(':')
        payload = {"itemId": video_id, "source": "feed"}
        result = send_request_with_proxy(ip, int(port), payload)
        if result['success']:
            success_count += 1
            proxy_manager.report_result(proxy, True)
        else:
            proxy_manager.report_result(proxy, False)
        if (i+1) % 5 == 0 or (i+1) == count:
            await update.message.reply_text(f"📊 Tiến độ: {success_count}/{i+1}")
        await asyncio.sleep(random.uniform(1, 2))
    await update.message.reply_text(f"📊 **Kết quả:** ✅ {success_count}/{count} thành công\n📡 Proxy còn: {len(proxy_manager.proxies)}", parse_mode="Markdown")

async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
    chat_id = update.effective_chat.id
    user_input = update.message.text.strip()
    if chat_id not in user_states:
        user_states[chat_id] = {'action': None, 'quantity': 10}
    state = user_states[chat_id]
    if state['action'] == 'awaiting_quantity':
        try:
            qty = int(user_input)
            if 1 <= qty <= 100:
                state['quantity'] = qty
                state['action'] = None
                await update.message.reply_text(f"✅ Đã đặt số lượng: {qty}")
            else:
                await update.message.reply_text("❌ Số lượng phải từ 1-100. Nhập lại:")
        except ValueError:
            await update.message.reply_text("❌ Vui lòng nhập số. Nhập lại:")
        return
    elif state['action'] == 'awaiting_views_url':
        video_id = extract_video_id(user_input)
        if not video_id:
            await update.message.reply_text("❌ Link TikTok không hợp lệ.")
            return
        count = min(state['quantity'], 50)
        await update.message.reply_text(f"🚀 Đang buff {count} views...")
        await handle_buff(update, context, 'views', video_id, count)
        state['action'] = None
    elif state['action'] == 'awaiting_likes_url':
        video_id = extract_video_id(user_input)
        if not video_id:
            await update.message.reply_text("❌ Link TikTok không hợp lệ.")
            return
        count = min(state['quantity'], 50)
        await update.message.reply_text(f"❤️ Đang buff {count} likes...")
        await handle_buff(update, context, 'likes', video_id, count)
        state['action'] = None
    else:
        lines = user_input.split('\n')
        is_proxy_list = all(':' in line and not line.startswith('/') for line in lines if line.strip())
        if is_proxy_list:
            await handle_proxy_list(update, context)
        else:
            await update.message.reply_text("❌ Gửi /start để xem hướng dẫn")

async def cancel(update: Update, context: ContextTypes.DEFAULT_TYPE):
    chat_id = update.effective_chat.id
    if chat_id in user_states:
        user_states[chat_id]['action'] = None
    await update.message.reply_text("❌ Đã hủy.")

async def clear_proxies(update: Update, context: ContextTypes.DEFAULT_TYPE):
    proxy_manager.clear_all()
    await update.message.reply_text("🗑️ Đã xóa tất cả proxy.")

# ========== MAIN ==========
def main():
    if BOT_TOKEN == "YOUR_BOT_TOKEN_HERE":
        print("⚠️ CHƯA CẤU HÌNH TOKEN! Set environment variable BOT_TOKEN")
        return
    print("🚀 TikTok Buff Bot đang chạy...")
    # Tạo application với các tham số mặc định
    application = Application.builder().token(BOT_TOKEN).build()
    application.add_handler(CommandHandler("start", start))
    application.add_handler(CommandHandler("cancel", cancel))
    application.add_handler(CommandHandler("clear", clear_proxies))
    application.add_handler(CallbackQueryHandler(button_handler))
    application.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_message))
    # Chạy polling với các tham số phù hợp
    application.run_polling(allowed_updates=Update.ALL_TYPES)

if __name__ == "__main__":
    keep_alive()
    main()
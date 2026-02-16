import tkinter as tk
from tkinter import scrolledtext, messagebox, filedialog
import ctypes
import time
import sys
import os
import platform
from ctypes import c_char_p
from threading import Thread
import requests
import importlib
import hashlib

def check_windows_version():
    os_info = platform.uname()
    if os_info.system == "Windows":
        version = float(platform.release())
        if version < 11:
            messagebox.showerror("Compatibility Error", "EternoSploit is only compatible with Windows 11. Please download the legacy version for anything older than Windows 11. Press OK to exit.")
            sys.exit(1)
    else:
        messagebox.showerror("Compatibility Error", "EternoSploit is only compatible with Windows 11. Press OK to exit.")
        sys.exit(1)

check_windows_version()

dll_paths = [
    "wearedevs_exploit_api.dll",
    os.path.join(os.getcwd(), "wearedevs_exploit_api.dll"),
    os.path.join(os.path.dirname(__file__), "wearedevs_exploit_api.dll"),
]

api_dll = None
for dll_path in dll_paths:
    try:
        if os.path.exists(dll_path):
            api_dll = ctypes.CDLL(dll_path)
            break
    except OSError:
        continue

if api_dll is None:
    messagebox.showerror("Error", "wearedevs_exploit_api.dll not found!")
    sys.exit(1)

initialize = api_dll.initialize
initialize.restype = ctypes.c_bool

isAttached = api_dll.isAttached
isAttached.restype = ctypes.c_ubyte

execute = api_dll.execute
execute.argtypes = [ctypes.c_char_p]

attached = False
current_file = None
scripts_folder = None
scripts_list_dict = {}
updates_list = []
last_fixes_hash_file = os.path.join(os.getcwd(), "last_fixes_hash.txt")
last_fixes_hash = None

INFINITE_YIELD_LOADSTRING = "loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()"
OWL_HUB_LOADSTRING = "loadstring(game:HttpGet('https://raw.githubusercontent.com/CriShoux/OwlHub/master/OwlHub.txt'))()"
FTAP_BLOODYV2_LOADSTRING = """loadstring(game:HttpGet("https://raw.githubusercontent.com/BloodyV2/BloodyScript/refs/heads/main/Free",true))()"""
RUHUB_FTAP_LOADSTRING = """local Main = game:HttpGet("https://gitlab.com/cooldawghaha/gitlabswitch/-/raw/main/MainBranch?ref_type=heads")
local Alternate = game:HttpGet("https://gitlab.com/cooldawghaha/gitlabswitch/-/raw/main/AlternateBranch.lua?ref_type=heads")
getgenv().saveconfig = false
loadstring(Main)()"""
RIVALS_LOADSTRING = """loadstring(game:HttpGet("https://raw.githubusercontent.com/endoverdosing/Soluna-API/refs/heads/main/rivals-classic.lua",true))()"""
BROOKHAVEN_LOADSTRING = """loadstring(game:HttpGet("https://raw.githubusercontent.com/diablo0011/BrookhavenRPScript/refs/heads/main/BrookhavenRPScript.Lua"))()"""
DEX_EXPLORER_LOADSTRING = """loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Misc/DexExplorer.lua", true))()"""
SIMPLE_SPY_LOADSTRING = """loadstring(game:HttpGet("https://raw.githubusercontent.com/exxtremestuffs/SimpleSpySource/master/SimpleSpy.lua"))()"""
DARK_HUB_LOADSTRING = """loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomAdamYT/DarkHub/master/Init", true))()"""
VEGA_X_LOADSTRING = """loadstring(game:HttpGet("https://raw.githubusercontent.com/vega-x/vega-x/main/vega-x.lua"))()"""

# Load the last applied fixes hash from a file on startup
def load_last_fixes_hash():
    global last_fixes_hash
    try:
        if os.path.exists(last_fixes_hash_file):
            with open(last_fixes_hash_file, 'r', encoding='utf-8') as f:
                last_fixes_hash = f.read().strip()
        else:
            last_fixes_hash = None
        print(f"Debug: Loaded last fixes hash: {last_fixes_hash}")
    except Exception as e:
        print(f"Debug: Failed to load last fixes hash: {str(e)}")
        last_fixes_hash = None

# Save the last applied fixes hash to a file
def save_last_fixes_hash(new_hash):
    global last_fixes_hash
    try:
        with open(last_fixes_hash_file, 'w', encoding='utf-8') as f:
            f.write(new_hash)
        last_fixes_hash = new_hash
        print(f"Debug: Saved new fixes hash: {new_hash}")
    except Exception as e:
        print(f"Debug: Failed to save last fixes hash: {str(e)}")

# Compute SHA-256 hash of content for comparison
def compute_hash(content):
    try:
        return hashlib.sha256(content.encode('utf-8')).hexdigest()
    except Exception as e:
        print(f"Debug: Hash computation failed: {str(e)}")
        return ""

class AnimatedButton(tk.Button):
    def __init__(self, master, **kwargs):
        super().__init__(master, **kwargs)
        self.original_bg = self['bg']
        self.original_fg = self['fg']
        self.bind("<Enter>", self.on_enter)
        self.bind("<Leave>", self.on_leave)
        self.animation_id = None
        self.alpha = 0

    def on_enter(self, event):
        if self.animation_id:
            self.after_cancel(self.animation_id)
        self.alpha = 0
        self.animate_in()

    def on_leave(self, event):
        if self.animation_id:
            self.after_cancel(self.animation_id)
        self.alpha = 255
        self.animate_out()

    def animate_in(self):
        self.alpha += 25
        if self.alpha >= 255:
            return
        bg_hex = self.original_bg
        self.configure(bg=bg_hex)
        fg_hex = current_theme["highlight"]
        self.configure(fg=fg_hex)
        self.animation_id = self.after(10, self.animate_in)

    def animate_out(self):
        self.alpha -= 25
        if self.alpha <= 0:
            self.configure(bg=self.original_bg, fg=self.original_fg)
            return
        bg_hex = self.original_bg
        fg_hex = self.original_fg
        self.configure(fg=fg_hex)
        self.animation_id = self.after(10, self.animate_out)

def select_scripts_folder():
    global scripts_folder
    folder = filedialog.askdirectory(title="Choose a script folder!")
    if folder:
        scripts_folder = folder
        load_scripts()
        folder_label.config(text=f"Folder: {os.path.basename(folder)}", fg=current_theme["highlight"])

def load_scripts():
    if not scripts_folder:
        messagebox.showwarning("Warning!", "Please choose a folder!")
        return
    scripts_list.delete(0, tk.END)
    scripts_list_dict.clear()
    try:
        for file in os.listdir(scripts_folder):
            if file.endswith('.lua') or file.endswith('.txt'):
                full_path = os.path.join(scripts_folder, file)
                scripts_list.insert(tk.END, file)
                scripts_list_dict[file] = full_path
        if scripts_list_dict:
            messagebox.showinfo("Successful", f"{len(scripts_list_dict)} Scripts loaded.")
        else:
            messagebox.showwarning("Warning!", "No .lua or .txt files found!")
    except Exception as e:
        messagebox.showerror("Warning", str(e))

def load_selected_script():
    selection = scripts_list.curselection()
    if not selection:
        messagebox.showwarning("Warning!", "Please choose a script.")
        return
    script_name = scripts_list.get(selection[0])
    file_path = scripts_list_dict[script_name]
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        script_input.delete("1.0", tk.END)
        script_input.insert("1.0", content)
        root.title(f"EternoSploit - {script_name}")
    except Exception as e:
        messagebox.showerror("Error", f"File cannot be opened: {str(e)}")

def attach_roblox():
    global attached
    if attached:
        messagebox.showinfo("Info", "You're already attached.")
        return
    max_retries = 2
    attempt = 1
    while attempt <= max_retries and not attached:
        if initialize():
            time.sleep(0.2)
            if isAttached() > 0:
                attached = True
                status_label.config(text="Status: ATTACHED", fg=current_theme["highlight"])
                messagebox.showinfo("Successful", f"Successfully attached to Roblox!")
                return
            else:
                if attempt < max_retries:
                    time.sleep(0)
                else:
                    messagebox.showerror("Error", "The API couldn't start!")
                    return
        attempt += 1
    if not attached:
        messagebox.showerror("Error", f"Failed to attach. Please try again and ensure Roblox is running and you're in a game.")

def execute_code():
    global attached
    if not attached:
        messagebox.showerror("Error", "Please attach to Roblox first!")
        return
    code = script_input.get("1.0", tk.END).strip()
    if not code:
        messagebox.showwarning("Error", "Please enter a script!")
        return
    try:
        execute(code.encode('utf-8'))
        messagebox.showinfo("Successful", "Script executed successfully.")
    except Exception as e:
        messagebox.showerror("Error", f"Couldn't execute the script: {str(e)}")

def kill_roblox():
    global attached
    if not attached:
        messagebox.showwarning("Error", "API is not attached to Roblox!")
        return
    if messagebox.askyesno("Error", "Would you like to kill Roblox?"):
        kill_script = b"game:Shutdown()"
        try:
            execute(kill_script)
            attached = False
            status_label.config(text="Status: DISCONNECTED", fg="#ff0000")
        except Exception as e:
            messagebox.showerror("Error", str(e))

def open_file():
    global current_file
    file_path = filedialog.askopenfilename(
        filetypes=[("Lua Files", ".lua"), ("Text Files", ".txt"), ("All Files", ".*")]
    )
    if file_path:
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            script_input.delete("1.0", tk.END)
            script_input.insert("1.0", content)
            current_file = file_path
            root.title(f"EternoSploit - {os.path.basename(file_path)}")
        except Exception as e:
            messagebox.showerror("Error", f"File cannot be opened: {str(e)}")

def save_file():
    global current_file
    code = script_input.get("1.0", tk.END)
    if current_file:
        file_path = current_file
    else:
        file_path = filedialog.asksaveasfilename(
            defaultextension=".lua",
            filetypes=[("Lua Files", ".lua"), ("Text Files", ".txt"), ("All Files", ".*")]
        )
    if file_path:
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(code)
            current_file = file_path
            root.title(f"EternoSploit - {os.path.basename(file_path)}")
            messagebox.showinfo("Successful", "File saved!")
        except Exception as e:
            messagebox.showerror("Error", f"File couldn't be saved: {str(e)}")

def load_and_execute_script(script_name, loadstring):
    global attached
    script_input.delete("1.0", tk.END)
    script_input.insert("1.0", loadstring)
    root.title(f"EternoSploit - 1.4 {script_name}")
    if attached:
        try:
            execute(loadstring.encode('utf-8'))
            messagebox.showinfo("Successful", f"{script_name} script executed.")
        except Exception as e:
            messagebox.showerror("Error", f"Couldn't execute {script_name}: {str(e)}")
    else:
        messagebox.showerror("Error", "Please attach to Roblox first.")

def load_infinite_yield():
    load_and_execute_script("Infinite Yield", INFINITE_YIELD_LOADSTRING)

def load_owl_hub():
    load_and_execute_script("Owl Hub", OWL_HUB_LOADSTRING)

def load_ftap_bloodyv2():
    load_and_execute_script("FTAP BloodyV2", FTAP_BLOODYV2_LOADSTRING)

def load_ruhub_ftap():
    load_and_execute_script("Ruhub FTAP", RUHUB_FTAP_LOADSTRING)

def load_rivals():
    load_and_execute_script("Rivals", RIVALS_LOADSTRING)

def load_brookhaven():
    load_and_execute_script("Brookhaven RP Script", BROOKHAVEN_LOADSTRING)

def load_dex_explorer():
    load_and_execute_script("Dex Explorer", DEX_EXPLORER_LOADSTRING)

def load_simple_spy():
    load_and_execute_script("Simple Spy", SIMPLE_SPY_LOADSTRING)

def load_dark_hub():
    load_and_execute_script("Dark Hub", DARK_HUB_LOADSTRING)

def load_vega_x():
    load_and_execute_script("Vega X", VEGA_X_LOADSTRING)

def check_for_updates():
    global updates_list
    github_updates_url = "https://github.com/HomerSimpson88354/EternoSploit/blob/main/updates.txt?raw=true"
    try:
        response = requests.get(github_updates_url, timeout=10)
        if response.status_code == 200:
            updates_list = response.text.splitlines()
            updates_display.delete("1.0", tk.END)
            for update in updates_list:
                updates_display.insert(tk.END, update + "\n")
            root.title("EternoSploit - Updates")
            messagebox.showinfo("Updates", "Latest updates have been loaded into the updates box!")
        else:
            messagebox.showerror("Error", f"Failed to fetch updates from GitHub. Status code: {response.status_code}")
    except requests.exceptions.RequestException as e:
        messagebox.showerror("Error", f"Could not connect to GitHub for updates: {str(e)}")

def fetch_code_fixes():
    global last_fixes_hash
    print(f"Debug: Current stored hash = {last_fixes_hash}")
    github_fixes_url = "https://raw.githubusercontent.com/HomerSimpson88354/EternoSploit/main/latest_fixes.py"
    local_fixes_path = os.path.join(os.getcwd(), "latest_fixes.py")
    
    try:
        response = requests.get(github_fixes_url, timeout=10)
        if response.status_code == 200:
            new_content = response.text
            new_hash = compute_hash(new_content)
            print(f"Debug: New content hash = {new_hash}")
            if last_fixes_hash is not None and last_fixes_hash == new_hash:
                messagebox.showinfo("Up to Date", "You are already up to date with the latest fixes.")
                print("Debug: Hashes match, no update needed")
                return
            # Content differs or no previous hash, save and proceed to apply
            with open(local_fixes_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            messagebox.showinfo("Update Available", "New code fixes have been detected. Applying updates...")
            print("Debug: New fixes detected, proceeding to apply")
            apply_fixes(local_fixes_path, new_hash)
        else:
            messagebox.showerror("Error", f"Failed to fetch code fixes. Status code: {response.status_code}")
            print(f"Debug: Failed to fetch fixes, status code = {response.status_code}")
    except requests.exceptions.RequestException as e:
        messagebox.showerror("Error", f"Could not connect to GitHub for code fixes: {str(e)}")
        print(f"Debug: Exception during fetch = {str(e)}")

def apply_fixes(fixes_path, new_hash):
    try:
        with open(fixes_path, 'r', encoding='utf-8') as f:
            content = f.read()
        if "requires_restart = True" in content:
            messagebox.showinfo("Restart Required", "Updates downloaded but require a restart. Please close and reopen EternoSploit.")
            print("Debug: Restart required, hash not updated")
        else:
            if "latest_fixes" in sys.modules:
                importlib.reload(sys.modules["latest_fixes"])
            else:
                importlib.import_module("latest_fixes")
            fixes_module = sys.modules.get("latest_fixes")
            if hasattr(fixes_module, "apply_patches"):
                fixes_module.apply_patches()
            # Only update the hash if application is successful and no restart required
            save_last_fixes_hash(new_hash)
            messagebox.showinfo("Success", "Code fixes applied successfully.")
            print(f"Debug: Fixes applied, updated hash to {new_hash}")
    except Exception as e:
        messagebox.showerror("Error", f"Failed to apply code fixes: {str(e)}")
        print(f"Debug: Error during apply = {str(e)}")

themes = {
    "Green": {"bg": "#1a1a1a", "fg": "#0d0d0d", "highlight": "#00ff00"},
    "White": {"bg": "#2a2a2a", "fg": "#1d1d1d", "highlight": "#ffffff"},
    "Red": {"bg": "#2a1a1a", "fg": "#1d0d0d", "highlight": "#ff0000"},
    "Blue": {"bg": "#1a1a2a", "fg": "#0d0d0d", "highlight": "#00aaff"}
}
theme_order = ["Green", "White", "Red", "Blue"]
current_theme_idx = 0
current_theme = themes["Green"]

def apply_theme(theme_name):
    global current_theme
    theme = themes[theme_name]
    current_theme = theme
    root.configure(bg=theme["fg"])
    title_frame.configure(bg=theme["bg"])
    title_label.configure(bg=theme["bg"], fg=theme["highlight"])
    animation_frame.configure(bg=theme["bg"])
    status_frame.configure(bg=theme["bg"])
    status_label.configure(bg=theme["bg"], fg=status_label.cget("fg"))
    main_frame.configure(bg=theme["fg"])
    left_panel.configure(bg=theme["bg"])
    right_panel.configure(bg=theme["fg"])
    updates_panel.configure(bg=theme["bg"])
    left_title.configure(bg=theme["bg"], fg=theme["highlight"])
    folder_label.configure(bg=theme["bg"], fg=folder_label.cget("fg"))
    popular_scripts_label.configure(bg=theme["bg"], fg=theme["highlight"])
    right_title.configure(bg=theme["fg"], fg=theme["highlight"])
    updates_title.configure(bg=theme["bg"], fg=theme["highlight"])
    select_folder_btn.configure(bg=theme["fg"], fg=theme["highlight"])
    load_btn.configure(bg=theme["fg"], fg=theme["highlight"])
    infinite_yield_btn.configure(bg=theme["fg"], fg=theme["highlight"])
    owl_hub_btn.configure(bg=theme["fg"], fg=theme["highlight"])
    bloodyv2_btn.configure(bg=theme["fg"], fg=theme["highlight"])
    ruhub_btn.configure(bg=theme["fg"], fg=theme["highlight"])
    rivals_btn.configure(bg=theme["fg"], fg=theme["highlight"])
    brookhaven_btn.configure(bg=theme["fg"], fg=theme["highlight"])
    dex_explorer_btn.configure(bg=theme["fg"], fg=theme["highlight"])
    simple_spy_btn.configure(bg=theme["fg"], fg=theme["highlight"])
    dark_hub_btn.configure(bg=theme["fg"], fg=theme["highlight"])
    vega_x_btn.configure(bg=theme["fg"], fg=theme["highlight"])
    scripts_list.configure(bg=theme["fg"], fg=theme["highlight"])
    script_input.configure(bg=theme["fg"], fg=theme["highlight"], insertbackground=theme["highlight"])
    updates_display.configure(bg=theme["fg"], fg=theme["highlight"])
    button_frame.configure(bg=theme["fg"])
    attach_btn.configure(bg=theme["bg"], fg=theme["highlight"])
    execute_btn.configure(bg=theme["bg"], fg=theme["highlight"])
    kill_btn.configure(bg=theme["bg"], fg="#ff0000")
    open_btn.configure(bg=theme["bg"], fg=theme["highlight"])
    save_btn.configure(bg=theme["bg"], fg=theme["highlight"])
    settings_btn.configure(bg=theme["bg"], fg=theme["highlight"])
    back_btn.configure(bg=theme["bg"], fg=theme["highlight"])
    check_updates_btn.configure(bg=theme["bg"], fg=theme["highlight"])
    fix_btn.configure(bg=theme["bg"], fg=theme["highlight"])
    if 'settings_panel' in globals():
        settings_panel.configure(bg=theme["bg"])
        settings_title.configure(bg=theme["bg"], fg=theme["highlight"])
        theme_frame.configure(bg=theme["bg"])
        theme_label.configure(bg=theme["bg"], fg=theme["highlight"])
        for btn in theme_buttons:
            btn.configure(bg=theme["fg"], fg=theme["highlight"])
        credits_frame.configure(bg=theme["bg"])
        credits_title.configure(bg=theme["bg"], fg=theme["highlight"])
        for label in credit_labels:
            label.configure(bg=theme["bg"], fg=theme["highlight"])
    all_buttons = [select_folder_btn, load_btn, infinite_yield_btn, owl_hub_btn, bloodyv2_btn, ruhub_btn, rivals_btn, brookhaven_btn,
                   dex_explorer_btn, simple_spy_btn, dark_hub_btn, vega_x_btn,
                   attach_btn, execute_btn, kill_btn, open_btn, save_btn, settings_btn, back_btn, check_updates_btn, fix_btn] + theme_buttons
    for btn in all_buttons:
        btn.original_bg = btn['bg']
        btn.original_fg = btn['fg']

def cycle_theme():
    global current_theme_idx
    current_theme_idx = (current_theme_idx + 1) % len(theme_order)
    current_theme_name = theme_order[current_theme_idx]
    apply_theme(current_theme_name)

def show_settings():
    main_frame.pack_forget()
    settings_panel.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
    settings_btn.pack_forget()
    back_btn.pack(side=tk.LEFT, padx=3)

def show_main():
    settings_panel.pack_forget()
    main_frame.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
    back_btn.pack_forget()
    settings_btn.pack(side=tk.LEFT, padx=3)

root = tk.Tk()
root.title("EternoSploit")
root.geometry("900x700")
root.configure(bg="#0d0d0d")

title_frame = tk.Frame(root, bg="#1a1a1a", height=40)
title_frame.pack(fill=tk.X)
title_frame.pack_propagate(False)

title_label = tk.Label(title_frame, text="EternoSploit", font=("Arial", 12, "bold"), bg="#1a1a1a", fg="#00ff00")
title_label.pack(pady=5)

animation_frame = tk.Frame(title_frame, bg="#1a1a1a")
animation_frame.pack(side=tk.RIGHT, padx=20)

status_frame = tk.Frame(root, bg="#1a1a1a")
status_frame.pack(fill=tk.X, padx=5, pady=2)

status_label = tk.Label(status_frame, text="Status: UNATTACHED", font=("Arial", 8, "bold"), bg="#1a1a1a", fg="#ff0000")
status_label.pack(side=tk.LEFT)

main_frame = tk.Frame(root, bg="#0d0d0d")
main_frame.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)

left_panel = tk.Frame(main_frame, bg="#1a1a1a", width=200)
left_panel.pack(side=tk.LEFT, fill=tk.BOTH, padx=(0, 5))
left_panel.pack_propagate(False)

left_title = tk.Label(left_panel, text="UPLOAD SCRIPTS", font=("Arial", 10, "bold"), bg="#1a1a1a", fg="#ffffff")
left_title.pack(pady=5)

folder_label = tk.Label(left_panel, text="No Folders have been found.", font=("Arial", 8), bg="#1a1a1a", fg="#ff0000")
folder_label.pack(pady=3)

select_folder_btn = AnimatedButton(left_panel, text="Choose a folder", bg="#0d0d0d", fg="#ffffff", command=select_scripts_folder, font=("Arial", 8), width=12)
select_folder_btn.pack(fill=tk.X, padx=3, pady=1)

load_btn = AnimatedButton(left_panel, text="Upload", bg="#0d0d0d", fg="#ffffff", command=load_scripts, font=("Arial", 8), width=12)
load_btn.pack(fill=tk.X, padx=3, pady=1)

popular_scripts_label = tk.Label(left_panel, text="SCRIPTS", font=("Arial", 9, "bold"), bg="#1a1a1a", fg="#ffffff")
popular_scripts_label.pack(pady=5)

infinite_yield_btn = AnimatedButton(left_panel, text="Infinite Yield(All Games)", bg="#0d0d0d", fg="#ffffff", command=load_infinite_yield, font=("Arial", 8), width=12)
infinite_yield_btn.pack(fill=tk.X, padx=3, pady=1)

owl_hub_btn = AnimatedButton(left_panel, text="Owl Hub (All Games)", bg="#0d0d0d", fg="#ffffff", command=load_owl_hub, font=("Arial", 8), width=12)
owl_hub_btn.pack(fill=tk.X, padx=3, pady=1)

bloodyv2_btn = AnimatedButton(left_panel, text="FTAP BloodyV2 (FTAP Game Only)", bg="#0d0d0d", fg="#ffffff", command=lambda: load_and_execute_script("FTAP BloodyV2", FTAP_BLOODYV2_LOADSTRING), font=("Arial", 8), width=12)
bloodyv2_btn.pack(fill=tk.X, padx=3, pady=1)

ruhub_btn = AnimatedButton(left_panel, text="Ruhub FTAP (FTAP Game Only)", bg="#0d0d0d", fg="#ffffff", command=lambda: load_and_execute_script("Ruhub FTAP", RUHUB_FTAP_LOADSTRING), font=("Arial", 8), width=12)
ruhub_btn.pack(fill=tk.X, padx=3, pady=1)

rivals_btn = AnimatedButton(left_panel, text="Soluna (Rivals Only)", bg="#0d0d0d", fg="#ffffff", command=lambda: load_and_execute_script("Rivals", RIVALS_LOADSTRING), font=("Arial", 8), width=12)
rivals_btn.pack(fill=tk.X, padx=3, pady=1)

brookhaven_btn = AnimatedButton(left_panel, text="Diablo0011 (Brookhaven RP Only)", bg="#0d0d0d", fg="#ffffff", command=load_brookhaven, font=("Arial", 8), width=12)
brookhaven_btn.pack(fill=tk.X, padx=3, pady=1)

dex_explorer_btn = AnimatedButton(left_panel, text="Dex Explorer (All Games)", bg="#0d0d0d", fg="#ffffff", command=load_dex_explorer, font=("Arial", 8), width=12)
dex_explorer_btn.pack(fill=tk.X, padx=3, pady=1)

simple_spy_btn = AnimatedButton(left_panel, text="Simple Spy (All Games)", bg="#0d0d0d", fg="#ffffff", command=load_simple_spy, font=("Arial", 8), width=12)
simple_spy_btn.pack(fill=tk.X, padx=3, pady=1)

dark_hub_btn = AnimatedButton(left_panel, text="Dark Hub (Multi Games)", bg="#0d0d0d", fg="#ffffff", command=load_dark_hub, font=("Arial", 8), width=12)
dark_hub_btn.pack(fill=tk.X, padx=3, pady=1)

vega_x_btn = AnimatedButton(left_panel, text="Vega X (Multi Games)", bg="#0d0d0d", fg="#ffffff", command=load_vega_x, font=("Arial", 8), width=12)
vega_x_btn.pack(fill=tk.X, padx=3, pady=1)

scripts_list = tk.Listbox(left_panel, bg="#0d0d0d", fg="#ffffff", selectmode=tk.SINGLE, font=("Arial", 8), highlightthickness=0)
scripts_list.pack(fill=tk.BOTH, expand=True, padx=3, pady=3)
scripts_list.bind('<Double-Button-1>', lambda e: load_selected_script())

right_panel = tk.Frame(main_frame, bg="#0d0d0d")
right_panel.pack(side=tk.RIGHT, fill=tk.BOTH, expand=True)

right_title = tk.Label(right_panel, text="Lua Script Executor", font=("Arial", 10, "bold"), bg="#010101", fg="#ffffff")
right_title.pack(pady=5)

script_input = scrolledtext.ScrolledText(right_panel, bg="#0d0d0d", fg="#ffffff", font=("Courier", 9), insertbackground="#ffffff", height=15)
script_input.pack(fill=tk.BOTH, expand=True, padx=0, pady=(0, 5))

updates_panel = tk.Frame(right_panel, bg="#1a1a1a", height=150)
updates_panel.pack(side=tk.BOTTOM, fill=tk.X, padx=5, pady=5)
updates_panel.pack_propagate(False)

updates_title = tk.Label(updates_panel, text="UPDATES", font=("Arial", 10, "bold"), bg="#1a1a1a", fg="#ffffff")
updates_title.pack(pady=5)

updates_display = scrolledtext.ScrolledText(updates_panel, bg="#0d0d0d", fg="#ffffff", font=("Arial", 9), height=8, wrap=tk.WORD)
updates_display.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
updates_display.configure(state='normal')

button_frame = tk.Frame(root, bg="#0d0d0d")
button_frame.pack(fill=tk.X, padx=5, pady=5, side=tk.BOTTOM)

attach_btn = AnimatedButton(button_frame, text="Attach", bg="#1a1a1a", fg="#ffffff", command=attach_roblox, font=("Arial", 8), width=12)
attach_btn.pack(side=tk.LEFT, padx=3)

execute_btn = AnimatedButton(button_frame, text="Execute", bg="#1a1a1a", fg="#ffffff", command=execute_code, font=("Arial", 8), width=12)
execute_btn.pack(side=tk.LEFT, padx=3)

kill_btn = AnimatedButton(button_frame, text="Kill Roblox", bg="#1a1a1a", fg="#ff0000", command=kill_roblox, font=("Arial", 8), width=12)
kill_btn.pack(side=tk.LEFT, padx=3)

open_btn = AnimatedButton(button_frame, text="Open", bg="#1a1a1a", fg="#ffffff", command=open_file, font=("Arial", 8), width=12)
open_btn.pack(side=tk.LEFT, padx=3)

save_btn = AnimatedButton(button_frame, text="Save", bg="#1a1a1a", fg="#ffffff", command=save_file, font=("Arial", 8), width=12)
save_btn.pack(side=tk.LEFT, padx=3)

check_updates_btn = AnimatedButton(button_frame, text="Check 4 Updates", bg="#1a1a1a", fg="#ffffff", command=check_for_updates, font=("Arial", 8), width=12)
check_updates_btn.pack(side=tk.LEFT, padx=3)

settings_btn = AnimatedButton(button_frame, text="Settings", bg="#1a1a1a", fg="#ffffff", command=show_settings, font=("Arial", 8), width=12)
settings_btn.pack(side=tk.LEFT, padx=3)

fix_btn = AnimatedButton(button_frame, text="Apply Fixes", bg="#1a1a1a", fg="#ffffff", command=fetch_code_fixes, font=("Arial", 8), width=12)
fix_btn.pack(side=tk.LEFT, padx=3)

settings_panel = tk.Frame(root, bg="#1a1a1a")

settings_title = tk.Label(settings_panel, text="SETTINGS", font=("Arial", 12, "bold"), bg="#1a1a1a", fg="#00ff00")
settings_title.pack(pady=10)

theme_frame = tk.Frame(settings_panel, bg="#1a1a1a")
theme_frame.pack(pady=10)

theme_label = tk.Label(theme_frame, text="Choose Theme:", font=("Arial", 10, "bold"), bg="#1a1a1a", fg="#ffffff")
theme_label.pack()

theme_buttons = []
for theme_name in theme_order:
    btn = AnimatedButton(theme_frame, text=theme_name, bg="#0d0d0d", fg="#ffffff", command=lambda t=theme_name: apply_theme(t), font=("Arial", 8), width=12)
    btn.pack(pady=3)
    theme_buttons.append(btn)

credits_frame = tk.Frame(settings_panel, bg="#1a1a1a")
credits_frame.pack(pady=20)

credits_title = tk.Label(credits_frame, text="CREDITS", font=("Arial", 10, "bold"), bg="#1a1a1a", fg="#00ff00")
credits_title.pack()

credit_labels = []
credits = [
    "Created by: Homer, Icey, Virck on discord",
    "API by: wearedevs",
    "Version: 1.3"
]
for credit in credits:
    label = tk.Label(credits_frame, text=credit, font=("Arial", 8), bg="#1a1a1a", fg="#ffffff")
    label.pack()
    credit_labels.append(label)

back_btn = AnimatedButton(button_frame, text="Back", bg="#1a1a1a", fg="#ffffff", command=show_main, font=("Arial", 8), width=12)

def check_for_updates_on_startup():
    def fetch_updates():
        global updates_list
        github_updates_url = "https://github.com/HomerSimpson88354/EternoSploit/blob/main/updates.txt?raw=true"
        try:
            response = requests.get(github_updates_url, timeout=10)
            if response.status_code == 200:
                updates_list = response.text.splitlines()
                updates_display.delete("1.0", tk.END)
                for update in updates_list:
                    updates_display.insert(tk.END, update + "\n")
        except requests.exceptions.RequestException:
            pass
    thread = Thread(target=fetch_updates, daemon=True)
    thread.start()

# Load the last fixes hash at startup
load_last_fixes_hash()
apply_theme("Green")
root.after(500, check_for_updates_on_startup)
root.mainloop()

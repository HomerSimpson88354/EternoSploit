# THIS CODE IS MEANT TO BE KEPT AS IS. ANY FORM OF MODIFICATION / SKIDDING TO THE SCRIPT IS NOT RECOMMENDED, AS IT RUINS WHAT IT ACTUALLY IS FOR.
# REACH OUT TO ANY OF THE DEVS AT https://discord.gg/w62KeAw4hK IF YOU HAVE ANY QUESTIONS ABOUT ADDING FEATURES OR DO ANYTHING. THANK YOU FOR YOUR TIME AND USAGE OF ETERNOSPLOIT.

import tkinter as tk
from tkinter import scrolledtext, messagebox, filedialog
import ctypes, time, sys, os, platform, requests, importlib, hashlib
from ctypes import c_char_p
from threading import Thread
import subprocess

# Currently gotta fix the issue with the script not starting back up after updating for some users.(fixed)

# This is where it detects the dll name and attaches with it.
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
    messagebox.showerror("Error", "wearedevs_exploit_api.dll not found. Make sure the DLL is in the same folder as EternoSploit.")
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

# This is the update memory file function that helps with detecting new code in the repo on github.
last_fixes_hash_file = os.path.join(os.getcwd(), "last_fixes_hash.txt")
last_fixes_hash = None

# These are all of the loadstrings for popular scripts for specific games.
INFINITE_YIELD_LOADSTRING = "loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()"
OWL_HUB_LOADSTRING = "loadstring(game:HttpGet('https://raw.githubusercontent.com/CriShoux/OwlHub/master/OwlHub.txt'))()"
FTAP_BLOODYV2_LOADSTRING = """loadstring(game:HttpGet("https://raw.githubusercontent.com/BloodyV2/BloodyScript/refs/heads/main/Free",true))()"""
RUHUB_FTAP_LOADSTRING = """local Main = game:HttpGet("https://gitlab.com/cooldawghaha/gitlabswitch/-/raw/main/MainBranch?ref_type=heads")
local Alternate = game:HttpGet("https://gitlab.com/cooldawghaha/gitlabswitch/-/raw/main/AlternateBranch.lua?ref_type=heads")
getgenv().saveconfig = false
loadstring(Main)()"""
RIVALS_LOADSTRING = """loadstring(game:HttpGet("https://raw.githubusercontent.com/endoverdosing/Soluna-API/refs/heads/main/rivals-classic.lua",true))()"""
BROOKHAVEN_LOADSTRING = """loadstring(game:HttpGet("https://raw.githubusercontent.com/diablo0011/BrookhavenRPScript/refs/heads/main/BrookhavenRPScript.Lua"))()"""
THABRONX_LOADSTRING = """loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Wave-tb3-90971"))()"""

# This is also a part of the update memory file function.
def load_last_fixes_hash():
    global last_fixes_hash
    try:
        if os.path.exists(last_fixes_hash_file):
            with open(last_fixes_hash_file, 'r', encoding='utf-8') as f:
                last_fixes_hash = f.read().strip()
        else:
            last_fixes_hash = None
    except Exception as e:
        print(f"Debug: Failed to load last fixes hash: {str(e)}")
        last_fixes_hash = None

def save_last_fixes_hash(new_hash):
    global last_fixes_hash
    try:
        with open(last_fixes_hash_file, 'w', encoding='utf-8') as f:
            f.write(new_hash)
        last_fixes_hash = new_hash
        print(f"Debug: Saved new fixes hash: {new_hash}")
    except Exception as e:
        print(f"Debug: Failed to save last fixes hash: {str(e)}")

def compute_hash(content):
    return hashlib.sha256(content.encode('utf-8')).hexdigest()

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
        if not scripts_list_dict:
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
                return
            else:
                if attempt < max_retries:
                    time.sleep(0)
                else:
                    messagebox.showerror("Error", "The API couldn't start. It usually starts on the second attach attempt to fully load itself. Please make sure you join a game and try again.")
                    return
        attempt += 1
    if not attached:
        messagebox.showerror("Error", f"Failed to attach. Please try again and ensure Roblox is running and you're in a game.")
        
# Executes lua code in the executor box.
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
    except Exception as e:
        messagebox.showerror("Error", f"Couldn't execute the script: {str(e)}")
        
# Kills the roblox process.
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
        except Exception as e:
            messagebox.showerror("Error", f"Couldn't execute {script_name}: {str(e)}")
    else:
        messagebox.showerror("Error", "Please attach to Roblox first.")
        
# Second part of the loadstring scripts function.
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

def load_thabronx():
    load_and_execute_script("ThaBronx3", THABRONX_LOADSTRING)

# These are basic exploit loadstring scripts. pretty fancy. 
GITHUB_SCRIPT_URLS = {
    "Aimbot": """loadstring(game:HttpGet("https://raw.githubusercontent.com/HomerSimpson88354/EternoSploit/main/Aimbot.lua?raw=true"))()""",
    "Fly": """loadstring(game:HttpGet("https://raw.githubusercontent.com/HomerSimpson88354/EternoSploit/main/Fly.lua?raw=true"))()""",
    "InfiniteJump": """loadstring(game:HttpGet("https://raw.githubusercontent.com/HomerSimpson88354/EternoSploit/main/InfiniteJump.lua?raw=true"))()""",
    "Noclip": """loadstring(game:HttpGet("https://raw.githubusercontent.com/HomerSimpson88354/EternoSploit/main/Noclip.lua?raw=true"))()""",
    "ESP": """loadstring(game:HttpGet("https://raw.githubusercontent.com/HomerSimpson88354/EternoSploit/main/Esp.lua?raw=true"))()""",
    "Fling": """loadstring(game:HttpGet("https://raw.githubusercontent.com/HomerSimpson88354/EternoSploit/main/Fling.lua?raw=true"))()""",
    "WalkSpeed": """loadstring(game:HttpGet("https://raw.githubusercontent.com/HomerSimpson88354/EternoSploit/main/WalkSpeed.lua?raw=true"))()""",
    "Teleport to Player": """loadstring(game:HttpGet("https://raw.githubusercontent.com/HomerSimpson88354/EternoSploit/main/Teleport.lua?raw=true"))()""",
}

def load_asset_script(script_name):
    global attached
    
    script_loadstring = GITHUB_SCRIPT_URLS.get(script_name)
    if not script_loadstring:
        messagebox.showerror("Error", f"No loadstring configured for script: {script_name}")
        print(f"Debug: No loadstring found for script {script_name} in GITHUB_SCRIPT_URLS")
        return
    
    print(f"Debug: Loading script {script_name} with loadstring")
    try:
        script_input.delete("1.0", tk.END)
        script_input.insert("1.0", script_loadstring)
        root.title(f"EternoSploit - {script_name}")
        if attached:
            execute(script_loadstring.encode('utf-8'))
        else:
            messagebox.showerror("Error", "Please attach to Roblox first.")
        print(f"Debug: Successfully loaded and executed {script_name}")
    except Exception as e:
        messagebox.showerror("Error", f"Failed to load or execute {script_name}: {str(e)}")
        print(f"Debug: General error processing {script_name}: {str(e)}")

def load_aimbot():
    load_asset_script("Aimbot")

def load_fly():
    load_asset_script("Fly")

def load_infinitejump():
    load_asset_script("InfiniteJump")

def load_noclip():
    load_asset_script("Noclip")

def load_esp():
    load_asset_script("ESP")

def load_fling():
    load_asset_script("Fling")

def load_walkspeed():
    load_asset_script("WalkSpeed")

def load_teleport():
    load_asset_script("Teleport to Player")

def debug_assets_folder():
    print(f"Debug: Asset scripts are now loaded from GitHub repository. Local assets folder is not used.")

# Checking for message updates in the box on startup.
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
        else:
            messagebox.showerror("Error", f"Failed to fetch updates from GitHub. Status code: {response.status_code}")
    except requests.exceptions.RequestException as e:
        messagebox.showerror("Error", f"Could not connect to GitHub for updates: {str(e)}")

def fetch_code_fixes():
    global last_fixes_hash
    print(f"Debug: Current stored hash = {last_fixes_hash}")
    github_fixes_url = "https://github.com/HomerSimpson88354/EternoSploit/blob/main/latest_fixes.py?raw=true"
    current_script_path = os.path.abspath(sys.argv[0])
    
    try:
        response = requests.get(github_fixes_url, timeout=10)
        if response.status_code == 200:
            new_content = response.text
            new_hash = compute_hash(new_content)
            print(f"Debug: New content hash = {new_hash}")
            if last_fixes_hash == new_hash:
                messagebox.showinfo("Up to Date", "You are already up to date with the latest version.")
                print("Debug: Hashes match, no update needed")
                return
            
            with open(current_script_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            save_last_fixes_hash(new_hash)
            messagebox.showinfo("Update Applied", "New version downloaded. Please reopen EternoSploit to apply changes.")
            print("Debug: Script overwritten with new content, restarting EternoSploit")
            restart_application()
        else:
            messagebox.showerror("Error", f"Failed to fetch code fixes. Status code: {response.status_code}")
            print(f"Debug: Failed to fetch fixes, status code = {response.status_code}")
    except requests.exceptions.RequestException as e:
        messagebox.showerror("Error", f"Could not connect to GitHub for code fixes: {str(e)}")
        print(f"Debug: Exception during fetch = {str(e)}")
    except Exception as e:
        messagebox.showerror("Error", f"Failed to apply update: {str(e)}")
        print(f"Debug: Error during script overwrite = {str(e)}")

def restart_application():
    try:
        python = sys.executable if sys.executable else "python"
        script = os.path.abspath(sys.argv[0])
        args = sys.argv[1:]
        cmd = [python, script] + args
        print(f"Debug: Restarting with command: {cmd}")
       
        subprocess.Popen(
            cmd,
            cwd=os.getcwd(),
            creationflags=subprocess.DETACHED_PROCESS | subprocess.CREATE_NEW_PROCESS_GROUP if platform.system() == "Windows" else 0,
            close_fds=True,
            shell=False
        )
        # Added small delay to ensure the new process starts before exiting as it wasn't before.
        time.sleep(1)
        print("Debug: New instance launched, terminating current process.")
    
        sys.exit(0)
    except Exception as e:
        error_msg = f"Failed to restart application: {str(e)}"
        messagebox.showerror("Error", error_msg)
        print(f"Debug: Restart failed: {error_msg}")
        
# Mostly just themes and stuff, semi fancy I guess.
themes = {
    "Green": {"bg": "#1a1a1a", "fg": "#0d0d0d", "highlight": "#00ff00"},
    "White": {"bg": "#2a2a2a", "fg": "#1d1d1d", "highlight": "#ffffff"},
    "Red": {"bg": "#2a1a1a", "fg": "#1d0d0d", "highlight": "#ff0000"},
    "Blue": {"bg": "#1a1a2a", "fg": "#0d0d0d", "highlight": "#00aaff"}
}
theme_order = ["Green", "White", "Red", "Blue"]
current_theme_idx = 0
current_theme = themes["White"]

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
    asset_scripts_label.configure(bg=theme["bg"], fg=theme["highlight"])
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
    thabronx_btn.configure(bg=theme["fg"], fg=theme["highlight"])
    aimbot_btn.configure(bg=theme["fg"], fg=theme["highlight"])
    fly_btn.configure(bg=theme["fg"], fg=theme["highlight"])
    infinitejump_btn.configure(bg=theme["fg"], fg=theme["highlight"])
    noclip_btn.configure(bg=theme["fg"], fg=theme["highlight"])
    esp_btn.configure(bg=theme["fg"], fg=theme["highlight"])
    fling_btn.configure(bg=theme["fg"], fg=theme["highlight"])
    walkspeed_btn.configure(bg=theme["fg"], fg=theme["highlight"])
    teleport_btn.configure(bg=theme["fg"], fg=theme["highlight"])
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

    all_buttons = [select_folder_btn, load_btn, infinite_yield_btn, owl_hub_btn, bloodyv2_btn, ruhub_btn, rivals_btn, brookhaven_btn, thabronx_btn, 
                   aimbot_btn, fly_btn, infinitejump_btn, noclip_btn, esp_btn, fling_btn, walkspeed_btn, teleport_btn, attach_btn, execute_btn, kill_btn, open_btn, save_btn, settings_btn, 
                   back_btn, check_updates_btn, fix_btn] + theme_buttons

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
    back_btn.pack(side=tk.LEFT, padx=3, before=fix_btn)

def show_main():
    settings_panel.pack_forget()
    main_frame.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
    
    back_btn.pack_forget()
    settings_btn.pack(side=tk.LEFT, padx=3, before=fix_btn)

# GUI functions are here.
root = tk.Tk()
root.attributes('-topmost', True)  
root.title("EternoSploit")
root.geometry("900x725")
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

left_panel = tk.Frame(main_frame, bg="#1a1a1a", width=240) 
left_panel.pack(side=tk.LEFT, fill=tk.BOTH, padx=(0, 5))
left_panel.pack_propagate(False)

left_title = tk.Label(left_panel, text="UPLOAD SCRIPTS", font=("Arial", 10, "bold"), bg="#1a1a1a", fg="#ffffff")
left_title.pack(pady=5)

folder_label = tk.Label(left_panel, text="No Folders have been found.", font=("Arial", 8), bg="#1a1a1a", fg="#ff0000")
folder_label.pack(pady=3)

select_folder_btn = AnimatedButton(left_panel, text="Choose a folder", bg="#0d0d0d", fg="#ffffff", command=select_scripts_folder, font=("Arial", 8), width=12)
select_folder_btn.pack(fill=tk.X, padx=5, pady=2)

load_btn = AnimatedButton(left_panel, text="Upload", bg="#0d0d0d", fg="#ffffff", command=load_scripts, font=("Arial", 8), width=12)
load_btn.pack(fill=tk.X, padx=5, pady=2)

popular_scripts_label = tk.Label(left_panel, text="POPULAR SCRIPTS", font=("Arial", 9, "bold"), bg="#1a1a1a", fg="#ffffff")
popular_scripts_label.pack(pady=5)

infinite_yield_btn = AnimatedButton(left_panel, text="Infinite Yield(All Games)", bg="#0d0d0d", fg="#ffffff", command=load_infinite_yield, font=("Arial", 8), width=12)
infinite_yield_btn.pack(fill=tk.X, padx=5, pady=2)

owl_hub_btn = AnimatedButton(left_panel, text="Owl Hub (All Games)", bg="#0d0d0d", fg="#ffffff", command=load_owl_hub, font=("Arial", 8), width=12)
owl_hub_btn.pack(fill=tk.X, padx=5, pady=2)

bloodyv2_btn = AnimatedButton(left_panel, text="FTAP BloodyV2 (FTAP Game Only)", bg="#0d0d0d", fg="#ffffff", command=lambda: load_and_execute_script("FTAP BloodyV2", FTAP_BLOODYV2_LOADSTRING), font=("Arial", 8), width=12)
bloodyv2_btn.pack(fill=tk.X, padx=5, pady=2)

ruhub_btn = AnimatedButton(left_panel, text="Ruhub FTAP (FTAP Game Only)", bg="#0d0d0d", fg="#ffffff", command=lambda: load_and_execute_script("Ruhub FTAP", RUHUB_FTAP_LOADSTRING), font=("Arial", 8), width=12)
ruhub_btn.pack(fill=tk.X, padx=5, pady=2)

rivals_btn = AnimatedButton(left_panel, text="Soluna (Rivals Only)", bg="#0d0d0d", fg="#ffffff", command=lambda: load_and_execute_script("Rivals", RIVALS_LOADSTRING), font=("Arial", 8), width=12)
rivals_btn.pack(fill=tk.X, padx=5, pady=2)

brookhaven_btn = AnimatedButton(left_panel, text="Diablo0011 (Brookhaven RP Only)", bg="#0d0d0d", fg="#ffffff", command=load_brookhaven, font=("Arial", 8), width=12)
brookhaven_btn.pack(fill=tk.X, padx=5, pady=2)

thabronx_btn = AnimatedButton(left_panel, text="TheBronx (Universal)", bg="#0d0d0d", fg="#ffffff", command=load_thabronx, font=("Arial", 8), width=12)
thabronx_btn.pack(fill=tk.X, padx=5, pady=2)

asset_scripts_label = tk.Label(left_panel, text="ASSET SCRIPTS", font=("Arial", 9, "bold"), bg="#1a1a1a", fg="#ffffff")
asset_scripts_label.pack(pady=5)

aimbot_btn = AnimatedButton(left_panel, text="Aimbot", bg="#0d0d0d", fg="#ffffff", command=load_aimbot, font=("Arial", 8), width=12)
aimbot_btn.pack(fill=tk.X, padx=5, pady=2)

fly_btn = AnimatedButton(left_panel, text="Fly", bg="#0d0d0d", fg="#ffffff", command=load_fly, font=("Arial", 8), width=12)
fly_btn.pack(fill=tk.X, padx=5, pady=2)

infinitejump_btn = AnimatedButton(left_panel, text="InfiniteJump", bg="#0d0d0d", fg="#ffffff", command=load_infinitejump, font=("Arial", 8), width=12)
infinitejump_btn.pack(fill=tk.X, padx=5, pady=2)

noclip_btn = AnimatedButton(left_panel, text="Noclip", bg="#0d0d0d", fg="#ffffff", command=load_noclip, font=("Arial", 8), width=12)
noclip_btn.pack(fill=tk.X, padx=5, pady=2)

esp_btn = AnimatedButton(left_panel, text="ESP", bg="#0d0d0d", fg="#ffffff", command=load_esp, font=("Arial", 8), width=12)
esp_btn.pack(fill=tk.X, padx=5, pady=2)

fling_btn = AnimatedButton(left_panel, text="Fling", bg="#0d0d0d", fg="#ffffff", command=load_fling, font=("Arial", 8), width=12)
fling_btn.pack(fill=tk.X, padx=5, pady=2)

walkspeed_btn = AnimatedButton(left_panel, text="WalkSpeed", bg="#0d0d0d", fg="#ffffff", command=load_walkspeed, font=("Arial", 8), width=12)
walkspeed_btn.pack(fill=tk.X, padx=5, pady=2)

teleport_btn = AnimatedButton(left_panel, text="Teleport to Player", bg="#0d0d0d", fg="#ffffff", command=load_teleport, font=("Arial", 8), width=12)
teleport_btn.pack(fill=tk.X, padx=5, pady=2)
print("Debug: Teleport to Player button packed and should be visible.")

scripts_list = tk.Listbox(left_panel, bg="#0d0d0d", fg="#ffffff", selectmode=tk.SINGLE, font=("Arial", 8), highlightthickness=0)
scripts_list.pack(fill=tk.BOTH, expand=True, padx=5, pady=3)
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

fix_btn = AnimatedButton(button_frame, text="Load Updates", bg="#1a1a1a", fg="#ffffff", command=fetch_code_fixes, font=("Arial", 8), width=12)
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
    "Menu / Executor Created by: Homer, Icey, Jay, Virck at https://discord.gg/ZxXAGrrBPh",
    "API by: wearedevs",
    "Version: 1.4"
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

load_last_fixes_hash()
apply_theme("Blue")
root.after(500, check_for_updates_on_startup)
debug_assets_folder()
root.mainloop()

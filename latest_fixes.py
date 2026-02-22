# THIS CODE IS MEANT TO BE KEPT AS IS. ANY FORM OF MODIFICATION TO THE SCRIPT IS NOT RECOMMENDED, AS IT RUINS WHAT IT ACTUALLY IS FOR.
# REACH OUT TO ANY OF THE DEVS AT https://discord.gg/w62KeAw4hK IF YOU HAVE ANY QUESTIONS.

import tkinter as tk
from tkinter import scrolledtext, messagebox, filedialog
import ctypes, time, sys, os, platform, requests, importlib, hashlib
from ctypes import c_char_p
from threading import Thread
import subprocess
import customtkinter as ctk

# Loads Api Bootstrap
__BOOTSTRAP = None

# Setting up the customtkinter appearance and theme
ctk.set_appearance_mode("Dark")
ctk.set_default_color_theme("dark-blue")

# Currently gotta fix the issue with the script not starting back up after updating for some users (fixed)

# This is where it detects the dll name and attaches with it
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

# This is the update memory file function that helps with detecting new code in the repo on github
last_fixes_hash_file = os.path.join(os.getcwd(), "last_fixes_hash.txt")
last_fixes_hash = None

# These are all of the loadstrings for popular scripts for specific games
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

# This is also a part of the update memory file function
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

def select_scripts_folder():
    global scripts_folder
    folder = filedialog.askdirectory(title="Choose a script folder!")
    if folder:
        scripts_folder = folder
        load_scripts()
        folder_label.configure(text=f"Folder: {os.path.basename(folder)}", text_color=current_text_color)

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
                status_label.configure(text="Status: ATTACHED", text_color="#00ff00")
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

# Executes lua code in the executor box
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

# Kills the roblox process
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
            status_label.configure(text="Status: DISCONNECTED", text_color="#ff0000")
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

def verify():
    ctk.set_appearance_mode("Dark")
    ctk.set_default_color_theme("dark-blue")

    global __BOOTSTRAP
    __BOOTSTRAP = object()

    root = ctk.CTk()
    root.title("EternoSploit - Key System")
    root.geometry("620x320")
    root.resizable(False, False)

    ctk.CTkLabel(
        root,
        text="Enter Access Key Here" \
             "\n(If you are having trouble finding the key, please go to discord.gg/w62KeAw4hK.)",
        font=("Arial", 16, "bold")
    ).pack(pady=(25, 10))

    k3yvar = ctk.StringVar()

    entry = ctk.CTkEntry(
        root,
        textvariable=k3yvar,
        font=("Arial", 12),
        width=250,
        show=""
    )
    entry.pack(pady=5)
    entry.focus()

    global INTEGRITY_OK
    INTEGRITY_OK = True

    error_label = ctk.CTkLabel(
        root,
        text="",
        font=("Arial", 10),
        text_color="red"
    )
    error_label.pack(pady=5)

    def on_close():
        sys.exit(1)

    root.protocol("WM_DELETE_WINDOW", on_close)

    def submit():
        k3y = k3yvar.get().strip()

        if not k3y:
            error_label.configure(text="This cannot be empty.")
            return

        try:
            r = requests.get(
                "https://github.com/HomerSimpson88354/EternoSploit/blob/main/k3ys.txt?raw=true",
                timeout=10
            )

            if r.status_code != 200:
                error_label.configure(text="Key server unavailable.")
                root.after(2000, lambda: sys.exit(1))
                return

            valid_k3ys = r.text.splitlines()

            if k3y not in valid_k3ys:
                error_label.configure(text="Invalid, please try again")
                return

            global INTEGRITY_OK
            INTEGRITY_OK = True
            root.destroy()
            global _KEY_PASSED
            _KEY_PASSED = True
            root.destroy()

        except Exception:
            error_label.configure(text="Verification failed.")
            root.after(2000, lambda: sys.exit(1))

    ctk.CTkButton(
        root,
        text="Submit",
        font=("Arial", 12),
        command=submit,
        width=120
    ).pack(pady=10)

    root.mainloop()

# CALL THE KEY VERIFICATION FUNCTION BEFORE ANYTHING ELSE TO PREVENT UNAUTHORIZED ACCESS TO THE SCRIPT
verify()
if not globals().get("_KEY_PASSED", False):
    os._exit(1)

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
    root.title(f"EternoSploit - {script_name}")
    if attached:
        try:
            execute(loadstring.encode('utf-8'))
        except Exception as e:
            messagebox.showerror("Error", f"Couldn't execute {script_name}: {str(e)}")
    else:
        messagebox.showerror("Error", "Please attach to Roblox first.")

# Second part of the loadstring scripts function
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

# These are basic exploit loadstring scripts, pretty fancy i guess lmao
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
    load_guard()
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
    load_guard()
    load_asset_script("Fly")

def load_infinitejump():
    load_asset_script("InfiniteJump")

def load_noclip():
    load_asset_script("Noclip")

def load_esp():
    load_asset_script("ESP")

def load_fling():
    load_asset_script("Fling")

def load_guard():
    try:
        if not _KEY_PASSED:
            os._exit(1)
    except:
        os._exit(1)

def load_walkspeed():
    load_asset_script("WalkSpeed")

def load_teleport():
    load_asset_script("Teleport to Player")

def debug_assets_folder():
    print(f"Debug: Asset scripts are now loaded from GitHub repository. Local assets folder is not used.")

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
            updates_display.configure(state="disabled")  
            root.title("EternoSploit")
        else:
            messagebox.showerror("Error", f"Failed to fetch updates from GitHub. Status code: {response.status_code}")
    except requests.exceptions.RequestException as e:
        messagebox.showerror("Error", f"Could not connect to GitHub for updates: {str(e)}")

def fetch_code_fixes():
    load_guard()
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
    load_guard()
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
        time.sleep(1)
        print("Debug: New instance launched, terminating current process.")
        sys.exit(0)
    except Exception as e:
        error_msg = f"Failed to restart application: {str(e)}"
        messagebox.showerror("Error", error_msg)
        print(f"Debug: Restart failed: {error_msg}")

def toggle_settings():
    load_guard()
    if settings_btn.cget("text") == "Settings":
        main_frame.pack_forget()
        settings_panel.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        settings_btn.configure(text="Back")
    else:
        settings_panel.pack_forget()
        main_frame.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        settings_btn.configure(text="Settings")

def show_settings():
    load_guard()
    main_frame.pack_forget()
    settings_panel.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
    settings_btn.configure(text="Back")

def show_main():
    load_guard()
    settings_panel.pack_forget()
    main_frame.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
    settings_btn.configure(text="Settings")

current_bg_color = "#2a2a3a"
current_sidebar_color = "#1e1e2e"
current_text_color = "#99ccff"  
current_btn_color = "#3a3a4a"
current_btn_hover_color = "#4a4a5a"
current_executor_shade = "#2a3a4a"

def change_theme(theme):
    load_guard()
    if theme == "White":
        ctk.set_appearance_mode("Light")
        ctk.set_default_color_theme("blue")
        bg_color = "#e0e0e0"
        sidebar_color = "#d0d0d0"
        btn_base_color = "#b0b0b0"
        btn_hover_color = "#a0a0a0"
        text_color = "#333333"
        executor_shade = "#c0c0c0"
    else:
        ctk.set_appearance_mode("Dark")
        color_map = {
            "Red": {
                "bg": "#3a2a2a",
                "sidebar": "#4a2a2a",
                "btn": "#5a2a2a",
                "hover": "#6a3a3a",
                "text": "#ff9999",
                "executor": "#5a3a3a"
            },
            "Blue": {
                "bg": "#2a3a4a",
                "sidebar": "#2a4a5a",
                "btn": "#3a4a6a",
                "hover": "#4a5a7a",
                "text": "#99ccff",
                "executor": "#3a5a6a"
            },
            "Green": {
                "bg": "#2a4a3a",
                "sidebar": "#2a5a3a",
                "btn": "#3a6a4a",
                "hover": "#4a7a5a",
                "text": "#99ff99",
                "executor": "#3a6a5a"
            }
        }
        theme_colors = color_map.get(theme, {
            "bg": "#2a2a3a",
            "sidebar": "#1e1e2e",
            "btn": "#3a3a4a",
            "hover": "#4a4a5a",
            "text": "#cccccc",
            "executor": "#2a3a4a"
        })
        bg_color = theme_colors["bg"]
        sidebar_color = theme_colors["sidebar"]
        btn_base_color = theme_colors["btn"]
        btn_hover_color = theme_colors["hover"]
        text_color = theme_colors["text"]
        executor_shade = theme_colors["executor"]
        ctk.set_default_color_theme("dark-blue")
    global current_bg_color, current_sidebar_color, current_text_color, current_btn_color, current_btn_hover_color, current_executor_shade
    current_bg_color = bg_color
    current_sidebar_color = sidebar_color
    current_text_color = text_color
    current_btn_color = btn_base_color
    current_btn_hover_color = btn_hover_color
    current_executor_shade = executor_shade
    top_frame.configure(fg_color=bg_color)
    top_right_buttons_frame.configure(fg_color=bg_color)
    main_frame.configure(fg_color=bg_color)
    sidebar.configure(fg_color=sidebar_color)
    popular_frame.configure(fg_color=sidebar_color)  
    asset_frame.configure(fg_color=sidebar_color)    
    popular_scroll.configure(fg_color=sidebar_color) 
    asset_scroll.configure(fg_color=sidebar_color)   
    right_panel.configure(fg_color=sidebar_color)
    button_frame.configure(fg_color=bg_color)
    updates_frame.configure(fg_color=bg_color, border_color=text_color)
    settings_panel.configure(fg_color=bg_color)
    theme_buttons_frame.configure(fg_color=bg_color)
    credits_frame.configure(fg_color=executor_shade) 
    script_input.configure(fg_color=executor_shade, text_color="#333333" if theme == "White" else "white")
    line_numbers.configure(fg_color=executor_shade, text_color="#333333" if theme == "White" else "gray")
    updates_display.configure(fg_color=executor_shade, text_color="#333333" if theme == "White" else "white")
    credits_text.configure(fg_color=executor_shade, text_color="#333333" if theme == "White" else text_color)
    scripts_list.configure(bg=sidebar_color, fg="#333333" if theme == "White" else "white", selectbackground=btn_base_color)
    eterno_label.configure(text_color=text_color)
    popular_label.configure(text_color=text_color)
    asset_label.configure(text_color=text_color)
    upload_label.configure(text_color=text_color)
    updates_label.configure(text_color=text_color)
    editor_label.configure(text_color=text_color)
    settings_label.configure(text_color=text_color)
    theme_label.configure(text_color=text_color)
    credits_label.configure(text_color=text_color)
    folder_label.configure(text_color=text_color)
    status_label.configure(text_color="#00ff00" if attached else "#ff0000")
    for widget in top_frame.winfo_children():
        if isinstance(widget, ctk.CTkLabel):
            widget.configure(text_color=text_color)
    for widget in sidebar.winfo_children():
        if isinstance(widget, ctk.CTkLabel):
            widget.configure(text_color=text_color)
    for widget in popular_frame.winfo_children():
        if isinstance(widget, ctk.CTkLabel):
            widget.configure(text_color=text_color)
    for widget in asset_frame.winfo_children():
        if isinstance(widget, ctk.CTkLabel):
            widget.configure(text_color=text_color)
    for widget in updates_frame.winfo_children():
        if isinstance(widget, ctk.CTkLabel):
            widget.configure(text_color=text_color)
    for widget in right_panel.winfo_children():
        if isinstance(widget, ctk.CTkLabel):
            widget.configure(text_color=text_color)
    for widget in settings_panel.winfo_children():
        if isinstance(widget, ctk.CTkLabel):
            widget.configure(text_color=text_color)
    for widget in button_frame.winfo_children():
        if isinstance(widget, ctk.CTkButton):
            widget.configure(text_color=text_color, fg_color=btn_base_color if widget.cget("text") != "Kill Roblox" else "#ff3333", hover_color=btn_hover_color if widget.cget("text") != "Kill Roblox" else "#ff4444")
    for widget in theme_buttons_frame.winfo_children():
        if isinstance(widget, ctk.CTkButton):
            widget.configure(text_color=text_color, fg_color=btn_base_color, hover_color=btn_hover_color)
    for widget in sidebar.winfo_children():
        if isinstance(widget, ctk.CTkButton):
            widget.configure(text_color=text_color, fg_color=btn_base_color, hover_color=btn_hover_color)
    update_btn.configure(text_color=text_color, fg_color=btn_base_color, hover_color=btn_hover_color)
    settings_btn.configure(text_color=text_color, fg_color=btn_base_color, hover_color=btn_hover_color)
    for widget in popular_scroll.winfo_children():
        if isinstance(widget, ctk.CTkButton):
            widget.configure(text_color=text_color, fg_color=btn_base_color, hover_color=btn_hover_color)
    for widget in asset_scroll.winfo_children():
        if isinstance(widget, ctk.CTkButton):
            widget.configure(text_color=text_color, fg_color=btn_base_color, hover_color=btn_hover_color)
    root.title("EternoSploit")

root = ctk.CTk()
root.title("EternoSploit")
root.geometry("1000x750")
root.resizable(True, True)


root.attributes('-topmost', True)

top_frame = ctk.CTkFrame(root, height=50, corner_radius=10, fg_color="#2a3a4a")
top_frame.pack(fill=tk.X, padx=10, pady=5)
top_frame.pack_propagate(False)
eterno_label = ctk.CTkLabel(top_frame, text="EternoSploit v1.5", font=("Arial", 18, "bold"), text_color="#99ccff")
eterno_label.pack(side=tk.LEFT, padx=10)
top_right_buttons_frame = ctk.CTkFrame(top_frame, corner_radius=5, fg_color="#2a3a4a")
top_right_buttons_frame.pack(side=tk.RIGHT, padx=10)
update_btn = ctk.CTkButton(top_right_buttons_frame, text="Update", command=fetch_code_fixes, font=("Arial", 12), corner_radius=8, fg_color="#3a4a6a", hover_color="#4a5a7a", text_color="#99ccff")
update_btn.pack(side=tk.RIGHT, padx=5)
settings_btn = ctk.CTkButton(top_right_buttons_frame, text="Settings", command=toggle_settings, font=("Arial", 12), corner_radius=8, fg_color="#3a4a6a", hover_color="#4a5a7a", height=30, text_color="#99ccff")
settings_btn.pack(side=tk.RIGHT, padx=5)
status_label = ctk.CTkLabel(top_frame, text="Status: UNATTACHED", font=("Arial", 14, "bold"), text_color="#ff0000")
status_label.pack(side=tk.RIGHT, padx=10)
main_frame = ctk.CTkFrame(root, corner_radius=10, fg_color="#2a3a4a")
main_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=5)
settings_panel = ctk.CTkFrame(root, corner_radius=10, fg_color="#2a3a4a")
settings_label = ctk.CTkLabel(settings_panel, text="Settings", font=("Arial", 18, "bold"), text_color="#99ccff")
settings_label.pack(pady=10)
theme_label = ctk.CTkLabel(settings_panel, text="Select Theme:", font=("Arial", 14), text_color="#99ccff")
theme_label.pack(pady=5)
theme_buttons_frame = ctk.CTkFrame(settings_panel, fg_color="#2a3a4a")
theme_buttons_frame.pack(pady=10)
for theme in ["White", "Red", "Blue", "Green"]:
    btn = ctk.CTkButton(theme_buttons_frame, text=theme, command=lambda t=theme: change_theme(t), font=("Arial", 12), corner_radius=8, fg_color="#3a4a6a", hover_color="#4a5a7a", width=100, text_color="#99ccff")
    btn.pack(side=tk.LEFT, padx=5)
credits_frame = ctk.CTkFrame(settings_panel, corner_radius=10, fg_color="#2a3a4a", height=130)
credits_frame.pack(fill=tk.X, padx=10, pady=10)
credits_frame.pack_propagate(False)
credits_label = ctk.CTkLabel(credits_frame, text="Credits", font=("Arial", 14, "bold"), text_color="#99ccff")
credits_label.pack(pady=5)
credits_text = ctk.CTkTextbox(credits_frame, font=("Arial", 11), height=80, corner_radius=8, fg_color="#2a4a5a", text_color="#99ccff")
credits_text.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
credits_text.insert("1.0", "Version: 1.5\n" "Developed by NickleNickleson, Virck, Icey\nIn collaboration with the WeAreDevs exploit API\nContact any of us at https://discord.gg/w62KeAw4hK")
credits_text.configure(state="disabled")
sidebar = ctk.CTkFrame(main_frame, width=250, corner_radius=10, fg_color="#2a4a5a")
sidebar.pack(side=tk.LEFT, fill=tk.Y, padx=(0, 10), pady=5)
sidebar.pack_propagate(False)
popular_frame = ctk.CTkFrame(sidebar, corner_radius=10, fg_color="#2a3a4a", height=200)
popular_frame.pack(fill=tk.X, padx=10, pady=(5, 0))
popular_frame.pack_propagate(False)
popular_label = ctk.CTkLabel(popular_frame, text="Popular Scripts", font=("Arial", 14, "bold"), text_color="#99ccff")
popular_label.pack(pady=5)
popular_scripts = [
    ("Infinite Yield (All Games)", load_infinite_yield),
    ("Owl Hub (All Games)", load_owl_hub),
    ("FTAP BloodyV2 (FTAP Only)", load_ftap_bloodyv2),
    ("Ruhub FTAP (FTAP Only)", load_ruhub_ftap),
    ("Soluna (Rivals Only)", load_rivals),
    ("Diablo0011 (Brookhaven RP)", load_brookhaven),
    ("TheBronx (Universal)", load_thabronx)
]
popular_scroll = ctk.CTkScrollableFrame(popular_frame, fg_color="#2a3a4a", height=150)
popular_scroll.pack(fill=tk.X, padx=5, pady=5)
for name, cmd in popular_scripts:
    btn = ctk.CTkButton(popular_scroll, text=name, command=cmd, font=("Arial", 11), corner_radius=8, fg_color="#3a4a6a", hover_color="#4a5a7a", anchor="w", height=28, text_color="#99ccff")
    btn.pack(fill=tk.X, pady=2)
asset_frame = ctk.CTkFrame(sidebar, corner_radius=10, fg_color="#2a3a4a", height=200)
asset_frame.pack(fill=tk.X, padx=10, pady=(10, 5))
asset_frame.pack_propagate(False)
asset_label = ctk.CTkLabel(asset_frame, text="Asset Scripts", font=("Arial", 14, "bold"), text_color="#99ccff")
asset_label.pack(pady=5)
asset_scripts = [
    ("Aimbot", load_aimbot),
    ("Fly", load_fly),
    ("Infinite Jump", load_infinitejump),
    ("Noclip", load_noclip),
    ("ESP", load_esp),
    ("Fling", load_fling),
    ("Walk Speed", load_walkspeed),
    ("Teleport to Player", load_teleport)
]
asset_scroll = ctk.CTkScrollableFrame(asset_frame, fg_color="#2a3a4a", height=150)
asset_scroll.pack(fill=tk.X, padx=5, pady=5)
for name, cmd in asset_scripts:
    btn = ctk.CTkButton(asset_scroll, text=name, command=cmd, font=("Arial", 11), corner_radius=8, fg_color="#3a4a6a", hover_color="#4a5a7a", anchor="w", height=28, text_color="#99ccff")
    btn.pack(fill=tk.X, pady=2)
upload_label = ctk.CTkLabel(sidebar, text="Upload Scripts", font=("Arial", 14, "bold"), text_color="#99ccff")
upload_label.pack(pady=10)
folder_label = ctk.CTkLabel(sidebar, text="No Folder Selected", font=("Arial", 12), text_color="#99ccff")
folder_label.pack(pady=5)
select_folder_btn = ctk.CTkButton(sidebar, text="Select Folder", command=select_scripts_folder, font=("Arial", 12), corner_radius=8, fg_color="#3a4a6a", hover_color="#4a5a7a", height=30, text_color="#99ccff")
select_folder_btn.pack(fill=tk.X, padx=10, pady=5)
load_btn = ctk.CTkButton(sidebar, text="Load Scripts", command=load_scripts, font=("Arial", 12), corner_radius=8, fg_color="#3a4a6a", hover_color="#4a5a7a", height=30, text_color="#99ccff")
load_btn.pack(fill=tk.X, padx=10, pady=5)
scripts_list = tk.Listbox(sidebar, bg="#2a4a5a", fg="white", font=("Arial", 12), bd=0, highlightthickness=0, selectbackground="#3a4a6a", height=10)
scripts_list.pack(fill=tk.X, padx=10, pady=5)
scripts_list.bind('<Double-Button-1>', lambda e: load_selected_script())
right_panel = ctk.CTkFrame(main_frame, corner_radius=10, fg_color="#2a4a5a")
right_panel.pack(side=tk.RIGHT, fill=tk.BOTH, expand=True, pady=5)
button_frame = ctk.CTkFrame(right_panel, height=60, corner_radius=10, fg_color="#2a3a4a")
button_frame.pack(fill=tk.X, padx=10, pady=5)
button_frame.pack_propagate(False)
control_buttons = [
    ("Attach", attach_roblox, "#3a4a6a"),
    ("Execute", execute_code, "#3a4a6a"),
    ("Kill Roblox", kill_roblox, "#ff3333"),
    ("Open", open_file, "#3a4a6a"),
    ("Save", save_file, "#3a4a6a")
]
for i, (text, cmd, color) in enumerate(control_buttons):
    btn = ctk.CTkButton(button_frame, text=text, command=cmd, font=("Arial", 12), corner_radius=8, fg_color=color, hover_color="#4a5a7a" if color == "#3a4a6a" else "#ff4444", height=30, text_color="#99ccff")
    btn.pack(side=tk.LEFT, padx=5)
editor_label = ctk.CTkLabel(right_panel, text="Lua Script Executor", font=("Arial", 14, "bold"), text_color="#99ccff")
editor_label.pack(pady=10)
executor_frame = ctk.CTkFrame(right_panel, corner_radius=0, fg_color="#3a5a6a")
executor_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=(0, 10))
line_numbers = ctk.CTkTextbox(executor_frame, width=40, font=("Courier", 12), corner_radius=0, fg_color="#3a5a6a", text_color="gray")
line_numbers.pack(side=tk.LEFT, fill=tk.Y)
line_numbers.insert("1.0", "1")
line_numbers.configure(state="disabled")
script_input = ctk.CTkTextbox(executor_frame, font=("Courier", 12), height=400, corner_radius=0, fg_color="#3a5a6a", text_color="white")
script_input.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
def update_line_numbers(event=None):
    line_numbers.configure(state="normal")
    line_numbers.delete("1.0", tk.END)
    content = script_input.get("1.0", tk.END).rstrip("\n")
    lines = content.count("\n") + 1 if content else 1
    line_numbers.insert("1.0", "\n".join(str(i) for i in range(1, lines + 1)))
    line_numbers.configure(state="disabled")
script_input.bind("<KeyRelease>", update_line_numbers)
script_input.bind("<Return>", update_line_numbers)
update_line_numbers()
updates_frame = ctk.CTkFrame(right_panel, height=150, corner_radius=10, fg_color="#2a3a4a", border_width=2, border_color="#99ccff")
updates_frame.pack(fill=tk.X, padx=10, pady=5)
updates_frame.pack_propagate(False)
updates_label = ctk.CTkLabel(updates_frame, text="Updates & News", font=("Arial", 14, "bold"), text_color="#99ccff")
updates_label.pack(pady=5)
updates_display = ctk.CTkTextbox(updates_frame, font=("Arial", 11), height=110, corner_radius=8, fg_color="#2a4a5a", text_color="white")
updates_display.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
updates_display.configure(state="disabled")  
def check_for_updates_on_startup():
    load_guard()
    def fetch_updates():
        global updates_list
        github_updates_url = "https://github.com/HomerSimpson88354/EternoSploit/blob/main/updates.txt?raw=true"
        try:
            response = requests.get(github_updates_url, timeout=10)
            if response.status_code == 200:
                updates_list = response.text.splitlines()
                updates_display.configure(state="normal")  
                updates_display.delete("1.0", tk.END)
                for update in updates_list:
                    updates_display.insert(tk.END, update + "\n")
                updates_display.configure(state="disabled")  
        except requests.exceptions.RequestException:
            pass
    thread = Thread(target=fetch_updates, daemon=True)
    thread.start()
load_last_fixes_hash()
root.after(500, check_for_updates_on_startup)
debug_assets_folder()
load_guard()
if not globals().get("INTEGRITY_OK", False):
    os._exit(1)
change_theme("Blue")
root.mainloop()

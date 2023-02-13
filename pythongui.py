import tkinter as tk
import subprocess

def start_service():
    subprocess.run(["service", "start", service_name.get()], capture_output=True)
    log.insert("end", f"Started service {service_name.get()}\n")

def stop_service():
    subprocess.run(["service", "stop", service_name.get()], capture_output=True)
    log.insert("end", f"Stopped service {service_name.get()}\n")

def restart_service():
    subprocess.run(["service", "restart", service_name.get()], capture_output=True)
    log.insert("end", f"Restarted service {service_name.get()}\n")

root = tk.Tk()
root.title("Service Manager")

service_name = tk.StringVar()

service_entry = tk.Entry(root, textvariable=service_name)
service_entry.pack()

start_button = tk.Button(root, text="Start", command=start_service)
start_button.pack()

stop_button = tk.Button(root, text="Stop", command=stop_service)
stop_button.pack()

restart_button = tk.Button(root, text="Restart", command=restart_service)
restart_button.pack()

log = tk.Text(root)
log.pack()

root.mainloop()

#The main difference from the previous example is that the capture_output argument is set to True in the subprocess.run function to capture the standard output 
# of the commands. Also, the "end" argument is used instead of tk.END to specify the end of the text box in the log.insert method.
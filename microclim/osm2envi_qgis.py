from qgis.PyQt.QtCore import QCoreApplication
from qgis.core import (QgsProcessing,
                       QgsFeatureSink,
                       QgsProcessingException,
                       QgsProcessingAlgorithm,
                       QgsProcessingParameterFile,
                       QgsProcessingParameterFolderDestination)
from qgis import processing
from qgis.processing import alg
import subprocess
import os
import platform
import re
import sys

# Function to remove ANSI escape codes from output logs
def strip_ansi_codes(text):
    ansi_escape = re.compile(r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])')
    return ansi_escape.sub('', text)

@alg(name="run_bash", label="Run Bash Script", group="Custom Scripts", group_label="Custom Scripts")
@alg.input(type=alg.FILE, name="SCRIPT", label="Bash Script (Must be an .sh file)")  # Updated label
@alg.input(type=alg.FILE, name="OSM", label="OSM File (Required)")  
@alg.input(type=alg.FILE, name="DEM", label="DEM File (Optional, must be used with DSM)", optional=True)
@alg.input(type=alg.FILE, name="DSM", label="DSM File (Optional, must be used with DEM)", optional=True)
@alg.output(type=alg.FOLDER, name="RESULT", label="Processed Output Directory")

def run_bash_script(instance, parameters, context, feedback, values=None):
    """
    Runs a Bash script as a QGIS Processing Tool, ensuring cross-platform execution.
    
    ⚠ Windows: You must download and install Git Bash for Windows!
        Step 1: Download Git Bash 
                🔗 https://git-scm.com/downloads
        Step 2: Run the installer (Git-*-64-bit.exe).
        Step 3: Restart QGIS
    """

    # Get script path and input files
    script_path = parameters["SCRIPT"]
    osm_file = parameters["OSM"]
    dem_file = parameters.get("DEM", None)
    dsm_file = parameters.get("DSM", None)

    feedback.pushInfo(f"🔧 Running Bash script: {script_path}")
    feedback.pushInfo(f"📂 OSM File: {osm_file}")

    # Check if both DEM and DSM are provided together
    if (dem_file and not dsm_file) or (dsm_file and not dem_file):
        feedback.reportError("❌ Error: DEM and DSM must both be provided or both omitted.", fatalError=True)
        return {"RESULT": ""}

    if dem_file and dsm_file:
        feedback.pushInfo(f"📂 DEM File: {dem_file}")
        feedback.pushInfo(f"📂 DSM File: {dsm_file}")

    # Detect OS and set Bash path accordingly
    if platform.system() == "Windows":
        bash_path = r"C:\Program Files\Git\bin\bash.exe"  # Use Git Bash
        feedback.pushInfo("⚠️ Windows Users: This script requires Git Bash. Download from: https://git-scm.com/downloads")
        
        # Setup Windows process startup info to minimize window
        startupinfo = subprocess.STARTUPINFO()
        startupinfo.dwFlags |= subprocess.STARTF_USESHOWWINDOW
        startupinfo.wShowWindow = 6  # Minimized window

    else:
        bash_path = "/bin/bash"  # Default for Linux/Mac
        startupinfo = None  # No need for startup settings on Unix-like systems

    # Test if Bash is available
    try:
        subprocess.run([bash_path, "-c", "ls"], check=True, capture_output=True)
        feedback.pushInfo("✅ Bash environment is available.")
    except FileNotFoundError:
        feedback.reportError("❌ Error: Bash is not installed. Install Git Bash for Windows.", fatalError=True)
        return {"RESULT": ""}

    # Ensure script is executable (Only on Unix-like systems)
    if platform.system() != "Windows":
        subprocess.run(["chmod", "+x", script_path], check=True)

    # Prepare command arguments
    command = [bash_path, script_path, osm_file]
    
    # Append DEM & DSM **only if both are provided**
    if dem_file and dsm_file:
        command.extend([dem_file, dsm_file])

    # Run Bash script with real-time output streaming and minimized window on Windows
    try:
        process = subprocess.Popen(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            bufsize=1,
            universal_newlines=True,
            startupinfo=startupinfo  # This minimizes the window on Windows
        )

        # Read output line by line and display in real-time
        for line in iter(process.stdout.readline, ""):
            clean_line = strip_ansi_codes(line.strip())
            feedback.pushInfo(clean_line)  # Display in QGIS log
            print(clean_line)  # Display in Bash shell

        for line in iter(process.stderr.readline, ""):
            clean_line = strip_ansi_codes(line.strip())
            feedback.reportError(clean_line, fatalError=False)
            print(clean_line)  # Show errors in Bash shell

        # Wait for process to finish
        process.stdout.close()
        process.stderr.close()
        process.wait()

        if process.returncode != 0:
            feedback.reportError(f"❌ Script execution failed with exit code {process.returncode}.", fatalError=True)
            return {"RESULT": ""}

    except subprocess.CalledProcessError as e:
        clean_error = strip_ansi_codes(e.stderr)
        feedback.reportError(f"❌ Script execution failed: {clean_error}", fatalError=True)
        return {"RESULT": ""}

    # Return a dummy output directory as required by QGIS Processing
    output_dir = os.path.dirname(script_path)  # Example: Place results in the same directory
    return {"RESULT": output_dir}

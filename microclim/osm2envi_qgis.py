"""
***************************************************************************
*                                                                         *
*   This program is free software; you can redistribute it and/or modify  *
*   it under the terms of the GNU General Public License as published by  *
*   the Free Software Foundation; either version 2 of the License, or     *
*   (at your option) any later version.                                   *
*                                                                         *
***************************************************************************
"""

from qgis.PyQt.QtCore import QCoreApplication
from qgis.core import (QgsProcessing,
                       QgsFeatureSink,
                       QgsProcessingException,
                       QgsProcessingAlgorithm,
                       QgsProcessingParameterFeatureSource,
                       QgsProcessingParameterFeatureSink)
from qgis import processing


from qgis.processing import alg
import subprocess

@alg(name="run_bash", label="Run Bash Script", group="Custom Scripts", group_label="Custom Scripts")
@alg.input(type=alg.FILE, name="SCRIPT", label="Bash Script")  # No extensions needed
@alg.input(type=alg.FILE, name="OSM", label="OSM File")        # No extensions needed
@alg.input(type=alg.FILE, name="DEM", label="DEM File")        # No extensions needed
@alg.input(type=alg.FILE, name="DSM", label="DSM File")        # No extensions needed
@alg.output(type=alg.FOLDER, name="RESULT", label="Processed Output Directory")

def run_bash_script(instance, parameters, context, feedback, values=None):
  """
    Runs a Bash script as a QGIS Processing Tool.
    """

# Get script path and input files
script_path = parameters["SCRIPT"]
osm_file = parameters["OSM"]
dem_file = parameters["DEM"]
dsm_file = parameters["DSM"]

feedback.pushInfo(f"🔧 Running Bash script: {script_path}")
feedback.pushInfo(f"📂 OSM File: {osm_file}")
feedback.pushInfo(f"📂 DEM File: {dem_file}")
feedback.pushInfo(f"📂 DSM File: {dsm_file}")

# Ensure script is executable
subprocess.run(["chmod", "+x", script_path], check=True)

# Execute Bash script
process = subprocess.run(["bash", script_path, osm_file, dsm_file, dem_file], capture_output=True, text=True)

# Log script output
feedback.pushInfo(process.stdout)

# Capture errors
if process.stderr:
  feedback.reportError(process.stderr, fatalError=False)

# Return a dummy output directory as required by QGIS Processing
return {"RESULT": "output"}


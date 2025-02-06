#!/bin/bash
# # ===============================================================================================================
# OSM Processing Script for ENVIMET Vegetation Mapping
# # ===============================================================================================================
# Description:
# This script processes an OpenStreetMap (OSM) file to extract and reproject
# geographic features relevant to vegetation, surface, and building types for ENVIMET modeling.
#
# Steps:
# 1. Convert OSM file to GeoPackage (GPKG).
# 2. Extract features (vegetation, surface types, buildings).
# 3. Reproject layers to EPSG:32632.
# 4. Apply field calculations (ENVIMET_ID, SURFACE_TYPE).
# 5. Extract buildings (`buildings.gpkg`).
# 6. Extract buildings heights using `DHM_32632.tif` for height analysis.
#

# Dependencies:
# - QGIS (`qgis_process`)
# - GDAL (`ogr2ogr`)
#
# Inputs:
# - OSM file located in the input directory.
#
# Outputs:
# - Processed GeoPackage files in the output directory.
#
# Author: gisma
# Date: 2025
# # ===============================================================================================================

# # ===========================================================================================
# Definitions: Project Paths
# # ===========================================================================================

# Function to display help message
usage() {
    echo "Usage:"
    echo "  Positional Mode: $0 <input_osm> [<dsm_raster> <dem_raster>]"
    echo "  Named Arguments: $0 -i <input_osm> [-s <dsm_raster>] [-d <dem_raster>]"
    echo -e "\nArguments:"
    echo "  -i <input_osm>   Path to the input OSM file (required in named mode)"
    echo "  -s <dsm_raster>  Path to the DSM raster file (optional, but required if DEM is provided)"
    echo "  -d <dem_raster>  Path to the DEM raster file (optional, but required if DSM is provided)"
    echo "  -h               Display this help message"
    exit 1
}

# Initialize variables
input_osm=""
dsm_raster=""
dem_raster=""

# Detect if the first argument is a flag (named mode) or a file (positional mode)
if [[ "$1" == "-"* ]]; then
    # Named argument mode
    while getopts ":i:s:d:h" opt; do
        case ${opt} in
            i) input_osm="$OPTARG" ;;
            s) dsm_raster="$OPTARG" ;;
            d) dem_raster="$OPTARG" ;;
            h) usage ;;
            :) echo "Error: Option -$OPTARG requires an argument." >&2; exit 1 ;;
            \?) echo "Invalid option: -$OPTARG" >&2; usage ;;
        esac
    done
else
    # Positional argument mode
    input_osm=$1
    dsm_raster=$2
    dem_raster=$3
fi

# Ensure required argument is provided
if [[ -z "$input_osm" ]]; then
    echo "Error: The OSM file is required."
    usage
fi

# Check if only one of DSM or DEM is provided
if [[ -n "$dsm_raster" && -z "$dem_raster" ]] || [[ -z "$dsm_raster" && -n "$dem_raster" ]]; then
    echo "Error: Both DSM and DEM must be provided together."
    exit 1
fi

# Determine processing mode
if [[ -n "$dsm_raster" && -n "$dem_raster" ]]; then
    height_extraction=true
else
    height_extraction=false
    echo "Note: Processing will be done without height extraction."
fi

# Print input parameters
echo "Processing OSM file: $input_osm"
if [[ "$height_extraction" == true ]]; then
    echo "Using DSM raster: $dsm_raster"
    echo "Using DEM raster: $dem_raster"
else
    echo "Skipping height extraction."
fi



# Define project directory and research area name
input_dir=$(dirname "$input_osm")          # Directory of the OSM file
project_path=$(dirname "$input_dir") 
research_area=$(basename "$input_osm" .osm) # Extract research area name (OSM filename without extension)
output_dir="$project_path/output"
ohm_raster="$output_dir/OHM.tif"
output_osm_gpkg="$output_dir/${research_area}.gpkg"

# # ===========================================================================================
# Temporary Processing Files
# # ===========================================================================================
# These are intermediate files that will be deleted later

tmp_veg="$output_dir/vegetation_tmp.gpkg"
tmp_surface_poly="$output_dir/surface_poly_tmp.gpkg"
tmp_buildings="$output_dir/buildings_tmp.gpkg"
tmp_surface_lines="$output_dir/surface_line_tmp.gpkg"
tmp_merged="$output_dir/merged_tmp.gpkg"
tmp_buffer="$output_dir/suface_buffer_tmp.gpkg"
tmp_buffer_calc="$output_dir/surface_buffer_calc_tmp.gpkg"
tmp_height_analysis="$output_dir/height_analysis_tmp.gpkg"

# # ===========================================================================================
# Projected & Clipped Files
# # ===========================================================================================
# These files store processed data with reprojected and clipped geometries

proj_veg="$output_dir/vegetation_proj.gpkg"
proj_surface_poly="$output_dir/surface_poly_proj.gpkg"
proj_surface_lines="$output_dir/surface_line_proj.gpkg"
proj_buildings="$output_dir/buildings_proj.gpkg"

clip_veg="$output_dir/vegetation_clip.gpkg"
clip_surface_poly="$output_dir/surface_poly_clip.gpkg"
clip_surface_poly_envimet="$output_dir/surface_poly_envimet_clip.gpkg"
clip_surface_lines="$output_dir/surface_line_clip.gpkg"
clip_surface_buffer="$output_dir/surface_line_buffered_clip.gpkg"
clip_surface_buffer_envimet="$output_dir/surface_line_buffered_envimet_clip.gpkg"
clip_buildings="$output_dir/buildings_clip.gpkg"

# # ===========================================================================================
# Final Output Files
# # ===========================================================================================
# These are the final output files that will be retained

final_surface="$output_dir/${research_area}_surface_final.gpkg"
final_buildings="$output_dir/${research_area}_buildings_final.gpkg"
final_vegetation="$output_dir/${research_area}_vegetation_final.gpkg"

# # ===========================================================================================
# Model Domain & CRS
# # ===========================================================================================
# Define spatial reference system and clipping extent

target_crs="EPSG:32632"
extent="481085.937500000,481686.218800000,5626620.500000000,5627058.500000000 [EPSG:32632]"

# # ===========================================================================================
# Filters for Extracting Layers
# # ===========================================================================================
# Define attribute filters for different layers to extract

filter_multipolygons_veg="\"landuse\" IN ('allotments', 'farmland', 'farmyard', 'forest', 'grass','meadow', 'orchard', 'village_green', 'grassland', 'scrub', 'wood') OR \"natural\" IN ('allotments', 'farmland', 'farmyard', 'forest', 'grass','meadow', 'orchard', 'village_green', 'grassland', 'scrub', 'wood')"
filter_lines_surface="\"highway\" IN ('primary', 'primary_link', 'residential', 'secondary','secondary_link', 'tertiary', 'tertiary_link', 'track')"
filter_buildings="\"building\" IS NOT NULL"
filter_multipolygons_surface="\"landuse\" IN ('farmland', 'residental', 'industrial')"

# # ===========================================================================================
# SQL Formulas for Field Calculations
# # ===========================================================================================
# Define classification formulas for ENVIMET surface types

# Vegetation classification
formula_multipolygons_veg="CASE
    WHEN \"landuse\" = 'grass' THEN '000000'
    WHEN \"landuse\" = 'meadow' THEN '000000'
    WHEN \"landuse\" = 'farmyard' THEN '0201H4'
    WHEN \"landuse\" = 'forest' THEN '0000SM'
    WHEN \"landuse\" = 'allotments' THEN '0201H4'
    WHEN \"landuse\" = 'orchard' THEN '000051'
    WHEN \"natural\" = 'grassland' THEN '000000'
    WHEN \"natural\" = 'wood' THEN '0000SM'
    WHEN \"natural\" = 'scrub' THEN '0100H2'
    ELSE '000000'
END"

# Road and surface classification
formulas_lines_surface_envimet="CASE
    WHEN \"highway\" = 'primary' THEN '0200AK'
    WHEN \"highway\" = 'primary_link' THEN '0200AK'
    WHEN \"highway\" = 'secondary' THEN '0200AK'
    WHEN \"highway\" = 'secondary_link' THEN '0200AK'
    WHEN \"highway\" = 'tertiary' THEN '0200AK'
    WHEN \"highway\" = 'tertiary_link' THEN '0200AK'
    WHEN \"surface\" = 'asphalt' THEN '0200AK'
    WHEN \"surface\" = 'ground' THEN '0200TS'
    WHEN \"surface\" = 'dirt' THEN '0200TS'
    WHEN \"surface\" = 'mud' THEN '0200TS'
    WHEN \"surface\" = 'fine_gravel' THEN '0200BS'
    WHEN \"surface\" = 'gravel' THEN '0200BS'
    WHEN \"surface\" = 'grass' THEN '02AGSS'
    WHEN \"surface\" = 'unpaved' THEN '0200TS'
    WHEN \"surface\" = 'compacted' THEN '0200BS'
    ELSE '0200TS'
END"

# Land use classification
formula_multipolygons_surface_envimet="CASE
    WHEN \"landuse\" = 'farmland' THEN '02AGSS'
    WHEN \"landuse\" = 'residental' THEN '02AGSS'    
    WHEN \"landuse\" = 'industrial' THEN '0200AK'
    ELSE '02AGSS'
END"

# Buffer distance calculation based on highway type
formula_line_surface_buffer="CASE 
    WHEN \"highway\" = 'primary' THEN 10
    WHEN \"highway\" = 'primary_link' THEN 10
    WHEN \"highway\" = 'secondary' THEN 6
    WHEN \"highway\" = 'secondary_link' THEN 6
    WHEN \"highway\" = 'tertiary' THEN 4
    WHEN \"highway\" = 'tertiary_link' THEN 4       
    WHEN \"highway\" = 'residential' THEN 4       
    WHEN \"highway\" = 'track' THEN 1
    ELSE 2
END"

# # ===========================================================================================
# Main Script Execution
# # ===========================================================================================
echo -e "\e[1;32m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
echo -e "\e[1;33m🔄 Starting the OSM processing script for research area '$research_area'... \e[0m"
echo -e "\e[1;32m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"


# Ensure input and output directories exist
mkdir -p "$input_dir" "$output_dir"

# # ===========================================================================================
# Step 1: Convert OSM file to GeoPackage
# # ===========================================================================================
echo -e "\e[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
echo -e "\e[1;33m🔄 Converting OSM file to GeoPackage...\e[0m"
echo -e "\e[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
ogr2ogr -f "GPKG" -dsco "SPATIALITE=YES" "$output_osm_gpkg" "$input_osm" || {
    echo "❌ Failed to convert OSM to GeoPackage."
    exit 1
}

# # ===========================================================================================
# Step 2: Extract, Reproject, and Clip Layers
# # ===========================================================================================
echo -e "\e[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
echo -e "\e[1;33m🔄 Extract, Reproject, and Clip Layers...\e[0m"
echo -e "\e[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"

# Define layer extraction parameters in an associative array
declare -A layers
layers["vegetation"]="multipolygons|$filter_multipolygons_veg|$tmp_veg|$proj_veg|$clip_veg"
layers["landuse"]="multipolygons|$filter_multipolygons_surface|$tmp_surface_poly|$proj_surface_poly|$clip_surface_poly"
layers["surface"]="lines|$filter_lines_surface|$tmp_surface_lines|$proj_surface_lines|$clip_surface_lines"
layers["buildings"]="multipolygons|$filter_buildings|$tmp_buildings|$proj_buildings|$clip_buildings"


# Loop through each defined layer type
for layer in "${!layers[@]}"; do
    IFS="|" read -r layername filter tmp_output proj_output clip_output <<< "${layers[$layer]}"

    echo "🔍 Extracting $layer..."
    qgis_process run native:extractbyexpression \
        INPUT="$output_osm_gpkg|layername=$layername" \
        EXPRESSION="$filter" \
        OUTPUT="$tmp_output">>"$output_dir/qgis_${research_area}.log" 2>&1 || exit 1

    echo "🔍 Reprojecting $layer..."
    qgis_process run native:reprojectlayer \
        INPUT="$tmp_output" \
        TARGET_CRS="EPSG:32632" \
        OUTPUT="$proj_output">>"$output_dir/qgis_${research_area}.log" 2>&1 || exit 1

    echo "🔍 Clipping $layer..."
    qgis_process run native:extractbyextent \
        INPUT="$proj_output" \
        EXTENT="$extent" \
        CLIP="true" \
        OUTPUT="$clip_output">>"$output_dir/qgis_${research_area}.log" 2>&1 || exit 1
done

echo "✅ All layers processed successfully!"

# # ===========================================================================================
# Step 3: Apply Field Calculations for Classification
# # ===========================================================================================
echo -e "\e[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
echo -e "\e[1;33m🔄 Applying field calculations......\e[0m"
echo -e "\e[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"

# Assign ENVIMET_ID to vegetation layers
qgis_process run native:fieldcalculator \
    INPUT="$clip_veg" \
    FIELD_NAME="ENVIMET_ID" \
    FIELD_TYPE=2 \
    FIELD_LENGTH=6 \
    FIELD_PRECISION=0 \
    FORMULA="$formula_multipolygons_veg" \
    OUTPUT="$final_vegetation">>"$output_dir/qgis_${research_area}.log" 2>&1 || exit 1

# Assign ENVIMET_ID to land use layers
qgis_process run native:fieldcalculator \
    INPUT="$clip_surface_poly" \
    FIELD_NAME="ENVIMET_ID" \
    FIELD_TYPE=2 \
    FIELD_LENGTH=6 \
    FIELD_PRECISION=0 \
    FORMULA="$formula_multipolygons_surface_envimet" \
    OUTPUT="$clip_surface_poly_envimet">>"$output_dir/qgis_${research_area}.log" 2>&1 || exit 1


# If DSM and DSM exist we perform a height extraction
if [[ "$height_extraction" == true ]]; then

# # ===========================================================================================
# Step 4: Compute Building Heights
# # ===========================================================================================
echo -e "\e[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
echo -e "\e[1;33m🔄 Applying zonal statistics to calculate building heights...\e[0m"
echo -e "\e[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"



# Perform raster calculation
echo "🔄 Calculating difference raster (DSM - DTM)..."
gdal_calc.py --overwrite -A "$dsm_raster" -B "$dem_raster" --outfile="$ohm_raster" --calc="A-B" --format=GTiff

# Check if the operation was successful
if [[ $? -eq 0 ]]; then
    echo "✅ Difference raster saved as: $ohm_raster"
else
    echo "❌ Error: Raster calculation failed."
fi

# Define input and output layers for zonal statistics
input_buildings="${proj_buildings}|layername=${research_area}_buildings_proj"
output_zonal_stats="$tmp_height_analysis"

# Perform zonal statistics using the DHM raster for height data
qgis_process run native:zonalstatisticsfb \
    INPUT="$clip_buildings" \
    INPUT_RASTER="$ohm_raster" \
    RASTER_BAND=1 \
    COLUMN_PREFIX="height_" \
    STATISTICS=2 \
    OUTPUT="$output_zonal_stats">>"$output_dir/qgis_${research_area}.log" 2>&1 || exit 1

# Clip the resulting building heights
qgis_process run native:extractbyextent \
    INPUT="$output_zonal_stats" \
    EXTENT="$extent" \
    CLIP="true" \
    OUTPUT="$final_buildings">>"$output_dir/qgis_${research_area}.log" 2>&1 || exit 1
else
mv "$clip_buildings" "$final_buildings"
fi

# # ===========================================================================================
# Step 5: Buffering for Surface Features
# # ===========================================================================================
echo -e "\e[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
echo -e "\e[1;33m🔄 Applying buffer based on highway type...\e[0m"
echo -e "\e[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"

# Calculate buffer distances for road layers
qgis_process run qgis:fieldcalculator -- \
    INPUT="$clip_surface_lines" \
    FIELD_NAME="buffer_distance" \
    FIELD_TYPE=0 \
    FIELD_LENGTH=10 \
    FIELD_PRECISION=2 \
    FORMULA="$formula_line_surface_buffer" \
    OUTPUT="$tmp_buffer_calc">>"$output_dir/qgis_${research_area}.log" || exit 1

# Generate buffer zones around roads
qgis_process run native:buffer \
    INPUT="$tmp_buffer_calc" \
    DISTANCE_FIELD="buffer_distance" \
    SEGMENTS=5 \
    DISSOLVE="false" \
    OUTPUT="$tmp_buffer">>"$output_dir/qgis_${research_area}.log" 2>&1 || exit 1

# Clip the buffered road surfaces
qgis_process run native:extractbyextent \
    INPUT="$tmp_buffer" \
    EXTENT="$extent" \
    CLIP="true" \
    OUTPUT="$clip_surface_buffer">>"$output_dir/qgis_${research_area}.log" 2>&1 || exit 1

# Assign ENVIMET_ID to buffered surfaces
qgis_process run native:fieldcalculator \
    INPUT="$clip_surface_buffer" \
    FIELD_NAME="ENVIMET_ID" \
    FIELD_TYPE=2 \
    FIELD_LENGTH=6 \
    FIELD_PRECISION=0 \
    FORMULA="$formulas_lines_surface_envimet" \
    OUTPUT="$clip_surface_buffer_envimet">>"$output_dir/qgis_${research_area}.log" 2>&1 || exit 1

# # ===========================================================================================
# Step 6: Merge Layers & Final Processing
# # ===========================================================================================
echo -e "\e[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
echo -e "\e[1;33m🔄 Merging surface types and applying final field calculation...\e[0m"
echo -e "\e[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"

# Merge buffered roads with land use data
qgis_process run native:mergevectorlayers \
   LAYERS="$clip_surface_buffer_envimet" \
   LAYERS="$clip_surface_poly_envimet" \
   CRS="EPSG:32632" \
   OUTPUT="$final_surface">>"$output_dir/qgis_${research_area}.log" 2>&1 || exit 1


# # ===========================================================================================
# Step 7: Cleanup Temporary Files
# # ===========================================================================================
echo -e "\e[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
echo -e "\e[1;33m🔄 Cleaning up temporary files...\e[0m"
echo -e "\e[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"

find "$output_dir" -type f \( -name "*_tmp.gpkg" -o -name "*_proj.gpkg" -o -name "*_clip.gpkg" \) -exec rm -f {} +



# # ===========================================================================================
# Step 8: Optimize for ENVIMET
# # ===========================================================================================
echo -e "\e[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
echo -e "\e[1;33m🔄 Optimizing final files for ENVIMET...\e[0m"
echo -e "\e[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
echo "Retained final output files:"
# Process final outputs to keep only necessary columns
for file in "$final_surface" "$final_buildings" "$final_vegetation"; do


    # Extract the layer name from the file path
    layer_name=$(basename "$file" .gpkg)
    cleaned_file="${output_dir}/${layer_name}_envimet.gpkg"

    # Ensure the file exists before processing
    if [[ ! -f "$file" ]]; then
        echo "⚠️ Skipping: $file (File not found)"
        continue
    fi

    # Get column information from the layer
    column_info=$(ogrinfo -sql "PRAGMA table_info('$layer_name')" "$file" 2>/dev/null)

    # Check if specific fields exist
    envimet_exists=$(echo "$column_info" | grep -w "ENVIMET_ID")
    height_exists=$(echo "$column_info" | grep -w "height_mean")

    # Construct the list of columns to keep (always keep 'geom')
    selected_columns="geom"
    [[ -n "$envimet_exists" ]] && selected_columns+=", ENVIMET_ID"
    [[ -n "$height_exists" ]] && selected_columns+=", height_mean"

    # Only proceed if additional relevant columns exist
    if [[ "$selected_columns" != "geom" ]]; then
        ogr2ogr -f GPKG "$cleaned_file" "$file" \
            -sql "SELECT $selected_columns FROM \"$layer_name\"" \
            -nlt PROMOTE_TO_MULTI -overwrite
        echo "✅ Saved cleaned file: $cleaned_file"
    else
        echo "⚠️ Skipping: $file (No relevant columns found)"
    fi
done

echo " 🔍 Log file is: $output_dir/qgis_${research_area}.log"
echo -e "\e[1;32m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ \e[0m"
echo -e "\e[1;33m✅ Script completed successfully for research area '$research_area'.\e[0m"
echo -e "\e[1;32m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ \e[0m"



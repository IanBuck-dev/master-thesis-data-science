import ee

# Trigger the authentication flow.
ee.Authenticate()

# Initialize Earth Engine
ee.Initialize()


def get_ndvi_data(west, south, east, north, start_date, end_date):
    """
    Imports NDVI data from Google Earth Engine.

    Parameters:
        bounding_box (list): List of coordinates for the bounding box in the format [lon_min, lat_min, lon_max, lat_max].
        start_date (str): Start date in 'YYYY-MM-DD' format.
        end_date (str): End date in 'YYYY-MM-DD' format.

    Returns:
        ee.ImageCollection: Earth Engine Image Collection containing NDVI data.
    """
    # Convert the bounding box coordinates to a geometry object
    region = ee.Geometry.BBox(west, south, east, north)

    # Load MODIS NDVI data
    modis_ndvi = (
        ee.ImageCollection("MODIS/061/MOD13A1")
        .filterDate(start_date, end_date)
        .select("NDVI")
    )

    clippedNdvi = modis_ndvi.first().getInfo()

    return clippedNdvi

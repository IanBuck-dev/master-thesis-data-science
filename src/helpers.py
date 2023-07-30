import pandas as pd
from geopandas import GeoDataFrame
from shapely.geometry import Point


def load_day_night_gdf(bounding_box, proj_wgs):
    df = pd.read_csv(f'./data/sensor.community/2023-06_all_qc_after.csv', delimiter=",", parse_dates=['time'])

    df = df[df["m5"] == True]

    df_day = df[df['time'] == '2023-06-19 14:00:00']
    df_night = df[df['time'] == '2023-06-19 05:00:00']

    gdf_day = GeoDataFrame(df_day, geometry=df_day[[
        'lon', 'lat']].apply(lambda row: Point(row[0], row[1]), axis=1), crs=proj_wgs)

    gdf_night = GeoDataFrame(df_night, geometry=df_night[[
        'lon', 'lat']].apply(lambda row: Point(row[0], row[1]), axis=1), crs=proj_wgs)

    # Only keep rows inside bounding box
    gdf_day = gdf_day[gdf_day.geometry.within(bounding_box)]
    gdf_night = gdf_night[gdf_night.geometry.within(bounding_box)]

    return gdf_day, gdf_night

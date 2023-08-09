// Compute Normalized Difference Vegetation Index over S2-L2 product.
// NDVI = (NIR - RED) / (NIR + RED), where
// RED is B4, 664.5 nm
// NIR is B8, 835.1 nm

//Step 1: Access your boundary-defining geometry
var extent_lebanon = ee.FeatureCollection("FAO/GAUL/2015/level0")
                  .filter(ee.Filter.eq('ADM0_NAME', 'Lebanon')); //filter for entry that equals the UN country name 'Lebanon'

//Step 2: Access the Sentinel-2 Level-2A data and filter it for all the the images of the year 2020 that lie within the geometries boundaries. Keep only the relevant bands and filter for cloud coverage.
var s2a = ee.ImageCollection('COPERNICUS/S2_SR')
                  .filterBounds(extent_lebanon)
                  .filterDate('2020-07-01', '2020-07-31')
                  .select('B1','B2','B3','B4','B5','B6','B7','B8','B8A','B9','B11','B12')
                  .filter(ee.Filter.lt('CLOUDY_PIXEL_PERCENTAGE', 10));

//Print your ImageCollection to your console tab to inspect it
print(s2a, 'Image Collection Lebanon July 2020');
Map.centerObject(s2a,9)


//Step 3: Create a single Image by reducing by Median and clip it to the extent of the geometry
var s2a_median = s2a.median()
                    .clip(extent_lebanon);

//Print your Image to your console tab to inspect it
print(s2a_median, 'Median reduced Image Lebanon July 2020');

//Add your Image as a map layer
var visParams = {'min': 400,'max': [4000,3000,3000],   'bands':'B8,B4,B3'};
Map.addLayer(s2a_median, visParams, 'S2 Lebanon July 2020 Median');

//Step 4: Calculate the NDVI manually: NDVI = (B8 - B4) / (B8 + B4)
//this can be achieved using either simple band operations, .expression or .normalizedDifference
//Variant 1: Simple band operations
var nir = s2a_median.select('B8');
var red = s2a_median.select('B4');
var ndvi = nir.subtract(red).divide(nir.add(red)).rename('NDVI');
print(ndvi, 'NDVI Lebanon July 2020 V1')

// Display the result.
var ndviParams = {min: -1, max: 1, palette: ['blue', 'white', 'green']};
Map.addLayer(ndvi, ndviParams, 'NDVI Lebanon July 2020 V1');

//Variant 2: .expression
var ndvi_2 = s2a_median.expression(
                      '(NIR-RED)/(NIR+RED)', {
                        'NIR' : s2a_median.select('B8'),
                        'RED' : s2a_median.select('B4')
                      })
                      .rename('NDVI');

print(ndvi_2, 'NDVI Lebanon July 2020 V2')

//Display the result
Map.addLayer(ndvi_2, ndviParams , 'NDVI Lebanon July 2020 V2');

//Variant 3: .normalizedDifference(NIR, RED)
//find out how .normalizedDifference works by checking Docs -> ee.Image -> normalizedDifference
var ndvi_3 = s2a_median.normalizedDifference(['B8', 'B4'])
                      .rename('NDVI');
print(ndvi_3, 'NDVI Lebanon July 2020 V3');

//You can also create more complex colour palettes via hex strings.
//this color combination is taken from the Examples script Image -> Normalized Difference:
var palette = ['FFFFFF', 'CE7E45', 'DF923D', 'F1B555', 'FCD163', '99B718',
               '74A901', '66A000', '529400', '3E8601', '207401', '056201',
               '004C00', '023B01', '012E01', '011D01', '011301'];
//Please keep in mind that for this palette, you should set your minimum visible value to 0, as it s designed for this purpose.
//This is due to it being a gradient from brown to green tones, with a heavy focus on the green side. If we would set min: -1, NDVI = 0 would already be displayed in a dark green tone.
//You can recognize this by checking the palette-section of your layer information for ndvi_3.

// Display the input image and the NDVI derived from it.
Map.addLayer(ndvi_3, {min: 0, max: 1, palette: palette}, 'NDVI Lebanon July 2020 V3')
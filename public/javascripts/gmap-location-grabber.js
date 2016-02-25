/**
 * Created by cacij on 2/12/2016.
 */

//Array of features stored on the map. Used only for display, not submission.
var overlays = [];

//Initiate the map, geocoder, and drawing manager
function initMap() {

    //The inital map object
    var map = new google.maps.Map(document.getElementById('map'), {
        zoom: 11,
        center: {lat: 47.6062095, lng: -122.3320708}
    });

    //The geocoder and its event listener
    var geocoder = new google.maps.Geocoder();
    document.getElementById('geocode-submit').addEventListener('click', function () {
        geocodeAddress(geocoder, map);
    });

    //The drawing controls and manager
    var drawingManager = new google.maps.drawing.DrawingManager({
        drawingMode: null,
        drawingControl: true,
        drawingControlOptions: {
            position: google.maps.ControlPosition.BOTTOM_CENTER,
            drawingModes: [
                google.maps.drawing.OverlayType.MARKER,

                //More drawing options if we decide to include them

                //google.maps.drawing.OverlayType.CIRCLE,
                //google.maps.drawing.OverlayType.POLYGON,
                //google.maps.drawing.OverlayType.POLYLINE,
                //google.maps.drawing.OverlayType.RECTANGLE
            ]
        }
    });
    drawingManager.setMap(map);

    //If the hidden input has content, load it into the map
    var hiddenContainerValue = document.getElementById('hidden-json-container').value;
    if(hiddenContainerValue != "")
    {
        map.data.addGeoJson(JSON.parse(hiddenContainerValue));
    }

    //Clear button event listener
    document.getElementById('geocode-clear').addEventListener('click', function () {
        clearOverlay(map);
    });

    //Event listener for drawn shapes
    google.maps.event.addListener(drawingManager, 'overlaycomplete', function (event) {
        drawObject(event, map)
    });

    //Event listener for the submit button
    document.getElementById('map-submit').addEventListener('click', function () {
                /*
                 * Code to submit the locations goes here. Currently, this just fills
                 * the input box named 'hidden-json-container' with the GeoJSON data.
                 */
        
                map.data.toGeoJson(function(result){
                    document.getElementById('hidden-json-container').value = Object.toJSON(result);
        		})
            });

}

//Geocode a submitted address, provide error message if unsuccessful
function geocodeAddress(geocoder, resultsMap) {
    var address = document.getElementById('address').value;
    geocoder.geocode({
        'address': address,
        bounds: {east: -117, north: 49, south: 46.5, west: -125}
    }, function (results, status) {
        if (status === google.maps.GeocoderStatus.OK) {
            resultsMap.setCenter(results[0].geometry.location);

            var datamarker = new google.maps.Data.Feature({
                geometry: results[0].geometry.location
            });

            resultsMap.data.add(datamarker);

        } else {
            alert('Geocode was not successful for the following reason: ' + status);
        }
    });
}

//Clear map and delete overlay objects
function clearOverlay(map) {
    map.data.forEach(function (feature) {
        map.data.remove(feature);
    });
}

//Draw objects, add their overlays to the map and their coordinates to the data layer
function drawObject(event, resultsMap) {
    var shape;
    var geometry;

    if (event.type == google.maps.drawing.OverlayType.MARKER) {
        shape = new google.maps.Data.Feature({geometry: event.overlay.getPosition()});
    }
    else if (event.type == google.maps.drawing.OverlayType.POLYGON) {
        geometry = new google.maps.Data.Polygon([event.overlay.getPath().getArray()]);
        shape = new google.maps.Data.Feature({geometry: geometry});
    }
    else if (event.type == google.maps.drawing.OverlayType.POLYLINE) {
        geometry = new google.maps.Data.LineString(event.overlay.getPath().getArray());
        shape = new google.maps.Data.Feature({geometry: geometry});
    }
    else if (event.type == google.maps.drawing.OverlayType.RECTANGLE) {

        var neX = event.overlay.getBounds().getNorthEast().lat(),
            neY = event.overlay.getBounds().getNorthEast().lng(),
            swX = event.overlay.getBounds().getSouthWest().lat(),
            swY = event.overlay.getBounds().getSouthWest().lng()

        geometry = new google.maps.Data.Polygon([[{
            lat: swX,
            lng: neY
        }, {
            lat: neX,
            lng: neY
        }, {
            lat: neX,
            lng: swY
        }, {
            lat: swX,
            lng: swY
        }]]);

        shape = new google.maps.Data.Feature({geometry: geometry});
    }
    else if (event.type == google.maps.drawing.OverlayType.CIRCLE) {
        shape = new google.maps.Data.Feature({
            geometry: event.overlay.getCenter(),
            properties: {
                radius: event.overlay.getRadius()
            }
        });
    }
    event.overlay.setMap(null);
    resultsMap.data.add(shape);
}
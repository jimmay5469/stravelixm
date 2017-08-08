// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

import Elm from "./main";
import GoogleMapsLoader from "google-maps";

const gMapStyle = [
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dadada"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#c9c9c9"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  }
];

const elmDiv = document.getElementById("elm-target");
GoogleMapsLoader.KEY = elmDiv.dataset.key;
GoogleMapsLoader.LIBRARIES = ["geometry"];

if (elmDiv) {
  GoogleMapsLoader.load(function(google) {
    const flags = {
      activities: JSON.parse(elmDiv.dataset.activities)
    };
    console.log("Flags:", flags)
    const app = Elm.Main.embed(elmDiv, flags);

    let map, mappedActivities, miniMap, miniMapWindow;
    const resetZoom = ()=> {
      const bounds = new google.maps.LatLngBounds();
      mappedActivities.forEach(ma=>ma.path.forEach(point=>bounds.extend(point)));
      map.fitBounds(bounds);
    };
    app.ports.loadMap.subscribe((activities)=> {
      const mapDiv = document.getElementById("map");
      const miniMapDiv = document.getElementById("miniMap");

      map = new google.maps.Map(mapDiv,  { styles: gMapStyle });
      miniMap = new google.maps.Map(miniMapDiv,  {
        disableDefaultUI: true,
        disableDoubleClickZoom: true,
        draggable: false,
        keyboardShortcuts: false,
        scrollwheel: false,
        styles: gMapStyle
      });
      miniMapWindow = new google.maps.InfoWindow({
        disableAutoPan: true,
        content: miniMapDiv
      });

      mappedActivities = activities
        .filter(a=>a.map.summary_polyline)
        .map(activity=> {
          const path = google.maps.geometry.encoding.decodePath(activity.map.summary_polyline);
          const polyline = new google.maps.Polyline({
            path,
            strokeColor: "red",
            strokeWeight: 2
          });
          const miniMapPolyline = new google.maps.Polyline({
            path,
            strokeColor: "red",
            strokeWeight: 2
          });
          return { activity, path, polyline, miniMapPolyline };
        });
      mappedActivities.forEach(ma=>ma.polyline.setMap(map));
      mappedActivities.forEach(ma=>ma.miniMapPolyline.setMap(miniMap));
      resetZoom();
    });
    app.ports.highlightActivity.subscribe((activity)=> {
      if (!activity.map.summary_polyline) {
        return;
      }
      mappedActivities.forEach(ma=> {
        if (ma.activity.id === activity.id) {
          ma.polyline.setOptions({
            strokeWeight: 5
          })
          ma.miniMapPolyline.setOptions({
            strokeWeight: 5
          })

          const bounds = new google.maps.LatLngBounds();
          ma.path.forEach(point=>bounds.extend(point));

          const ne = map.getProjection().fromLatLngToPoint(bounds.getNorthEast());
          const sw = map.getProjection().fromLatLngToPoint(bounds.getSouthWest());
          const distance = Math.sqrt(Math.pow(ne.x - sw.x, 2) + Math.pow(ne.y - sw.y, 2));
          const scale = 1 << map.getZoom();
          const boundsPixelSize = distance * scale;

          if (boundsPixelSize < 30) {
            miniMapWindow.open(map);
            miniMap.fitBounds(bounds);
            miniMapWindow.setPosition(ma.path[0]);
          }
        } else {
          ma.polyline.setOptions({
            strokeWeight: 2
          })
          ma.miniMapPolyline.setOptions({
            strokeWeight: 2
          })
        }
      });
    });
    app.ports.resetHighlight.subscribe(()=> {
      mappedActivities.forEach(ma=> {
        ma.polyline.setOptions({
          strokeWeight: 2
        })
        ma.miniMapPolyline.setOptions({
          strokeWeight: 2
        })
      });
      miniMapWindow.close();
    });
    app.ports.zoomActivity.subscribe((activity)=> {
      if (!activity.map.summary_polyline) {
        return;
      }
      const bounds = new google.maps.LatLngBounds();
      const path = google.maps.geometry.encoding.decodePath(activity.map.summary_polyline);
      path.forEach(point=>bounds.extend(point));
      map.fitBounds(bounds);
    });
    app.ports.resetZoom.subscribe(resetZoom);
  });
}

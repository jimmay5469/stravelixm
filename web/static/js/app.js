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
import GoogleMapStyle from "./google-map-style";

const elmDiv = document.getElementById("elm-target");
GoogleMapsLoader.KEY = elmDiv.dataset.googleApiKey;
GoogleMapsLoader.LIBRARIES = ["geometry"];

if (elmDiv) {
  GoogleMapsLoader.load(function(google) {
    const loginLink = elmDiv.dataset.loginLink;
    const logoutLink = elmDiv.dataset.logoutLink;
    const athlete = JSON.parse(elmDiv.dataset.athlete);
    const activities = JSON.parse(elmDiv.dataset.activities) || [];
    const flags = {
      loginLink,
      logoutLink,
      athlete: !athlete ? null : {
        id: athlete.id,
        lastname: athlete.lastname || null,
        firstname: athlete.firstname || null
      },
      activities: activities.map((a)=>({
        id: a.id,
        name: a.name,
        athlete: {
          id: a.athlete.id,
          lastname: a.athlete.lastname || null,
          firstname: a.athlete.firstname || null
        },
        map: {
          summaryPolyline: a.map.summary_polyline || null
        }
      }))
    };
    console.log("Login Link: ", loginLink);
    console.log("Logout Link: ", logoutLink);
    console.log("Athlete: ", athlete);
    console.log("Activities: ", activities);
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

      map = new google.maps.Map(mapDiv,  { styles: GoogleMapStyle });
      miniMap = new google.maps.Map(miniMapDiv,  {
        disableDefaultUI: true,
        disableDoubleClickZoom: true,
        draggable: false,
        keyboardShortcuts: false,
        scrollwheel: false,
        styles: GoogleMapStyle
      });
      miniMapWindow = new google.maps.InfoWindow({
        disableAutoPan: true,
        content: miniMapDiv,
        pixelOffset: new google.maps.Size(0, -5)
      });

      mappedActivities = activities
        .filter(a=>a.map.summaryPolyline)
        .map(activity=> {
          const path = google.maps.geometry.encoding.decodePath(activity.map.summaryPolyline);
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
          polyline.addListener('click', ()=> {
            app.ports.clickActivity.send(activity);
          });
          polyline.addListener('mouseover', ()=> {
            app.ports.hoverActivity.send(activity);
          });
          polyline.addListener('mouseout', ()=> {
            app.ports.unhoverActivity.send(null);
          });
          return { activity, path, polyline, miniMapPolyline };
        });
      mappedActivities.forEach(ma=>ma.polyline.setMap(map));
      mappedActivities.forEach(ma=>ma.miniMapPolyline.setMap(miniMap));
      resetZoom();
    });
    app.ports.highlightActivity.subscribe((activity)=> {
      if (!activity.map.summaryPolyline) {
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
      if (!activity.map.summaryPolyline) {
        return;
      }
      const bounds = new google.maps.LatLngBounds();
      const path = google.maps.geometry.encoding.decodePath(activity.map.summaryPolyline);
      path.forEach(point=>bounds.extend(point));
      map.fitBounds(bounds);
      miniMapWindow.close();
    });
    app.ports.resetZoom.subscribe(resetZoom);
  });
}

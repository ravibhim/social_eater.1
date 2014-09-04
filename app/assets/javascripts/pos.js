var geocoder, loc;

function getLocation() {
  if($.cookie('_locality')) {
    updateAddress($.cookie('_locality'));
  } else {
    updateLocation();
  }

  var updated_at = $.cookie('_updated_at');

  if(updated_at) {
    date = new Date();
    if (date.getTime() - updated_at > 120000) {
      updateLocation();
    }
  }
}

function updateLocation() {
  geocoder = new google.maps.Geocoder();

  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(geoSuccess, geoError,{enableHighAccuracy: false});
  }
}

function geoSuccess(pos) {
  var lat = pos.coords.latitude;
  var lon = pos.coords.longitude;
  $.cookie('_lat',lat);
  $.cookie('_lon',lon);
  computeLocation(lat,lon);
}

function geoError(e) {
  manualLocation('GPS is disabled on your device. Please select your location.');
}

function computeLocation(lat, lng) {
  var latlng = new google.maps.LatLng(lat, lng);
  geocoder.geocode({'location': latlng}, function(results, status) {
    if (status == google.maps.GeocoderStatus.OK) {
      if (results[1]) {
        loc = results[3].formatted_address.split(',');
        updateAddress(loc[0]);
      } else {
        manualLocation();
      }
    } else {
      manualLocation();
    }
  });
}

function updateAddress(addr) {
  $('.btn-loc span').html(addr);
  $.cookie('_locality',addr);
  date = new Date();
  $.cookie('_updated_at',date.getTime());
  updatePlaces();
}

function manualLocation(msg) {
  var m = msg? msg : 'Select your Location';

  $('#selectLocation .modal-title').html(m);

  $('#selectLocation').modal({
    backdrop: 'static',
    keyboard: false
  });
}

function setLocation() {
  $('#selectLocation .form-control').each(function() {
    if($(this).val()) {
      updateAddress($(this).val());
    } else {
      $(this).addClass('has-error');
    }
  });
}


function updatePlaces() {
  $.get(
    '/searches/places',
    {
      area: $.cookie('_locality')
    },
    function(data) {
      //alert(data);
      $('#places .content').html(data);
    }
  );
}

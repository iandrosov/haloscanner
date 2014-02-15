/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
var parentElementID;
var app = {
    // Application Constructor
    initialize: function() {
        this.bindEvents();
        
    },
    // Bind Event Listeners
    //
    // Bind any events that are required on startup. Common events are:
    // 'load', 'deviceready', 'offline', and 'online'.
    bindEvents: function() {
        document.addEventListener('deviceready', this.onDeviceReady, false);
    },
    // deviceready Event Handler
    //
    // The scope of 'this' is the event. In order to call the 'receivedEvent'
    // function, we must explicity call 'app.receivedEvent(...);'
    onDeviceReady: function() {
        app.receivedEvent('deviceready');
        
        //========================================================================
        // Initialize Scanner device
        cordova.exec(onSuccessScan, onErrorScanner, "IPCardScanner", "initScanner", []);
        //========================================================================
        
    },
    // Update DOM on a Received Event
    receivedEvent: function(id) {
        parentElementID = id;
        //var parentElement = document.getElementById(id);
        //var listeningElement = parentElement.querySelector('.listening');
        //var receivedElement = parentElement.querySelector('.received');

        //listeningElement.setAttribute('style', 'display:none;');
        //receivedElement.setAttribute('style', 'display:block;');

        //onSuccessScan('TEST');
        
        console.log('Received Event: ' + id);
    }
};

function onSuccessScan(results) {
    console.log("Call success on scanner device "+results);
    // Set connection and battery status

    var parentElement = document.getElementById('deviceready');
    var listeningElement = parentElement.querySelector('.listening');
    var receivedElement = parentElement.querySelector('.received');
    
    listeningElement.setAttribute('style', 'display:none;');
    receivedElement.setAttribute('style', 'display:block;');
    
    
    alert("Call success on scanner device "+results);
}

function onErrorScanner(error) {
    //cordova.require("salesforce/util/logger").logToConsole("onErrorSfdc: " + JSON.stringify(error));
    console.log("Scanner Error "+error);
    alert("Error Init Scanner!");
}

// Called when member card Barcode was scanned and number passed as parameter
function onSuccessScanBarcode(code) {
    console.log("Member card scan success on scanner device "+code);
    
    alert("Barcode: "+code);
    
}

// Called by DTScanner plugin in respnse to magnetic card swipe Credit Card reader
// responds with CC account information
function onSuccessScanPaymentCard(ccinfo) {
    console.log("Payment Card scan success on scanner device "+ccinfo);
    
    alert("Payment Card success on scanner device "+ccinfo);
}

// Called by DTScanner plugin in response to Device connection event
function reportConnectionStatus(results) {
    console.log("Scanner device CONNECTED "+results);
    // Set connection and abttery status
    var parentElement = document.getElementById('deviceready');
    var listeningElement = parentElement.querySelector('.listening');
    var receivedElement = parentElement.querySelector('.received');
    if (results == "SCANNER_CONNECTED"){
        listeningElement.setAttribute('style', 'display:none;');
        receivedElement.setAttribute('style', 'display:block;');
    }else{
        listeningElement.setAttribute('style', 'display:block;');
        receivedElement.setAttribute('style', 'display:none;');
    }
}

// Called by DTScanner plugin returns battery charge information
function reportBatteryStatus(results) {
    console.log("Battery "+results);
    
    // Set connection and abttery status
    var pe = document.getElementById('battery');
    var batteryElement = pe.querySelector('.battery');
    
    batteryElement.innerText = results;

}


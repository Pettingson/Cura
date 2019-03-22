// Copyright (c) 2019 Ultimaker B.V.
// Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import UM 1.3 as UM
import Cura 1.1 as Cura


//
// This component contains the content for the 'by IP' page of the "Add New Printer" flow of the on-boarding process.
//
Item
{
    UM.I18nCatalog { id: catalog; name: "cura" }

    id: addPrinterByIpScreen

    // Whether an IP address is currently being resolved.
    property bool hasSentRequest: false
    // Whether the IP address user entered can be resolved as a recognizable printer.
    property bool haveConnection: false

    Label
    {
        id: titleLabel
        anchors.top: parent.top
        anchors.topMargin: UM.Theme.getSize("welcome_pages_default_margin").height
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        text: catalog.i18nc("@label", "Add printer by IP address")
        color: UM.Theme.getColor("primary_button")
        font: UM.Theme.getFont("large_bold")
        renderType: Text.NativeRendering
    }

    Item
    {
        anchors.top: titleLabel.bottom
        anchors.bottom: connectButton.top
        anchors.topMargin: UM.Theme.getSize("default_margin").height
        anchors.bottomMargin: UM.Theme.getSize("default_margin").height
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.floor(parent.width * 3 / 4)

        Item
        {
            width: parent.width

            Label
            {
                id: explainLabel
                height: contentHeight
                width: parent.width
                anchors.top: parent.top
                anchors.margins: UM.Theme.getSize("default_margin").width
                font: UM.Theme.getFont("default")

                text: catalog.i18nc("@label", "Enter the IP address or hostname of your printer on the network.")
            }

            Item
            {
                id: userInputFields
                height: childrenRect.height
                width: parent.width
                anchors.top: explainLabel.bottom

                TextField
                {
                    id: hostnameField
                    anchors.verticalCenter: addPrinterButton.verticalCenter
                    anchors.left: parent.left
                    height: addPrinterButton.height
                    anchors.right: addPrinterButton.left
                    anchors.margins: UM.Theme.getSize("default_margin").width
                    font: UM.Theme.getFont("default")

                    validator: RegExpValidator
                    {
                        regExp: /[a-fA-F0-9\.\:]*/
                    }

                    onAccepted: addPrinterButton.clicked()
                }

                Cura.PrimaryButton
                {
                    id: addPrinterButton
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: UM.Theme.getSize("default_margin").width
                    width: UM.Theme.getSize("action_button").width
                    fixedWidthMode: true

                    text: catalog.i18nc("@button", "Add")
                    onClicked:
                    {
                        if (hostnameField.text.trim() != "")
                        {
                            enabled = false;
                            UM.OutputDeviceManager.addManualDevice(hostnameField.text, hostnameField.text);
                        }
                    }

                    BusyIndicator
                    {
                        anchors.fill: parent
                        running:
                        {
                            ! parent.enabled &&
                            ! addPrinterByIpScreen.hasSentRequest &&
                            ! addPrinterByIpScreen.haveConnection
                        }
                    }
                }
            }

            Item
            {
                width: parent.width
                anchors.top: userInputFields.bottom
                anchors.margins: UM.Theme.getSize("default_margin").width

                Label
                {
                    id: waitResponseLabel
                    anchors.top: parent.top
                    anchors.margins: UM.Theme.getSize("default_margin").width
                    font: UM.Theme.getFont("default")

                    visible: { addPrinterByIpScreen.hasSentRequest && ! addPrinterByIpScreen.haveConnection }
                    text: catalog.i18nc("@label", "The printer at this address has not responded yet.")
                }

                Item
                {
                    id: printerInfoLabels
                    anchors.top: parent.top
                    anchors.margins: UM.Theme.getSize("default_margin").width

                    visible: addPrinterByIpScreen.haveConnection

                    Label
                    {
                        id: printerNameLabel
                        anchors.top: parent.top
                        font: UM.Theme.getFont("large")

                        text: "???"
                    }

                    GridLayout
                    {
                        id: printerInfoGrid
                        anchors.top: printerNameLabel.bottom
                        anchors.margins: UM.Theme.getSize("default_margin").width
                        columns: 2
                        columnSpacing: UM.Theme.getSize("default_margin").width

                        Label { font: UM.Theme.getFont("default"); text: catalog.i18nc("@label", "Type") }
                        Label { id: typeText; font: UM.Theme.getFont("default"); text: "?" }

                        Label { font: UM.Theme.getFont("default"); text: catalog.i18nc("@label", "Firmware version") }
                        Label { id: firmwareText; font: UM.Theme.getFont("default"); text: "0.0.0.0" }

                        Label { font: UM.Theme.getFont("default"); text: catalog.i18nc("@label", "Address") }
                        Label { id: addressText; font: UM.Theme.getFont("default"); text: "0.0.0.0" }

                        Connections
                        {
                            target: UM.OutputDeviceManager
                            onManualDeviceChanged:
                            {
                                typeText.text = UM.OutputDeviceManager.manualDeviceProperty("printer_type")
                                firmwareText.text = UM.OutputDeviceManager.manualDeviceProperty("firmware_version")
                                addressText.text = UM.OutputDeviceManager.manualDeviceProperty("address")
                            }
                        }
                    }

                    Connections
                    {
                        target: UM.OutputDeviceManager
                        onManualDeviceChanged:
                        {
                            printerNameLabel.text = UM.OutputDeviceManager.manualDeviceProperty("name")
                            addPrinterByIpScreen.haveConnection = true
                        }
                    }
                }
            }
        }
    }

    Cura.PrimaryButton
    {
        id: backButton
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: UM.Theme.getSize("welcome_pages_default_margin").width
        text: catalog.i18nc("@button", "Cancel")
        width: UM.Theme.getSize("action_button").width
        fixedWidthMode: true
        onClicked: base.goToPage("add_printer_by_selection")
    }

    Cura.PrimaryButton
    {
        id: connectButton
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: UM.Theme.getSize("welcome_pages_default_margin").width
        text: catalog.i18nc("@button", "Connect")
        width: UM.Theme.getSize("action_button").width
        fixedWidthMode: true
        onClicked:
        {
            CuraApplication.getDiscoveredPrintersModel().createMachineFromDiscoveredPrinterAddress(
                UM.OutputDeviceManager.manualDeviceProperty("address"))
            UM.OutputDeviceManager.setActiveDevice(UM.OutputDeviceManager.manualDeviceProperty("device_id"))
            base.showNextPage()
        }

        enabled: addPrinterByIpScreen.haveConnection
    }
}

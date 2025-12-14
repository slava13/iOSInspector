//
//  LocatosSuggestionsBuilder.swift
//  Dumper
//
//  Created by Iaroslav on 14/12/2025.
//

import Foundation

struct LocatorSuggestion: Identifiable {
    let id = UUID()
    let title: String
    let code: String
    let isRecommended: Bool
}


enum LocatorSuggestionBuilder {
    static func suggestions(for node: ViewNode) -> [LocatorSuggestion] {
        let queryRoot = elementQueryRoot(for: node)

        var result: [LocatorSuggestion] = []

        // 1) Best: Identifier
        if let identifier = nonEmpty(node.identifier) {
            result.append(.init(
                title: "Recommended (Identifier)",
                code: """
                let element = \(queryRoot)["\(escape(identifier))"]
                """,
                isRecommended: true
            ))
        }

        // 2) Fallback: Predicate (contains) — use label if possible, else identifier
        if let token = nonEmpty(node.label) ?? nonEmpty(node.identifier) {
            result.append(.init(
                title: "Fallback (Predicate contains)",
                code: """
                let element = \(queryRoot)
                    .matching(NSPredicate(format: "label CONTAINS %@", "\(escape(token))"))
                    .firstMatch
                """,
                isRecommended: false
            ))
        }

        return result
    }

    // MARK: - Helpers

    private static func elementQueryRoot(for node: ViewNode) -> String {
        let raw = node.type
        let normalized = normalizeType(raw)

        if let queryProperty = typeToQueryProperty[normalized] {
            return "app.\(queryProperty)"
        }

        if allQueryProperties.contains(normalized) {
            return "app.\(normalized)"
        }

        return "app.otherElements"
    }

    private static func normalizeType(_ raw: String) -> String {
        var s = raw.trimmingCharacters(in: .whitespacesAndNewlines)

        s = s.replacingOccurrences(of: "XCUIElementType", with: "")
        s = s.replacingOccurrences(of: "XCUIElement", with: "")

        s = s.replacingOccurrences(of: " ", with: "")
        s = s.replacingOccurrences(of: "_", with: "")
        s = s.lowercased()

        return s
    }
    
    // All properties from XCUIElementTypeQueryProvider
    private static let allQueryProperties: Set<String> = [
        "touchBars", "groups", "windows", "sheets", "drawers",
        "alerts", "dialogs", "buttons", "radioButtons", "radioGroups",
        "checkBoxes", "disclosureTriangles", "popUpButtons", "comboBoxes",
        "menuButtons", "toolbarButtons", "popovers", "keyboards", "keys",
        "navigationBars", "tabBars", "tabGroups", "toolbars", "statusBars",
        "tables", "tableRows", "tableColumns", "outlines", "outlineRows",
        "disclosedChildRows", "browsers", "collectionViews", "sliders",
        "pageIndicators", "progressIndicators", "activityIndicators",
        "segmentedControls", "pickers", "pickerWheels", "switches", "toggles",
        "links", "images", "icons", "searchFields", "scrollViews", "scrollBars",
        "staticTexts", "textFields", "secureTextFields", "datePickers",
        "textViews", "menus", "menuItems", "menuBars", "menuBarItems",
        "maps", "webViews", "steppers", "incrementArrows", "decrementArrows",
        "tabs", "timelines", "ratingIndicators", "valueIndicators",
        "splitGroups", "splitters", "relevanceIndicators", "colorWells",
        "helpTags", "mattes", "dockItems", "rulers", "rulerMarkers",
        "grids", "levelIndicators", "cells", "layoutAreas", "layoutItems",
        "handles", "otherElements", "statusItems"
    ]

    // Map singular-ish element type names from dumps to plural query properties.
    // Keys must be normalized (lowercased, no spaces, no XCUIElementType prefix).
    private static let typeToQueryProperty: [String: String] = [
        "touchbar": "touchBars",
        "group": "groups",
        "window": "windows",
        "sheet": "sheets",
        "drawer": "drawers",
        "alert": "alerts",
        "dialog": "dialogs",

        "button": "buttons",
        "radiobutton": "radioButtons",
        "radiogroup": "radioGroups",
        "checkbox": "checkBoxes",
        "disclosuretriangle": "disclosureTriangles",
        "popupbutton": "popUpButtons",
        "combobox": "comboBoxes",
        "menubutton": "menuButtons",
        "toolbarbutton": "toolbarButtons",
        "popover": "popovers",

        "keyboard": "keyboards",
        "key": "keys",

        "navigationbar": "navigationBars",
        "tabbar": "tabBars",
        "tabgroup": "tabGroups",
        "toolbar": "toolbars",
        "statusbar": "statusBars",

        "table": "tables",
        "tablerow": "tableRows",
        "tablecolumn": "tableColumns",
        "outline": "outlines",
        "outlinerow": "outlineRows",
        "disclosedchildrow": "disclosedChildRows",
        "browser": "browsers",
        "collectionview": "collectionViews",

        "slider": "sliders",
        "pageindicator": "pageIndicators",
        "progressindicator": "progressIndicators",
        "activityindicator": "activityIndicators",
        "segmentedcontrol": "segmentedControls",
        "picker": "pickers",
        "pickerwheel": "pickerWheels",
        "switch": "switches",
        "toggle": "toggles",

        "link": "links",
        "image": "images",
        "icon": "icons",
        "searchfield": "searchFields",
        "scrollview": "scrollViews",
        "scrollbar": "scrollBars",

        "statictext": "staticTexts",
        "textfield": "textFields",
        "securetextfield": "secureTextFields",
        "datepicker": "datePickers",
        "textview": "textViews",

        "menu": "menus",
        "menuitem": "menuItems",
        "menubar": "menuBars",
        "menubaritem": "menuBarItems",

        "map": "maps",
        "webview": "webViews",

        "stepper": "steppers",
        "incrementarrow": "incrementArrows",
        "decrementarrow": "decrementArrows",

        "tab": "tabs",
        "timeline": "timelines",
        "ratingindicator": "ratingIndicators",
        "valueindicator": "valueIndicators",

        "splitgroup": "splitGroups",
        "splitter": "splitters",
        "relevanceindicator": "relevanceIndicators",
        "colorwell": "colorWells",
        "helptag": "helpTags",
        "matte": "mattes",
        "dockitem": "dockItems",

        "ruler": "rulers",
        "rulermarker": "rulerMarkers",
        "grid": "grids",
        "levelindicator": "levelIndicators",

        "cell": "cells",
        "layoutarea": "layoutAreas",
        "layoutitem": "layoutItems",
        "handle": "handles",

        "otherelement": "otherElements",
        "statusitem": "statusItems"
    ]

    
    private static func nonEmpty(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private static func escape(_ s: String) -> String {
        s.replacingOccurrences(of: #"\"#, with: #"\\\\"#)
            .replacingOccurrences(of: #"""#, with: #"\""#)
    }

}


//
//  LocationSearchView.swift
//  Trailgram
//
//  Created by 刘闰生 on 8/4/2025.
//

import SwiftUI
import MapKit
import Observation

/// LocationSearchView lets users search for a place using MapKit's MKLocalSearchCompleter.
/// Selecting a location triggers a callback with the coordinate.
@Observable
class LocalSearchManager {
    var results: [MKLocalSearchCompletion] = []

    let completer: MKLocalSearchCompleter
    private var delegateWrapper: SearchDelegateWrapper!

    init() {
        self.completer = MKLocalSearchCompleter()
        self.completer.resultTypes = [.address, .pointOfInterest]
        self.delegateWrapper = SearchDelegateWrapper(manager: self)
        self.completer.delegate = self.delegateWrapper
    }

    func updateResults(_ newResults: [MKLocalSearchCompletion]) {
        self.results = newResults
    }
}


/// LocalSearchManager manages search completions using a delegate wrapper.
/// Used as @Observable to bind results to SwiftUI view.
class SearchDelegateWrapper: NSObject, MKLocalSearchCompleterDelegate {
    weak var manager: LocalSearchManager?

    init(manager: LocalSearchManager) {
        self.manager = manager
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        manager?.updateResults(completer.results)
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Search failed: \(error.localizedDescription)")
    }
}



struct LocationSearchView: View {
    @Environment(\.dismiss) var dismiss
    @State private var queryFragment = ""
    var searchManager = LocalSearchManager()
    var onSelect: (CLLocationCoordinate2D) -> Void

    var body: some View {
        NavigationView {
            List {
                ForEach(searchManager.results, id: \.self) { completion in
                    Button {
                        search(for: completion)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(completion.title)
                                .font(.headline)
                            Text(completion.subtitle)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Search Location")
            .searchable(text: $queryFragment)
            .onChange(of: queryFragment, initial: false) { oldValue, newValue in
                searchManager.completer.queryFragment = newValue
            }
        }
    }

    func search(for completion: MKLocalSearchCompletion) {
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)

        search.start { response, error in
            if let coordinate = response?.mapItems.first?.placemark.coordinate {
                onSelect(coordinate)
                dismiss()
            }
        }
    }

}


// MARK: - Wrapper Delegate (since SwiftUI can't adopt delegate directly)
class SearchCompleterDelegate: NSObject, MKLocalSearchCompleterDelegate {
    var onUpdate: ([MKLocalSearchCompletion]) -> Void

    init(onUpdate: @escaping ([MKLocalSearchCompletion]) -> Void) {
        self.onUpdate = onUpdate
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        onUpdate(completer.results)
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Search completer failed: \(error.localizedDescription)")
    }
}


#Preview {
//    LocationSearchView()
}

//
//  LocationSearchView.swift
//  Trailgram
//
//  Created by 刘闰生 on 8/4/2025.
//

import SwiftUI
import MapKit
import Observation

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
    @Binding var selectedCoordinate: CLLocationCoordinate2D?

    @State private var queryFragment = ""
    var searchManager = LocalSearchManager() // ✅ 使用现代 Observable

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
                selectedCoordinate = coordinate
                dismiss()
            }
        }
    }

    // ✅ 保留你之前添加的构造器
    init(selectedCoordinate: Binding<CLLocationCoordinate2D?>) {
        self._selectedCoordinate = selectedCoordinate
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

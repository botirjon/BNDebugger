//
//  SearchBar.swift
//  BNDebugger
//
//  Created by MAC-Nasridinov-B on 11/09/25.
//

import SwiftUI

struct ConditionalSearchableModifier: ViewModifier {
    @Binding var text: String
    let prompt: String
    
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content.searchable(text: $text, prompt: prompt)
        } else {
            content
        }
    }
}

struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String
    
    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.delegate = context.coordinator
        searchBar.placeholder = placeholder
        searchBar.searchBarStyle = .minimal
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UISearchBarDelegate {
        let parent: SearchBar
        
        init(_ parent: SearchBar) {
            self.parent = parent
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            parent.text = searchText
        }
    }
}
